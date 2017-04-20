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

Policy objects are responsible for context-related validation of objects, or mixes of objects. Here **context-related** means a validation doesn't check whether an object is valid by itself, but whether it is valid for some purpose (context). For example, we could ask if some article is ready (valid) to be published, etc.

There are several well-known interfaces exist for validation like [ActiveModel::Validations][active-model-validation], or its [ActiveRecord][active-record-validation] extension in Rails, or PORO [Dry::Validation][dry-validation]. All of them focus on providing rich DSL-s for **validation rules**.

**Tram::Policy** follows another approach -- it uses simple Ruby methods for validation, but focuses on building both *customizable* and *composable* results of validation, namely their errors.

- By **customizable** we mean adding any number of *tags* to validation error -- to allow filtering and sorting validation results.
- By **composable** we mean a possibility to merge errors provided by one policy/validator to another, for building nested sets of well-focused policies.

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
    return unless text.empty?
    # Adds an error with a translated message. All fields are available
    # both as error tags, and I18n translation options
    errors.add :empty_text, field: "text", level: "error"
  end
end
```

Because validation is the only responsibility of a policy, we don't need to call it explicitly. Policy initializer will perform all the checks immediately, memoizing the results into `errors` array. The methods `#valid?`, `#invalid?` and `#validate!` just check those `#errors`.

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
policy.errors.filter { |error| error.tags[:level] == "error" }.count # => 1
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

policy.validate! { |error| error.level != "disaster" } # => nil (seems ok)
```

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
    others = Article::ReadinessPolicy[article].errors.by_tags(level: "error")

    # Merges collected errors to the current ones.
    # New errors are tagged by source: "readiness".
    # Notice the block takes _hashified_ errors.
    errors.merge(others) { |hash| hash[:source] = "readiness" }
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

The last thing to say is about exceptions. When you use `validate!` it raises `Tram::Policy::ValidationError` (subclass of `RuntimeError`). Its message is built from selected errors (taking into account a `validation!` filter).

The exception also carries a backreference to the `policy` that raised it. You can use it to extract either errors, or arguments of the policy during a debugging:

```ruby
begin
  policy.validate!
rescue Tram::Policy::ValidationError => error
  error.policy == policy # => true
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
  let(:user) { build :user } # <- expected a factory

  subject(:policy) { described_class[email: "user@example.com"] }

  it "is invalid with 'error' level" do
    expect { policy }.to be_invalid_at level: "error"
  end

  it "is not invalid with 'info' level" do
    expect { policy }.not_to be_invalid_at level: "info"
  end
end
```

**Notice** that you have to wrap policy into block `{ policy }`. This is because the matcher checks not only presence of an error, but also ensures its message is translated to all available locales (`I18n.available_locales`). The block containing a policy will be executed separately for every such language.

## Generators

The gem provides simple tool for scaffolding new policy along with RSpec test template.

```shell
$ tram-policy user/readiness_policy -p user -o admin -v name_present:blank_name email_present:blank_email
```

This will generate a policy class with specification compatible to both [RSpec][rspec] and [FactoryGirl][factory-girl]:


```ruby
# app/policies/user/readiness_policy.rb

# TODO: describe the policy, its subject and context
class User::ReadinessPolicy < Tram::Policy
  # TODO: add default values     (default: -> { ... }),
  #       coercers               (type: proc(&:to_s)),
  #       and optional arguments (optional: true)
  #       when necessary
  param  :user
  option :admin

  validate :name_present
  validate :email_present

  private

  def name_present
    # TODO: define a condition
    return if true
    # TODO: add necessary tags
    errors.add :blank_name
  end

  def email_present
    # TODO: define a condition
    return if true
    # TODO: add necessary tags
    errors.add :blank_email
  end
end
```

```yaml
# config/tram-policies.en.yml
---
en:
  user/readiness_policy:
    blank_name: translation missing
    blank_email: translation missing
```

```ruby
# spec/policies/user/readiness_policy_spec.rb
require "spec_helper"
# TODO: move it to spec_helper
require "tram/policy/rspec"

RSpec.describe User::ReadinessPolicy, ".[]" do
  # TODO: either remove this line, or set another source for locales to check
  let(:available_locales) { I18n.available_locales }
  let(:user) { FactoryGirl.build :user }

  it "is valid with proper arguments" do
    expect { described_class[user] }.to be_valid
  end

  # TODO: check the description
  it "is invalid when not name_present" do
    # TODO: modify some arguments
    user = nil
    # TODO: add necessary tags to focus the condition
    expect { described_class[user] }.to be_invalid_at
  end

  # TODO: check the description
  it "is invalid when not email_present" do
    # TODO: modify some arguments
    user = nil
    # TODO: add necessary tags to focus the condition
    expect { described_class[user] }.to be_invalid_at
  end
end
```

Then you should go through all TODO-s and add necessary details.

Later you can copy-paste examples to provide more edge case for testing your policies.

Notice that RSpec matcher `be_invalid_at` checks at once:

- that an error is added to the policy
- that the error has given tags
- that the error is translated to every available locale

Its negation (`not_to be_invalid_at`) checks that no errors added with given tags.
When called without tags, it checks that the policy is valid as a whole.

Both matchers provide a full description for the essence of the failure.

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
* `empty?` - checks whether a collection is emtpy (in addition to enumerable interface)
* `by_tags` - filters errors that have given tags
* `messages` - returns an array of messages
* `full_messages` - returns an array of messages with tags info added (used in exception)
* `merge` - merges a collection to another one

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
