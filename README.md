# Tram::Policy

Policy Object Pattern

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]
[![Dependency Status][gemnasium-badger]][gemnasium]
[![Inline docs][inch-badger]][inch]

## Intro

Policy objects are responsible for context-related validation of objects, or mixes of objects. Here **context-related** means a validation doesn't check whether an object is valid by itself, but whether it is valid for some purpose (context). For example, we could ask if some article is ready (valid) to be published, etc.

There are several well-known interfaces exist for validation like [ActiveModel::Validations][active-model-validation], or its [ActiveRecord][active-record-validation] extension for Rails, or PORO [Dry::Validation][dry-validation]. All of them focus on providing rich DSL-s for **validation rules**.

**Tram::Policy** follows another approach -- it uses simple Ruby methods for validation, but focuses on building both *customizable* and *composable* results of validation, namely their errors.

- By **customizable** we mean adding any number of *tags* to errors -- to allow filtering and sorting validation results.
- By **composable** we mean a possibility to merge errors provided by one policy into another, and build nested sets of well-focused policies.

Keeping this reasons in mind, let's go to some examples.

## Synopsis

The gem uses [Dry::Initializer][dry-initializer] interface for defining params and options for policy object instanses:

```ruby
require "tram-policy"

class Article::ReadinessPolicy < Tram::Policy
  # required param for article to validate
  param  :article

  # memoized attributes of the article (you can set them explicitly in specs)
  option :title,    proc(&:to_s), default: -> { article.title }
  option :subtitle, proc(&:to_s), default: -> { article.subtitle }
  option :text,     proc(&:to_s), default: -> { article.text }

  # define what methods and in what order we should use to validate an article
  validate :title_presence
  validate :subtitle_presence
  validate do # use anonymous lambda
    return unless text.empty?
    errors.add :empty, field: "text", level: "error"
  end

  private

  def title_presence
    return unless title.empty?
    # Adds an error with a unique key and a set of additional tags
    # You can use any tags, not only an attribute/field like in ActiveModel
    errors.add :blank_title, field: "title", level: "error"
  end

  def subtitle_presence
    return unless subtitle.empty?
    # Notice that we can set another level
    errors.add :blank_subtitle, field: "subtitle", level: "warning"
  end
end
```

Because validation is the only responsibility of a policy, we don't need to call it explicitly.

Policy initializer will perform all the checks immediately, memoizing the results into `errors` array. The methods `#valid?`, `#invalid?` and `#validate!` just check those `#errors`.

You should treat an instance immutable.

```ruby
article = Article.new title: "A wonderful article", subtitle: "", text: ""
policy  = Article::ReadinessPolicy[article] # syntax sugar for constructor `new`

# Simple checks
policy.errors.any? # => true
policy.valid?      # => false
policy.invalid?    # => true
policy.validate!   # raises Tram::Policy::ValidationError

# And errors
policy.errors.count # => 2 (no subtitle, no text)
policy.errors.filter { |error| error.tags[:level] == "error" }.count # => 1
policy.errors.filter { |error| error.level == "error" }.count # => 1
```

## Validation Results

Let look at those errors closer. We define 3 representation of errors:

- error objects (`policy.errors`)
- error items (`policy.items`, `policy.errors.items`, `policy.errors.map(&:item)`)
- error messages (`policy.messages`, `policy.errors.messages`, `policy.errors.map(&:message)`)

Errors by themselves are used for composition (see the next chapter), while `items` and `messages` represent errors for translation.

The difference is the following.

- The `messages` are translated immediately using the current locale.

- The `items` postpone translation for later (for example, you can store them in a database and translate them to the locale of UI by demand).

### Items

Error items contain arrays that could be send to I18n.t for translation. We add the default scope from the name of policy, preceeded by the `["tram-policy"]` root namespace.

```ruby
policy.items # or policy.errors.items, or policy.errors.map(&:item)
# => [
#      [
#        :blank_title,
#        {
#          scope: ["tram-policy", "article/readiness_policy"]],
#          field: "title",
#          level: "error"
#        }
#      ],
#      ...
#    ]

I18n.t(*policy.items.first)
# => "translation missing: en.tram-policy.article/readiness_policy.blank_title"
```

You can change the root scope if you will (this could be useful in libraries):

```ruby
class MyGemPolicy < Tram::Policy
  root_scope "mygem", "policies" # inherited by subclasses
end

class Article::ReadinessPolicy < MyGemPolicy
  # ...
end

# ...
I18n.t(*policy.items.first)
# => "translation missing: en.mygem.policies.article/readiness_policy.blank_title"
```

### Messages

Error messages contain translation of `policy.items` in the current locale:

```ruby
policy.messages # or policy.errors.messages, or policy.errors.map(&:message)
# => [
#      "translation missing: en.tram-policy.article/readiness_policy.blank_title",
#      "translation missing: en.tram-policy.article/readiness_policy.blank_subtitle"
#    ]
```

The messages are translated if the keys are symbolic. Strings are treated as already translated:

