# Tram::Policy

Policy Object Pattern

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]
[![Dependency Status][gemnasium-badger]][gemnasium]
[![Code Climate][codeclimate-badger]][codeclimate]
[![Inline docs][inch-badger]][inch]

## Intro

Policy objects are responcible for context-related validation of objects, or mixes of objects. Here **context-related** means a validation doesn't check whether an object is valid by itself, but whether it is valid for some purpose (context). For example, we could ask, is some article is ready (valid) for been published, etc.

There are several well-known interfaces exist for validation like [ActiveModel::Validations][active-model-validation], or its [ActiveRecord][active-record-validation] extension in Rails, or PORO [Dry::Validation][dry-validation]. All of them focuse on providing rich DSL-s for **validation rules**.

**Tram::Policy** follows another approach -- it uses simple Ruby methods for validation, but focuses on building both *customiseable* and *composable* results of validation, namely their errors.

- By **customiseable** we mean adding any number of *tags* to validation error -- to allow filtering and sorting validation results.
- By **composable** we mean a possibility to merge errors, provided by one policy/validator to another, for building nested sets of well-focused policies.

Keeping this reasons in mind, lets go to some examples.

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
  validate :text_presence

  private

  def title_presence
    return unless title.empty?
    # Adds an error with a message and a set of additional tags
    # You can use any tags, not only an attribute/field like in ActiveModel
    errors.add "Title is empty", field: "title", level: "error"
  end

  def subtitle_presence
    return unless subtitle.empty?
    # Notice that we can set another level
    errors.add "Subtitle is empty", field: "subtitle", level: "warning"
  end

  def text_presence
    return unless title.empty?
    # Adds an error with a translated message. All fields are available
    # both as error tags, and I18n translation options
    errors.add :empty_subtitle, field: "text", level: "error"
  end
end
```

Because a policy is responsible for validation only, we don't need to call validation explicitly. All validations are made by its initializer immediately; the results are memoized in array of its `errors`. The methods `#valid?`, `#invalid?` and `#validate!` just check those `#errors`.

You can treat an instance of policy object as immutable.

```ruby
article = Article.new title: "A wonderful article", subtitle: "", text: ""
policy  = Article::ReadinessPolicy[article] # syntax sugar for constructor `new`

# Simple checks
policy.errors.any? # => true
policy.valid?      # => false
policy.invalid?    # => true
policy.validate!   # raises Tram::Policy::ValidationError

# Look at errors closer
policy.errors.count # => 2 (no subtitle, no text)
policy.errors.filter { |error| error.tags[:field] == "error" }.count # => 1
policy.errors.filter { |error| error.level == "error" }.count # => 1

# Error messages are already added under special key :message
policy.errors.map(&:message) # => ["Subtitle is empty", "Error translation for missed text"]

# A shortcut
policy.messages # => ["Subtitle is empty", "Error translation for missed text"]

# More verbose strings
policy.full_messages
# => [
#      'Subtitle is empty: {"field":"subtitle", "level":"warning"}'
#      'Error translation for missed text: {"field":"text", "level":"error"}'
#    ]

# You can use tags in checkers -- to add condition for errors to ignore
policy.valid? { |error| !%w(warning error).include? error.level } # => false
policy.valid? { |error| error.level != "disaster" }               # => true

# Notice the `invalid` takes a block with definitions for errors to count (not ignore)
policy.invalid? { |error| %w(warning error).include? error.level } # => true
policy.invalid? { |error| error.level == "disaster" }              # => false

policy.validate! { |errro| error.level != "disaster" } # => nil (seems ok)
```

You can use reach errors in policy composition:

```ruby
class Article::PublicationPolicy < Tram::Policy
  param  :article
  option :selected, proc { |value| !!value } # enforce booleans

  validate :article_readiness
  validate :article_selection

  private

  def article_readiness
    # Collects errors except warnings from "nested" policy
    Article::ReadinessPolicy[article].errors.each do |err|
      next if err.level == "warning"
      errors.add err.to_h.merge { field: "article[#{err.field}]" }
    end
  end

  def article_selection
    errors.add "Not selected", field: "selected", level: "info" unless selected
  end
end
```

As mentioned above, sending a symbolic key to the `errors#add` means the key should be translated by [I18n][i18n]. The only magic under the hood is that a scope for the translation is taken from the full name of current class. All tags are available as options:

```ruby
class Article::PublicationPolicy < Tram::Policy
  # ...
  errors.add :empty_text, field: "text", level: "error"
  # ...
end
```

```yaml
# /config/locales/en.yml
---
en:
  article/publication_policy:
    empty_text: "Validation %{level}: %{field} is empty"
```

This will provide error message "Validation error: text is empty".

The last thing to say is about exceptions. When you use `validate!` it raises an exception of `Tram::Policy::ValidationError` (subclass of `RuntimeError`). Its message is built from selected errors (taking into account a `validation!` filter).

The exception also carries back reference to the `policy` that raised it. You can use it to extract either errors, or arguments of the policy during a debagging:

```ruby
begin
  policy.validate!
rescue Tram::Policy::ValidationError => error
  error.policy == policy # => true
end
```

## Generators

The gem provides simple tool for scaffolding new policy along with RSpec specification. You

```shell
$ tram-policy user/readiness_policy user user:name user:emain
```

This will generate a corresponding class

```ruby
# app/policies/user/readiness_policy.rb
class User::ReadinessPolicy < Tram::Policy
  param  :user
  option :name,  default: -> { user.name }
  option :email, default: -> { user.email }
end
```

and a specification, compatible to both [RSpec][rspec] and [FactoryGirl][factory-girl]:

```ruby
# spec/policies/user/readiness_policy_spec.rb
RSpec.describe User::ReadinessPolicy do
  let(:user)   { build :user } # <- expected a factory
  subject(:policy) { described_class[user] }

  it { is_expected.to be_valid }

  context "with wrong name" do
    before { user.name = nil }
    it { is_expected.to be_invalid_at field: "name" }
  end

  context "with wrong name" do
    before { user.email = nil }
    it { is_expected.to be_invalid_at field: "email" }
  end
end
```

Later you can copy-paste that contexts to provide more edge case for testing your policies.

Notice that RSpec matcher `be_invalid_at` checks at once:

- that an error is added to the policy
- that the error has given tags
- that the error is translated to every available locale

and provides full description for the essence of the failure.

## To Recap

The `Tram::Policy` DSL provides the following methods:

* `.param` and `.option` - class-level methods for policy constructor arguments
* `.validate` - class-level method to add validators (they will be invoked in the same order as defined)
* `.[]` - a syntax sugar for `.new`

* `#errors` - returns an enumerable collection of validation errors
* `#valid?` - checks whether no errors exist
* `#invalid?` - checks whether some error exists
* `#validate!` - raises if some error exist

Enumerable collection of unique policy `errors` (`Tram::Policy::Errors`) responds to methods:

* `add` - adds an error to the collection
* `each` - iterates by the set of errors (support other methods of enumerables)
* `messages` - returns an array of messages
* `full_messages` - returns an array of messages with tags info added (used in exception)

Every instance of `Tram::Policy::Error` supports:

* `#tags` - hash of assigned tags
* `#message` - the translated message
* `#full_message` - the message with tags info added
* `#to_h` - hash of tags and a message
* `#==` - checks whether an error is equal to another one
* undefined methods treated as tags

The instance of `Tram::Policy::ValidationError` responds to:

* `policy` - returns a policy object that raised an exception
* other methods defined by the `RuntimeError` class

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
[factory-girl]: https://github.com/thoughtbot/factory_girl
