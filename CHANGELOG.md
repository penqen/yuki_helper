# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][Keep a Changelog] and this project adheres to [Semantic Versioning][Semantic Versioning].

## [Unreleased]

### Added

- added support for escript in order to provide global commands for `mix tasks`
- added support for languages `ruby` and `c++11`
- added a new **mix tasks** `mix yuki.lang.list`
- added CHANGELOG.md

### Changed

- updated config file format (`languages` and `providers`)
- updated to support for options (`--source` and `--lang`) of `mix yuki.test`
- renamed `TargetFileError` to `SourceFileError`
- moved functions of `Problem` into `Config` and `Config.Testcase`
- rename `Test` module to `Language`

### Deprecated

### Removed

### Fixed

### Security

---

## [v0.1.0] - 2021-04-20

### Added

- added support for language `Elixir`
- added support for juadges (`CE` / `AC` / `WA` / `RE`)
- added four **mix tasks** following:
  - `mix yuki.config`
  - `mix yuki.testcase.list`
  - `mix yuki.testcase.download`
  - `mix yuki.test`
- added the example config file `yuki_helper.default.config.yml`.
- added README.md

---

<!-- Links -->
[Keep a Changelog]: https://keepachangelog.com/
[Semantic Versioning]: https://semver.org/

<!-- Versions -->
[Unreleased]: https://github.com/Author/Repository/compare/v1.0.0...HEAD
[Released]: https://github.com/Author/Repository/releases
[0.0.2]: https://github.com/Author/Repository/compare/v0.0.1..v0.0.2
[0.0.1]: https://github.com/Author/Repository/releases/v0.0.1
