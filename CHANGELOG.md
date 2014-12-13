# Change Log
All notable changes to this project will be documented in this file.

## [unreleased]
- No significant changes.

## [1.0.0] - 2014-07-09

### Added
- Add an implementation of the MAC token spec.

### Fixed
- Fix Base64.strict_encode64 incompatibility with Ruby 1.8.7.

## [unreleased]
- No significant changes.

## [0.5.0] - 2011-07-29

### Changed
- [breaking] `oauth_token` renamed to `oauth_bearer`.
- [breaking] `authorize_path` Client option renamed to `authorize_url`.
- [breaking] `access_token_path` Client option renamed to `token_url`.
- [breaking] `access_token_method` Client option renamed to `token_method`.
- [breaking] `web_server` renamed to `auth_code`.

[unreleased]: https://github.com/intridea/oauth2/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/intridea/oauth2/compare/v0.9.4...v1.0.0
[0.5.0]: https://github.com/intridea/oauth2/compare/v0.4.1...v0.5.0
