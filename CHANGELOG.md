# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.2] - [WIP]

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

  ```
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
