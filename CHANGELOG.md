# Changelog
All notable changes to this project will be documented in this file.

The format (since v2) is based on [Keep a Changelog v1](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2022-06-22
### Added
- Documentation improvements (@pboling)
- Increased test coverage to 99% (@pboling)

## [2.0.0] - 2022-06-21
### Added
- [#158](https://github.com/oauth-xx/oauth2/pull/158), [#344](https://github.com/oauth-xx/oauth2/pull/344) - Optionally pass raw response to parsers (@niels)
- [#190](https://github.com/oauth-xx/oauth2/pull/190), [#332](https://github.com/oauth-xx/oauth2/pull/332), [#334](https://github.com/oauth-xx/oauth2/pull/334), [#335](https://github.com/oauth-xx/oauth2/pull/335), [#360](https://github.com/oauth-xx/oauth2/pull/360), [#426](https://github.com/oauth-xx/oauth2/pull/426), [#427](https://github.com/oauth-xx/oauth2/pull/427), [#461](https://github.com/oauth-xx/oauth2/pull/461) - Documentation (@josephpage, @pboling, @meganemura, @joshRpowell, @elliotcm)
- [#220](https://github.com/oauth-xx/oauth2/pull/220) - Support IETF rfc7523 JWT Bearer Tokens Draft 04+ (@jhmoore)
- [#298](https://github.com/oauth-xx/oauth2/pull/298) - Set the response object on the access token on Client#get_token for debugging (@cpetschnig)
- [#305](https://github.com/oauth-xx/oauth2/pull/305) - Option: `OAuth2::Client#get_token` - `:access_token_class` (`AccessToken`); user specified class to use for all calls to `get_token` (@styd)
- [#346](https://github.com/oauth-xx/oauth2/pull/571) - Modern gem structure (@pboling)
- [#351](https://github.com/oauth-xx/oauth2/pull/351) - Support Jruby 9k (@pboling)
- [#362](https://github.com/oauth-xx/oauth2/pull/362) - Support SemVer release version scheme (@pboling)
- [#363](https://github.com/oauth-xx/oauth2/pull/363) - New method `OAuth2::AccessToken#refresh!` same as old `refresh`, with backwards compatibility alias (@pboling)
- [#364](https://github.com/oauth-xx/oauth2/pull/364) - Support `application/hal+json` format (@pboling)
- [#365](https://github.com/oauth-xx/oauth2/pull/365) - Support `application/vnd.collection+json` format (@pboling)
- [#376](https://github.com/oauth-xx/oauth2/pull/376) - _Documentation_: Example / Test for Google 2-legged JWT (@jhmoore)
- [#381](https://github.com/oauth-xx/oauth2/pull/381) - Spec for extra header params on client credentials (@nikz)
- [#394](https://github.com/oauth-xx/oauth2/pull/394) - Option: `OAuth2::AccessToken#initialize` - `:expires_latency` (`nil`); number of seconds by which AccessToken validity will be reduced to offset latency (@klippx)
- [#412](https://github.com/oauth-xx/oauth2/pull/412) - Support `application/vdn.api+json` format (from jsonapi.org) (@david-christensen)
- [#413](https://github.com/oauth-xx/oauth2/pull/413) - _Documentation_: License scan and report (@meganemura)
- [#442](https://github.com/oauth-xx/oauth2/pull/442) - Option: `OAuth2::Client#initialize` - `:logger` (`::Logger.new($stdout)`) logger to use when OAUTH_DEBUG is enabled (for parity with `1-4-stable` branch) (@rthbound)
- [#494](https://github.com/oauth-xx/oauth2/pull/494) - Support [OIDC 1.0 Private Key JWT](https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication); based on the OAuth JWT assertion specification [(RFC 7523)](https://tools.ietf.org/html/rfc7523) (@SteveyblamWork)
- [#549](https://github.com/oauth-xx/oauth2/pull/549) - Wrap `Faraday::ConnectionFailed` in `OAuth2::ConnectionFailed` (@nikkypx)
- [#550](https://github.com/oauth-xx/oauth2/pull/550) - Raise error if location header not present when redirecting (@stanhu)
- [#552](https://github.com/oauth-xx/oauth2/pull/552) - Add missing `version.rb` require (@ahorek)
- [#553](https://github.com/oauth-xx/oauth2/pull/553) - Support `application/problem+json` format (@janz93)
- [#560](https://github.com/oauth-xx/oauth2/pull/560) - Support IETF rfc6749, section 2.3.1 - don't set auth params when `nil` (@bouk)
- [#571](https://github.com/oauth-xx/oauth2/pull/571) - Support Ruby 3.1 (@pboling)
- [#575](https://github.com/oauth-xx/oauth2/pull/575) - Support IETF rfc7231, section 7.1.2 - relative location in redirect (@pboling)
- [#581](https://github.com/oauth-xx/oauth2/pull/581) - _Documentation_: of breaking changes (@pboling)
### Changed
- [#191](https://github.com/oauth-xx/oauth2/pull/191) - **BREAKING**: Token is expired if `expired_at` time is `now` (@davestevens)
- [#312](https://github.com/oauth-xx/oauth2/pull/312) - **BREAKING**: Set `:basic_auth` as default for `:auth_scheme` instead of `:request_body`. This was default behavior before 1.3.0. (@tetsuya, @wy193777)
- [#317](https://github.com/oauth-xx/oauth2/pull/317) - _Dependency_: Upgrade `jwt` to 2.x.x (@travisofthenorth)
- [#338](https://github.com/oauth-xx/oauth2/pull/338) - _Dependency_: Switch from `Rack::Utils.escape` to `CGI.escape` (@josephpage)
- [#339](https://github.com/oauth-xx/oauth2/pull/339), [#368](https://github.com/oauth-xx/oauth2/pull/368), [#424](https://github.com/oauth-xx/oauth2/pull/424), [#479](https://github.com/oauth-xx/oauth2/pull/479), [#493](https://github.com/oauth-xx/oauth2/pull/493), [#539](https://github.com/oauth-xx/oauth2/pull/539), [#542](https://github.com/oauth-xx/oauth2/pull/542), [#553](https://github.com/oauth-xx/oauth2/pull/553) - CI Updates, code coverage, linting, spelling, type fixes, New VERSION constant (@pboling, @josephpage, @ahorek)
- [#410](https://github.com/oauth-xx/oauth2/pull/410) - **BREAKING**: Removed the ability to call .error from an OAuth2::Response object (@jhmoore)
- [#414](https://github.com/oauth-xx/oauth2/pull/414) - Use Base64.strict_encode64 instead of custom internal logic (@meganemura)
- [#489](https://github.com/oauth-xx/oauth2/pull/489) - **BREAKING**: Default value for option `OAuth2::Client` - `:authorize_url` removed leading slash to work with relative paths by default (`'oauth/authorize'`) (@ghost)
- [#489](https://github.com/oauth-xx/oauth2/pull/489) - **BREAKING**: Default value for option `OAuth2::Client` - `:token_url` removed leading slash to work with relative paths by default (`'oauth/token'`) (@ghost)
- [#576](https://github.com/oauth-xx/oauth2/pull/576) - **BREAKING**: Stop rescuing parsing errors (@pboling)
- [#591](https://github.com/oauth-xx/oauth2/pull/576) - _DEPRECATION_: `OAuth2::Client` - `:extract_access_token` option is deprecated
### Fixed
- [#158](https://github.com/oauth-xx/oauth2/pull/158), [#344](https://github.com/oauth-xx/oauth2/pull/344) - Handling of errors when using `omniauth-facebook` (@niels)
- [#294](https://github.com/oauth-xx/oauth2/pull/294) - Fix: "Unexpected middleware set" issue with Faraday when `OAUTH_DEBUG=true` (@spectator, @gafrom)
- [#300](https://github.com/oauth-xx/oauth2/pull/300) - _Documentation_: `Oauth2::Error` - Error codes are strings, not symbols (@NobodysNightmare)
- [#318](https://github.com/oauth-xx/oauth2/pull/318), [#326](https://github.com/oauth-xx/oauth2/pull/326), [#343](https://github.com/oauth-xx/oauth2/pull/343), [#347](https://github.com/oauth-xx/oauth2/pull/347), [#397](https://github.com/oauth-xx/oauth2/pull/397), [#464](https://github.com/oauth-xx/oauth2/pull/464), [#561](https://github.com/oauth-xx/oauth2/pull/561), [#565](https://github.com/oauth-xx/oauth2/pull/565) - _Dependency_: Support all versions of `faraday` (see [gemfiles/README.md][gemfiles/readme] for compatibility matrix with Ruby engines & versions) (@pboling, @raimondasv, @zacharywelch, @Fudoshiki, @ryogift, @sj26, @jdelStrother)
- [#322](https://github.com/oauth-xx/oauth2/pull/322), [#331](https://github.com/oauth-xx/oauth2/pull/331), [#337](https://github.com/oauth-xx/oauth2/pull/337), [#361](https://github.com/oauth-xx/oauth2/pull/361), [#371](https://github.com/oauth-xx/oauth2/pull/371), [#377](https://github.com/oauth-xx/oauth2/pull/377), [#383](https://github.com/oauth-xx/oauth2/pull/383), [#392](https://github.com/oauth-xx/oauth2/pull/392), [#395](https://github.com/oauth-xx/oauth2/pull/395), [#400](https://github.com/oauth-xx/oauth2/pull/400), [#401](https://github.com/oauth-xx/oauth2/pull/401), [#403](https://github.com/oauth-xx/oauth2/pull/403), [#415](https://github.com/oauth-xx/oauth2/pull/415), [#567](https://github.com/oauth-xx/oauth2/pull/567) - Updated Rubocop, Rubocop plugins and improved code style (@pboling, @bquorning, @lautis, @spectator)
- [#328](https://github.com/oauth-xx/oauth2/pull/328) - _Documentation_: Homepage URL is SSL (@amatsuda)
- [#339](https://github.com/oauth-xx/oauth2/pull/339), [#479](https://github.com/oauth-xx/oauth2/pull/479) - Update testing infrastructure for all supported Rubies (@pboling and @josephpage)
- [#366](https://github.com/oauth-xx/oauth2/pull/366) - **Security**: Fix logging to `$stdout` of request and response bodies via Faraday's logger and `ENV["OAUTH_DEBUG"] == 'true'` (@pboling)
- [#380](https://github.com/oauth-xx/oauth2/pull/380) - Fix: Stop attempting to encode non-encodable objects in `Oauth2::Error` (@jhmoore)
- [#399](https://github.com/oauth-xx/oauth2/pull/399) - Fix: Stop duplicating `redirect_uri` in `get_token` (@markus)
- [#410](https://github.com/oauth-xx/oauth2/pull/410) - Fix: `SystemStackError` caused by circular reference between Error and Response classes (@jhmoore)
- [#460](https://github.com/oauth-xx/oauth2/pull/460) - Fix: Stop throwing errors when `raise_errors` is set to `false`; analog of [#524](https://github.com/oauth-xx/oauth2/pull/524) for `1-4-stable` branch (@joaolrpaulo)
- [#472](https://github.com/oauth-xx/oauth2/pull/472) - **Security**: Add checks to enforce `client_secret` is *never* passed in authorize_url query params for `implicit` and `auth_code` grant types (@dfockler)
- [#482](https://github.com/oauth-xx/oauth2/pull/482) - _Documentation_: Update last of `intridea` links to `oauth-xx` (@pboling)
- [#536](https://github.com/oauth-xx/oauth2/pull/536) - **Security**: Compatibility with more (and recent) Ruby OpenSSL versions, Github Actions, Rubocop updated, analogous to [#535](https://github.com/oauth-xx/oauth2/pull/535) on `1-4-stable` branch (@pboling)
- [#595](https://github.com/oauth-xx/oauth2/pull/595) - Graceful handling of empty responses from `Client#get_token`, respecting `:raise_errors` config (@stanhu)
- [#596](https://github.com/oauth-xx/oauth2/pull/596) - Consistency between `AccessToken#refresh` and `Client#get_token` named arguments (@stanhu)
- [#598](https://github.com/oauth-xx/oauth2/pull/598) - Fix unparseable data not raised as error in `Client#get_token`, respecting `:raise_errors` config (@stanhu)
### Removed
- [#341](https://github.com/oauth-xx/oauth2/pull/341) - Remove Rdoc & Jeweler related files (@josephpage)
- [#342](https://github.com/oauth-xx/oauth2/pull/342) - **BREAKING**: Dropped support for Ruby 1.8 (@josephpage)
- [#539](https://github.com/oauth-xx/oauth2/pull/539) - Remove reliance on globally included OAuth2 in tests, analog of [#538](https://github.com/oauth-xx/oauth2/pull/538) for 1-4-stable (@anderscarling)
- [#566](https://github.com/oauth-xx/oauth2/pull/566) - _Dependency_: Removed `wwtd` (@bquorning)
- [#589](https://github.com/oauth-xx/oauth2/pull/589), [#593](https://github.com/oauth-xx/oauth2/pull/593) - Remove support for expired MAC token draft spec (@stanhu)
- [#590](https://github.com/oauth-xx/oauth2/pull/590) - _Dependency_: Removed `multi_json` (@stanhu)

## [1.4.9] - 2022-02-20
- Fixes compatibility with Faraday v2 [572](https://github.com/oauth-xx/oauth2/issues/572)
- Includes supported versions of Faraday in test matrix:
  - Faraday ~> 2.2.0 with Ruby >= 2.6
  - Faraday ~> 1.10 with Ruby >= 2.4
  - Faraday ~> 0.17.3 with Ruby >= 1.9
- Add Windows and MacOS to test matrix

## [1.4.8] - 2022-02-18
- MFA is now required to push new gem versions (@pboling)
- README overhaul w/ new Ruby Verion and Engine compatibility policies (@pboling)
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
- [#538](https://github.com/oauth-xx/oauth2/pull/538) - Remove reliance on globally included OAuth2 in tests, analogous to [#539](https://github.com/oauth-xx/oauth2/pull/539) on master branch (@anderscarling)

## [1.4.5] - 2021-03-18
- [#535](https://github.com/oauth-xx/oauth2/pull/535) - Compatibility with range of supported Ruby OpenSSL versions, Rubocop updates, Github Actions, analogous to [#536](https://github.com/oauth-xx/oauth2/pull/536) on master branch (@pboling)
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
  - Officially support Ruby 2.6 and truffleruby

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

[Unreleased]: https://github.com/oauth-xx/oauth2/compare/v2.0.0...HEAD
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
[2.0.0]: https://github.com/oauth-xx/oauth2/compare/v1.4.9...v2.0.0
[2.0.1]: https://github.com/oauth-xx/oauth2/compare/v2.0.0...v2.0.1
[gemfiles/readme]: gemfiles/README.md
