# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.0.1] - [2019-11-14]

### Fixed
- Allow translation :scope to be customized in the #merge operation (sclinede)
  Before the fix, the customized value was always replaced by the default value.

## [2.0.0] - [2019-07-04]

### Changed

- [BREAKING] separate `Tram::Policy::Errors` from a policy (nepalez, sclinede)
  
  Instead of the policy, the collection refers to the explicit scope used for error messages' translation.
  This change breaks the signature of `Tram::Policy::Error` and `Tram::Policy::Errors`.

## [1.0.1] - [2019-05-06]

### Added
- Support of `dry-initializer` v3.0+ (nepalez)

### Fixed
- Fix be_invalid RSpec matcher if non-policy model is passed (Envek)
- Disable translation check for non-strings in rspec matcher (Envek)

## [1.0.0] - [2018-02-17]

### Changed
- RSpec matchers does't use blocks any more (nepalez)

  Instead of

  ```ruby
  expect { policy }.to be_invalid_at level: "error"
  ```

  use the simpler syntax

  ```ruby
  expect(policy).to be_invalid_at level: "error"
  ```

### Deleted
- Deprecated methods (nepalez)
- RSpec shared examples (nepalez)

## [0.4.0] - [2018-02-17]

This is beta-release before the first stable version 1.0.0.

It adds methods `#item` and `#items` to policy errors to support lazy translation.

It also renames some methods, and deprecate others that will be removed from v1.0.0.

### Added
- `Tram::Policy.root_scope` changes the default root scope ("tram-policy") for I18n (nepalez)
- `Tram::Policy::Error#item` returns an array of [key, tags] which can be sent to I18n.t later (nepalez)
- `Tram::Policy::Error#to_a` as an alias for the `#item` (nepalez)
- `Tram::Policy::Errors#items` returns an array of error items (nepalez)
- `Tram::Policy::Errors#filter` acts like `by_tag` but returns the filtered collection instead of an array (nepalez)
- `Tram::Policy#messages` as a shortcut for `errors.messages` (nepalez)
- `Tram::Policy#items` as a shortcut for `errors.items` (nepalez)

### Changed
- errors are compared by `#to_a` instead of `#to_h` (nepalez)

### Deprecated
- `Tram::Policy::Error#full_message` (nepalez)
- `Tram::Policy::Error#to_h` (nepalez)
- `Tram::Policy::Errors#full_messages` (nepalez)
- `Tram::Policy::Errors#by_tags` (nepalez)

## [0.3.1] - [2018-01-05]

### Fixed
- Convertion of block into lambda in `validate` (nepalez)

## [0.3.0] - [2018-01-05]

### Added
- Allow returning from block in `validate` by using lambdas (nepalez)

## [0.2.5] - [2018-01-05]

### Added
- Allow `Tram::Policy.scope` to be made private (nepalez)

## [0.2.4] - [2017-12-03]

Some private methods has been refactored

## Internals
- Renamed `Tram::Policy@__options__` -> `Tram::Policy##__attributes__` (nepalez)
- Removed `Tram::Policy::Validator##scope` in favor of `Tram::Policy.scope` (nepalez)
- Refactored spec matcher (nepalez)

## [0.2.3] - [2017-11-21]

### Fixed
- RSpec matcher `:be_invalid_at` checks all the available locales (nepalez)
- Security vulnerability from old version of rubocop (update to 0.49) (nepalez)

## [0.2.2] - [2017-09-12]

### Changed
- Policy class methods `all`, `local`, and `scope` was made public (nepalez)

## [0.2.1] - [2017-08-28]

### Changed
- Updated dependency from [dry-initializer] to v2.0.0 (nepalez)

## [0.2.0] - [2017-08-19]

### Added
- Support for unnamed block validators (@nepalez)

  In addition to instance methods:

    validate :some_method

  You can use a block for validation:

    validate { errors.add :blank_name if name.blank? }

- Support for custom scopes (@nepalez)

  Just reload private class method `scope`

- Support for inheritance (@nepalez)

  You can inherit the policy class. A subclass will apply all validators of
  superclass before those of its own. Every error message will be translated
  in the scope of policy where it was defined.

### Deleted
- Reloading of validators

  To follow Liskov substitube principle we run all validators declared anywhere
  in the policy or its superclasses. Any sub-policy should provide the same
  level of confidence about validity of object(s) under check as any
  of its superclasses.

## [0.1.1] - [2017-08-04]

### Added
- Support for options in errors.merge (@nepalez)

    # adds `field: "user"` to every merged error
    errors.merge other_policy.errors, field: "user"

## [0.1.0] - [2017-05-31]
Contains backward-incompatible change.

### Migration
You should add the namespace to gem-related I18n translations.

```yaml
# config/locales/tram-policy.en.yml
---
en:
  tram-policy: # The namespace to be added
    my_policy:
      error_key: Error message
```

### Changed
- [BREAKING] a namespace added to scopes for policy error translations (@nepalez)

## [0.0.3] - [2017-05-24]

### Fixed
- bug in `errors.empty?` with a block (@nepalez with thanks to @gzigzigzeo)

## [0.0.2] - [2017-04-25]
The gem is battle-tested for production (in a real commertial project).

### Removed
- `.validate` with several keys for several validators at once (@nepalez)

  Use a multiline version instead of `validate :foo, :bar`:

  ```ruby
  validate :foo
  validate :bar
  ```

### Added
- `.validate` supports option `stop_on_failure` (@nepalez)

### Fixed
- Minor bugs in generators (@nepalez)

## [0.0.1] - [2017-04-18]
This is a first public release (@nepalez, @charlie-wasp, @JewelSam, @sergey-chechaev)

[dry-initializer]: https://github.com/dry-rb/dry-initializer
[Unreleased]: https://github.com/tram-rb/tram-policy
[0.0.1]: https://github.com/tram-rb/tram-policy/releases/tag/v0.0.1
[0.0.2]: https://github.com/tram-rb/tram-policy/compare/v0.0.1...v0.0.2
[0.0.3]: https://github.com/tram-rb/tram-policy/compare/v0.0.2...v0.0.3
[0.1.0]: https://github.com/tram-rb/tram-policy/compare/v0.0.3...v0.1.0
[0.1.1]: https://github.com/tram-rb/tram-policy/compare/v0.1.0...v0.1.1
[0.2.0]: https://github.com/tram-rb/tram-policy/compare/v0.1.1...v0.2.0
[0.2.1]: https://github.com/tram-rb/tram-policy/compare/v0.2.0...v0.2.1
[0.2.2]: https://github.com/tram-rb/tram-policy/compare/v0.2.1...v0.2.2
[0.2.3]: https://github.com/tram-rb/tram-policy/compare/v0.2.2...v0.2.3
[0.2.4]: https://github.com/tram-rb/tram-policy/compare/v0.2.3...v0.2.4
[0.2.5]: https://github.com/tram-rb/tram-policy/compare/v0.2.4...v0.2.5
[0.3.0]: https://github.com/tram-rb/tram-policy/compare/v0.2.5...v0.3.0
[0.3.1]: https://github.com/tram-rb/tram-policy/compare/v0.3.0...v0.3.1
[0.4.0]: https://github.com/tram-rb/tram-policy/compare/v0.3.1...v0.4.0
[1.0.0]: https://github.com/tram-rb/tram-policy/compare/v0.4.0...v1.0.0
[1.0.1]: https://github.com/tram-rb/tram-policy/compare/v1.0.0...v1.0.1
[2.0.0]: https://github.com/tram-rb/tram-policy/compare/v1.0.1...v2.0.0
