# Change Log
All notable changes to this project will be documented in this file.

## [unreleased]

- **Breaking**: Set `:basic_auth` as default for `:auth_scheme` instead of `:request_body`. This was default behavior before 1.3.0. See [#285](oauth-xx/oauth2#285) (@tetsuya, @wy193777)
- Token is expired if `expired_at` time is now (@davestevens)
- Set the response object on the access token on Client#get_token (@cpetschnig)
- Fix "Unexpected middleware set" issue with Faraday when `OAUTH_DEBUG=true` (@spectator, @gafrom)
- Oauth2::Error : Error codes are strings instead of symbols (@NobodysNightmare)
- _Dependency_: Upgrade Faraday to 0.13.x (@zacharywelch)
- _Dependency_: Upgrade jwt to 2.x.x (@travisofthenorth)

## [1.4.0] - 2017-06-09

- Drop Ruby 1.8.7 support (@sferik)
- Fix some RuboCop offenses (@sferik)
- _Dependency_: Remove Yardstick (@sferik)
- _Dependency_: Upgrade Faraday to 0.12 (@sferik)

## [1.3.1] - 2017-03-03

- Add support for Ruby 2.4.0 (@pschambacher)
- _Dependency_: Upgrade Faraday to Faraday 0.11 (@mcfiredrill, @rhymes, @pschambacher)

## [1.3.0] - 2016-12-28

- Add support for header-based authentication to the `Client` so it can be used across the library (@bjeanes)
- Default to header-based authentication when getting a token from an authorisation code (@maletor)
- **Breaking**: Allow an `auth_scheme` (`:basic_auth` or `:request_body`) to be set on the client, defaulting to `:request_body` to maintain backwards compatibility (@maletor, @bjeanes)
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

## [0.4.1] - 2011-04-20

## [0.4.0] - 2011-04-20

## [0.3.0] - 2011-04-08

## [0.2.0] - 2011-04-01

## [0.1.1] - 2011-01-12

## [0.1.0] - 2010-10-13

## [0.0.13] + [0.0.12] + [0.0.11] - 2010-08-17

## [0.0.10] - 2010-06-19

## [0.0.9] - 2010-06-18

## [0.0.8] + [0.0.7] - 2010-04-27

## [0.0.6] - 2010-04-25

## [0.0.5] - 2010-04-23

## [0.0.4] + [0.0.3] + [0.0.2] + [0.0.1] - 2010-04-22


[0.0.1]: https://github.com/oauth-xx/oauth2/compare/311d9f4...v0.0.1
[0.0.2]: https://github.com/oauth-xx/oauth2/compare/v0.0.1...v0.0.2
[0.0.3]: https://github.com/oauth-xx/oauth2/compare/v0.0.2...v0.0.3
[0.0.4]: https://github.com/oauth-xx/oauth2/compare/v0.0.3...v0.0.4
[0.0.5]: https://github.com/oauth-xx/oauth2/compare/v0.0.4...v0.0.5
[0.0.6]: https://github.com/oauth-xx/oauth2/compare/v0.0.5...v0.0.6
[0.0.7]: https://github.com/oauth-xx/oauth2/compare/v0.0.6...v0.0.7
[0.0.8]: https://github.com/oauth-xx/oauth2/compare/v0.0.7...v0.0.8
[0.0.9]: https://github.com/oauth-xx/oauth2/compare/v0.0.8...v0.0.9
[0.0.10]: https://github.com/oauth-xx/oauth2/compare/v0.0.9...v0.0.10
[0.0.11]: https://github.com/oauth-xx/oauth2/compare/v0.0.10...v0.0.11
[0.0.12]: https://github.com/oauth-xx/oauth2/compare/v0.0.11...v0.0.12
[0.0.13]: https://github.com/oauth-xx/oauth2/compare/v0.0.12...v0.0.13
[0.1.0]: https://github.com/oauth-xx/oauth2/compare/v0.0.13...v0.1.0
[0.1.1]: https://github.com/oauth-xx/oauth2/compare/v0.1.0...v0.1.1
[0.2.0]: https://github.com/oauth-xx/oauth2/compare/v0.1.1...v0.2.0
[0.3.0]: https://github.com/oauth-xx/oauth2/compare/v0.2.0...v0.3.0
[0.4.0]: https://github.com/oauth-xx/oauth2/compare/v0.3.0...v0.4.0
[0.4.1]: https://github.com/oauth-xx/oauth2/compare/v0.4.0...v0.4.1
[0.5.0]: https://github.com/oauth-xx/oauth2/compare/v0.4.1...v0.5.0
[1.0.0]: https://github.com/oauth-xx/oauth2/compare/v0.9.4...v1.0.0
[1.1.0]: https://github.com/oauth-xx/oauth2/compare/v1.0.0...v1.1.0
[1.2.0]: https://github.com/oauth-xx/oauth2/compare/v1.1.0...v1.2.0
[1.3.0]: https://github.com/oauth-xx/oauth2/compare/v1.2.0...v1.3.0
[1.3.1]: https://github.com/oauth-xx/oauth2/compare/v1.3.0...v1.3.1
[1.4.0]: https://github.com/oauth-xx/oauth2/compare/v1.3.1...v1.4.0
[unreleased]: https://github.com/oauth-xx/oauth2/compare/v1.4.0...HEAD
