# Change Log
All notable changes to this project will be documented in this file.

## unreleased


## [1.4.10] - 2022-07-01

- FIPS Compatibility [#587](https://github.com/oauth-xx/oauth2/pull/587) (@akostadinov)

## [1.4.9] - 2022-02-20

- Fixes compatibility with Faraday v2 [#572](https://github.com/oauth-xx/oauth2/issues/572)
- Includes supported versions of Faraday in test matrix:
  - Faraday ~> 2.2.0 with Ruby >= 2.6
  - Faraday ~> 1.10 with Ruby >= 2.4
  - Faraday ~> 0.17.3 with Ruby >= 1.9
- Add Windows and MacOS to test matrix

## [1.4.8] - 2022-02-18

- MFA is now required to push new gem versions (@pboling)
- README overhaul w/ new Ruby Version and Engine compatibility policies (@pboling)
- [#569](https://github.com/oauth-xx/oauth2/pull/569) Backport fixes ([#561](https://github.com/oauth-xx/oauth2/pull/561) by @ryogift), and add more fixes, to allow faraday 1.x and 2.x (@jrochkind)
- Improve Code Coverage tracking (Coveralls, CodeCov, CodeClimate), and enable branch coverage (@pboling)
- Add CodeQL, Security Policy, Funding info (@pboling)
- Added Ruby 3.1, jruby, jruby-head, truffleruby, truffleruby-head to build matrix (@pboling)
- [#543](https://github.com/oauth-xx/oauth2/pull/543) - Support for more modern Open SSL libraries (@pboling)

## [1.4.7] - 2021-03-19

- [#541](https://github.com/oauth-xx/oauth2/pull/541) - Backport fix to expires_at handling [#533](https://github.com/oauth-xx/oauth2/pull/533) to 1-4-stable branch. (@dobon)

## [1.4.6] - 2021-03-19

- [#540](https://github.com/oauth-xx/oauth2/pull/540) - Add VERSION constant (@pboling)
- [#537](https://github.com/oauth-xx/oauth2/pull/537) - Fix crash in OAuth2::Client#get_token (@anderscarling)
- [#538](https://github.com/oauth-xx/oauth2/pull/538) - Remove reliance on globally included OAuth2 in tests for version 1.4 (@anderscarling)

## [1.4.5] - 2021-03-18

- [#535](https://github.com/oauth-xx/oauth2/pull/535) - Compatibility with range of supported Ruby OpenSSL versions, Rubocop updates, Github Actions (@pboling)
- [#518](https://github.com/oauth-xx/oauth2/pull/518) - Add extract_access_token option to OAuth2::Client (@jonspalmer)
- [#507](https://github.com/oauth-xx/oauth2/pull/507) - Fix camel case content type, response keys (@anvox)
- [#500](https://github.com/oauth-xx/oauth2/pull/500) - Fix YARD documentation formatting (@olleolleolle)

## [1.4.4] - 2020-02-12

- [#408](https://github.com/oauth-xx/oauth2/pull/408) - Fixed expires_at for formatted time (@Lomey)

## [1.4.3] - 2020-01-29

- [#483](https://github.com/oauth-xx/oauth2/pull/483) - add project metadata to gemspec (@orien)
- [#495](https://github.com/oauth-xx/oauth2/pull/495) - support additional types of access token requests (@SteveyblamFreeagent, @thomcorley, @dgholz)
  - Adds support for private_key_jwt and tls_client_auth
- [#433](https://github.com/oauth-xx/oauth2/pull/433) - allow field names with square brackets and numbers in params (@asm256)

## [1.4.2] - 2019-10-01

- [#478](https://github.com/oauth-xx/oauth2/pull/478) - support latest version of faraday & fix build (@pboling)
  - officially support Ruby 2.6 and truffleruby

## [1.4.1] - 2018-10-13

- [#417](https://github.com/oauth-xx/oauth2/pull/417) - update jwt dependency (@thewoolleyman)
- [#419](https://github.com/oauth-xx/oauth2/pull/419) - remove rubocop dependency (temporary, added back in [#423](https://github.com/oauth-xx/oauth2/pull/423)) (@pboling)
- [#418](https://github.com/oauth-xx/oauth2/pull/418) - update faraday dependency (@pboling)
- [#420](https://github.com/oauth-xx/oauth2/pull/420) - update [oauth2.gemspec](https://github.com/oauth-xx/oauth2/blob/1-4-stable/oauth2.gemspec) (@pboling)
- [#421](https://github.com/oauth-xx/oauth2/pull/421) - fix [CHANGELOG.md](https://github.com/oauth-xx/oauth2/blob/1-4-stable/CHANGELOG.md) for previous releases (@pboling)
- [#422](https://github.com/oauth-xx/oauth2/pull/422) - update [LICENSE](https://github.com/oauth-xx/oauth2/blob/1-4-stable/LICENSE) and [README.md](https://github.com/oauth-xx/oauth2/blob/1-4-stable/README.md) (@pboling)
- [#423](https://github.com/oauth-xx/oauth2/pull/423) - update [builds](https://travis-ci.org/oauth-xx/oauth2/builds), [Rakefile](https://github.com/oauth-xx/oauth2/blob/1-4-stable/Rakefile) (@pboling)
  - officially document supported Rubies
    * Ruby 1.9.3
    * Ruby 2.0.0
    * Ruby 2.1
    * Ruby 2.2
    * [JRuby 1.7][jruby-1.7] (targets MRI v1.9)
    * [JRuby 9.0][jruby-9.0] (targets MRI v2.0)
    * Ruby 2.3
    * Ruby 2.4
    * Ruby 2.5
    * [JRuby 9.1][jruby-9.1] (targets MRI v2.3)
    * [JRuby 9.2][jruby-9.2] (targets MRI v2.5)

[jruby-1.7]: https://www.jruby.org/2017/05/11/jruby-1-7-27.html
[jruby-9.0]: https://www.jruby.org/2016/01/26/jruby-9-0-5-0.html
[jruby-9.1]: https://www.jruby.org/2017/05/16/jruby-9-1-9-0.html
[jruby-9.2]: https://www.jruby.org/2018/05/24/jruby-9-2-0-0.html

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
[1.4.1]: https://github.com/oauth-xx/oauth2/compare/v1.4.0...v1.4.1
[1.4.2]: https://github.com/oauth-xx/oauth2/compare/v1.4.1...v1.4.2
[1.4.3]: https://github.com/oauth-xx/oauth2/compare/v1.4.2...v1.4.3
[1.4.4]: https://github.com/oauth-xx/oauth2/compare/v1.4.3...v1.4.4
[1.4.5]: https://github.com/oauth-xx/oauth2/compare/v1.4.4...v1.4.5
[1.4.6]: https://github.com/oauth-xx/oauth2/compare/v1.4.5...v1.4.6
[1.4.7]: https://github.com/oauth-xx/oauth2/compare/v1.4.6...v1.4.7
[1.4.8]: https://github.com/oauth-xx/oauth2/compare/v1.4.7...v1.4.8
[1.4.9]: https://github.com/oauth-xx/oauth2/compare/v1.4.8...v1.4.9
[1.4.10]: https://github.com/oauth-xx/oauth2/compare/v1.4.9...v1.4.10
[unreleased]: https://github.com/oauth-xx/oauth2/compare/v1.4.10...HEAD
