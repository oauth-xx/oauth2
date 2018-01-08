# Change Log
All notable changes to this project will be documented in this file.

## [unreleased]

- Set the response object on the access token on Client#get_token (@cpetschnig)
- Set `:basic_auth` as default for `:auth_scheme` instead of `:request_body` (@tetsuya)
- Fix "Unexpected middleware set" issue with Faraday when `OAUTH_DEBUG=true` (@spectator)
- _Dependency_: Upgrade Faraday to 0.13.x (@zacharywelch)
- _Dependency_: Upgrade jwt to 2.x.x (@travisofthenorth)

## [1.4.0] - 2017-06-09

- Drop Ruby 1.8.7 support (@sferik)
- Add support for Faraday 0.12 (@sferik)
- Fix some RuboCop offenses (@sferik)
- Remove Yardstick (@sferik)

## [1.3.1] - 2017-03-03

- Add support for Faraday 0.11 (@mcfiredrill, @rhymes, @pschambacher)
- Add support for Ruby 2.4.0 (@pschambacher)

## [1.3.0] - 2016-12-28

- Add support for header-based authentication to the `Client` so it can be used across the library (@bjeanes)
- Default to header-based authentication when getting a token from an authorisation code (@maletor)
- Allow an `auth_scheme` (`:basic_auth` or `:request_body`) to be set on the client, defaulting to `:request_body` to maintain backwards compatibility (@maletor, @bjeanes)
- Handle `redirect_uri` according to the OAuth 2 spec, so it is passed on redirect and at the point of token exchange (@bjeanes)
- Refactor handling of encoding of error responses (@urkle)
- Avoid instantiating an `Error` if there is no error to raise (@urkle)
- Add support for Faraday 0.10 (@rhymes)

## [1.2.0] - 2016-07-01

- Properly handle encoding of error responses (so we don't blow up, for example, when Google's response includes a ∞) (@Motoshi-Nishihira)
- Make a copy of the options hash in `AccessToken#from_hash` to avoid accidental mutations (@Linuus)
- Use `raise` rather than `fail` to throw exceptions (@sferik)

## [1.1.0] - 2016-01-30

- Various refactors (eliminating `Hash#merge!` usage in `AccessToken#refresh!`, use `yield` instead of `#call`, freezing mutable objects in constants, replacing constants with class variables) (@sferik)
- Add support for Rack 2, and bump various other dependencies (@sferik)

## [1.0.0] - 2014-07-09

### Added
- Add an implementation of the MAC token spec.

### Fixed
- Fix Base64.strict_encode64 incompatibility with Ruby 1.8.7.

## [0.5.0] - 2011-07-29

### Changed
- [breaking] `oauth_token` renamed to `oauth_bearer`.
- [breaking] `authorize_path` Client option renamed to `authorize_url`.
- [breaking] `access_token_path` Client option renamed to `token_url`.
- [breaking] `access_token_method` Client option renamed to `token_method`.
- [breaking] `web_server` renamed to `auth_code`.

[0.5.0]: https://github.com/intridea/oauth2/compare/v0.4.1...v0.5.0
[1.0.0]: https://github.com/intridea/oauth2/compare/v0.9.4...v1.0.0
[1.1.0]: https://github.com/intridea/oauth2/compare/v1.0.0...v1.1.0
[1.2.0]: https://github.com/intridea/oauth2/compare/v1.1.0...v1.2.0
[1.3.0]: https://github.com/intridea/oauth2/compare/v1.2.0...v1.3.0
[unreleased]: https://github.com/intridea/oauth2/compare/v1.3.0...HEAD