```ruby
class Article::ReadinessPolicy < Tram::Policy
  # ...
  def title_presence
    return unless title.empty?
    errors.add "Title is absent", field: "title", level: "error"
  end
end

# ...
policy.messages
# => [
#      "Title is absent",
#      "translation missing: en.tram-policy.article/readiness_policy.blank_subtitle"
#    ]
```

## Partial Validation

You can use tags in checkers -- to add condition for errors to ignore

```ruby
policy.valid? { |error| !%w(warning error).include? error.level } # => false
policy.valid? { |error| error.level != "disaster" }               # => true
```

Notice the `invalid?` method takes a block with definitions for errors to count (not ignore)

```ruby
policy.invalid? { |error| %w(warning error).include? error.level } # => true
policy.invalid? { |error| error.level == "disaster" }              # => false

policy.validate! { |error| error.level != "disaster" } # => nil (seems ok)
```

## Composition of Policies

You can use errors in composition of policies:

```ruby
class Article::PublicationPolicy < Tram::Policy
  param  :article
  option :selected, proc { |value| !!value } # enforce booleans

  validate :article_readiness
  validate :article_selection

  private

  def article_readiness
    # Collects errors tagged by level: "error" from "nested" policy
    readiness_errors = Article::ReadinessPolicy[article].errors.filter(level: "error")

    # Merges collected errors to the current ones.
    # New errors are also tagged by source: "readiness".
    errors.merge(readiness_errors, source: "readiness")
  end

  def article_selection
    errors.add "Not selected", field: "selected", level: "info" unless selected
  end
end
```

## Exceptions

When you use `validate!` it raises `Tram::Policy::ValidationError` (subclass of `RuntimeError`). Its message is built from selected errors (taking into account a `validation!` filter).

The exception also carries a backreference to the `policy` that raised it. You can use it to extract either errors, or arguments of the policy during a debugging:

```ruby
begin
  policy.validate!
rescue Tram::Policy::ValidationError => error
  error.policy == policy # => true
end
```

## Additional options

Class method `.validate` supports several options:

### `stop_on_failure`

If a selected validation will fail (adds an error to the collection), the following validations won't be executed.

```ruby
require "tram-policy"

class Article::ReadinessPolicy < Tram::Policy
  # required param for article to validate
  param  :article

  validate :title_presence, stop_on_failure: true
  validate :title_valid # not executed if title is absent

  # ...
end
```

## RSpec matchers

RSpec matchers defined in a file `tram-policy/matcher` (not loaded in runtime).

Use `be_invalid_at` matcher to check whether a policy has errors with given tags.

```ruby
# app/policies/user/readiness_policy.rb
class User::ReadinessPolicy < Tram::Policy
  option :name,  proc(&:to_s), optional: true
  option :email, proc(&:to_s), optional: true

  validate :name_presence

  private

  def name_presence
    return unless name.empty?
    errors.add "Name is absent", level: "error"
  end
end
```

```ruby
# spec/spec_helper.rb
require "tram/policy/rspec"
```

```ruby
# spec/policies/user/readiness_policy_spec.rb
RSpec.describe User::ReadinessPolicy do
  subject(:policy) { described_class[email: "user@example.com"] }

  let(:user) { build :user } # <- expected a factory

  it { is_expected.to be_invalid }
  it { is_expected.to be_invalid_at level: "error" }
  it { is_expected.to be_valid_at   level: "info" }
end
```

The matcher checks not only the presence of an error, but also ensures that you provided translation of any message to any available locale (`I18n.available_locales`).

## Generators

The gem provides simple tool for scaffolding new policy along with its RSpec test template and translations.

```shell
$ tram-policy user/readiness_policy -p user -o admin -v name_present:blank_name email_present:blank_email
```

This will generate a policy class with specification compatible to both [RSpec][rspec] and [FactoryBot][factory_bot].

Under the keys `-p` and `-o` define params and options of the policy.
Key `-v` should contain validation methods along with their error message keys.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tram-policy'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install tram-policy
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[codeclimate-badger]: https://img.shields.io/codeclimate/github/tram-rb/tram-policy.svg?style=flat
[codeclimate]: https://codeclimate.com/github/tram-rb/tram-policy
[gem-badger]: https://img.shields.io/gem/v/tram-policy.svg?style=flat
[gem]: https://rubygems.org/gems/tram-policy
[gemnasium-badger]: https://img.shields.io/gemnasium/tram-rb/tram-policy.svg?style=flat
[gemnasium]: https://gemnasium.com/tram-rb/tram-policy
[inch-badger]: http://inch-ci.org/github/tram-rb/tram-policy.svg
[inch]: https://inch-ci.org/github/tram-rb/tram-policy
[travis-badger]: https://img.shields.io/travis/tram-rb/tram-policy/master.svg?style=flat
[travis]: https://travis-ci.org/tram-rb/tram-policy
[active-model-validation]: http://api.rubyonrails.org/classes/ActiveModel/Validations.html
[active-record-validation]: http://guides.rubyonrails.org/active_record_validations.html
[dry-validation]: http://dry-rb.org/gems/dry-validation/
[dry-initializer]: http://dry-rb.org/gems/dry-initializer/
[i18n]: https://github.com/svenfuchs/i18n
[rspec]: http://rspec.info/
[factory_bot]: https://github.com/thoughtbot/factory_bot
