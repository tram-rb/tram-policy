# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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

[Unreleased]: https://github.com/tram-rb/tram-policy
[0.0.1]: https://github.com/tram-rb/tram-policy/releases/tag/v0.0.1
[0.0.2]: https://github.com/tram-rb/tram-policy/compare/v0.0.1...v0.0.2
[0.0.3]: https://github.com/tram-rb/tram-policy/compare/v0.0.2...v0.0.3