<p align="center">
    <a href="http://oauth.net/2/" target="_blank" rel="noopener noreferrer">
      <img src="https://github.com/oauth-xx/oauth2/raw/master/docs/images/logo/oauth2-logo-124px.png?raw=true" alt="OAuth 2.0 Logo by Chris Messina, CC BY-SA 3.0">
    </a>
    <a href="https://www.ruby-lang.org/" target="_blank" rel="noopener noreferrer">
      <img width="124px" src="https://github.com/oauth-xx/oauth2/raw/master/docs/images/logo/ruby-logo-198px.svg?raw=true" alt="Yukihiro Matsumoto, Ruby Visual Identity Team, CC BY-SA 2.5">
    </a>
</p>

## What

OAuth 2.0 is the industry-standard protocol for authorization.
OAuth 2.0 focuses on client developer simplicity while providing specific authorization flows for web applications,
    desktop applications, mobile phones, and living room devices.
This is a RubyGem for implementing OAuth 2.0 clients and servers in Ruby applications.
See the sibling `oauth` gem for OAuth 1.0 implementations in Ruby.

⚠️ **_WARNING_**: You are viewing the `README` of the soon-to-be-deprecated `1-4-stable`
branch which for version 1.4.x releases. Version 2.0 is coming! ⚠️

---

* [OAuth 2.0 Spec][oauth2-spec]
* [OAuth 1.0 sibling gem][sibling-gem]
* Help us finish release [![2.0.0 release milestone][next-milestone-pct-img]][next-milestone-pct] by submitting or reviewing PRs and issues.
* Oauth2 gem is _always_ looking for additional maintainers. See [#307][maintainers-discussion].

[oauth2-spec]: https://oauth.net/2/
[sibling-gem]: https://github.com/oauth-xx/oauth-ruby
[next-milestone-pct]: https://github.com/oauth-xx/oauth2/milestone/1
[next-milestone-pct-img]: https://img.shields.io/github/milestones/progress-percent/oauth-xx/oauth2/1
[maintainers-discussion]: https://github.com/oauth-xx/oauth2/issues/307

## Release Documentation

<details>
  <summary>1.4.x Readmes</summary>

| Version | Release Date | Readme                                                   |
|---------|--------------|----------------------------------------------------------|
| 1.4.8   | Feb 18, 2022 | https://github.com/oauth-xx/oauth2/blob/v1.4.8/README.md |
| 1.4.7   | Mar 18, 2021 | https://github.com/oauth-xx/oauth2/blob/v1.4.7/README.md |
| 1.4.6   | Mar 18, 2021 | https://github.com/oauth-xx/oauth2/blob/v1.4.6/README.md |
| 1.4.5   | Mar 18, 2021 | https://github.com/oauth-xx/oauth2/blob/v1.4.5/README.md |
| 1.4.4   | Feb 12, 2020 | https://github.com/oauth-xx/oauth2/blob/v1.4.4/README.md |
| 1.4.3   | Jan 29, 2020 | https://github.com/oauth-xx/oauth2/blob/v1.4.3/README.md |
| 1.4.2   | Oct 1, 2019  | https://github.com/oauth-xx/oauth2/blob/v1.4.2/README.md |
| 1.4.1   | Oct 13, 2018 | https://github.com/oauth-xx/oauth2/blob/v1.4.1/README.md |
| 1.4.0   | Jun 9, 2017  | https://github.com/oauth-xx/oauth2/blob/v1.4.0/README.md |
</details>

<details>
  <summary>1.3.x Readmes</summary>

| Version  | Release Date | Readme                                                   |
|----------|--------------|----------------------------------------------------------|
| 1.3.1    | Mar 3, 2017  | https://github.com/oauth-xx/oauth2/blob/v1.3.1/README.md |
| 1.3.0    | Dec 27, 2016 | https://github.com/oauth-xx/oauth2/blob/v1.3.0/README.md |
</details>

<details>
  <summary>&le;= 1.2.x Readmes (2016 and before)</summary>

| Version  | Release Date | Readme                                                   |
|----------|--------------|----------------------------------------------------------|
| 1.2.0    | Jun 30, 2016 | https://github.com/oauth-xx/oauth2/blob/v1.2.0/README.md |
| 1.1.0    | Jan 30, 2016 | https://github.com/oauth-xx/oauth2/blob/v1.1.0/README.md |
| 1.0.0    | May 23, 2014 | https://github.com/oauth-xx/oauth2/blob/v1.0.0/README.md |
| < 1.0.0  | Find here    | https://github.com/oauth-xx/oauth2/tags                  |
</details>

<!--
Numbering rows and badges in each row as a visual "database" lookup,
    as the table is extremely dense, and it can be very difficult to find anything
Putting one on each row here, to document the emoji that should be used, and for ease of copy/paste.

row #s:
1️⃣
2️⃣
3️⃣
4️⃣
5️⃣
6️⃣
7️⃣

badge #s:
⛳️
🖇
🏘
🚎
🖐
🧮
📗
-->

|     | Project               | oauth2                                                                                                                                                                                                                                                              |
|:----|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1️⃣ | name, license, docs   | [![RubyGems.org][⛳️name-img]][⛳️gem] [![License: MIT][🖇src-license-img]][🖇src-license] [![FOSSA][🏘fossa-img]][🏘fossa] [![RubyDoc.info][🚎yard-img]][🚎yard] [![InchCI][🖐inch-ci-img]][🚎yard]                                                                  |
| 2️⃣ | version & activity    | [![Gem Version][⛳️version-img]][⛳️gem] [![Total Downloads][🖇DL-total-img]][⛳️gem] [![Download Rank][🏘DL-rank-img]][⛳️gem] [![Source Code][🚎src-home-img]][🚎src-home] [![Open PRs][🖐prs-open-img]][🖐prs-open] [![Closed PRs][🧮prs-closed-img]][🧮prs-closed]  |
| 3️⃣ | maintanence & linting | [![Maintainability][⛳cclim-maint-img]][⛳cclim-maint] [![Helpers][🖇triage-help-img]][🖇triage-help] [![Depfu][🏘depfu-img]][🏘depfu] [![Contributors][🚎contributors-img]][🚎contributors] [![Style][🖐style-wf-img]][🖐style-wf] [![Kloc Roll][🧮kloc-img]][🧮kloc] |
| 4️⃣ | testing               | [![Build][⛳️tot-bld-img]][⛳️tot-bld] [![supported][🖇supported-wf-img]][🖇supported-wf] [![EOL & Code Coverage Build][🏘eol-wf-img]][🏘eol-wf] [![unsupported][🚎unsupported-wf-img]][🚎unsupported-wf]                                                             |
| 5️⃣ | coverage & security   | [![CodeClimate][⛳cclim-cov-img]][⛳cclim-cov] [![CodeCov][🖇codecov-img]][🖇codecov] [![Coveralls][🏘coveralls-img]][🏘coveralls] [![Security Policy][🚎sec-pol-img]][🚎sec-pol] [![CodeQL][🖐codeQL-img]][🖐codeQL]                                                 |
| 6️⃣ | resources             | [![Discussion][⛳gh-discussions-img]][⛳gh-discussions] [![Get help on Codementor][🖇codementor-img]][🖇codementor] [![Chat][🏘chat-img]][🏘chat] [![Blog][🚎blog-img]][🚎blog] [![Blog][🖐wiki-img]][🖐wiki]                                                         |
| 7️⃣ | spread 💖             | [![Liberapay Patrons][⛳liberapay-img]][⛳liberapay] [![Sponsor Me][🖇sponsor-img]][🖇sponsor] [![Tweet @ Peter][🏘tweet-img]][🏘tweet] [🌏][aboutme] [👼][angelme] [💻][coderme] [🌹][politicme]                                                                     |

<!--
The link tokens in the following sections should be kept ordered by the row and badge numbering scheme
-->

<!-- 1️⃣ name, license, docs -->
[⛳️gem]: https://rubygems.org/gems/oauth2
[⛳️name-img]: https://img.shields.io/badge/name-oauth2-brightgreen.svg?style=flat
[🖇src-license]: https://opensource.org/licenses/MIT
[🖇src-license-img]: https://img.shields.io/badge/License-MIT-green.svg
[🏘fossa]: https://app.fossa.io/projects/git%2Bgithub.com%2Foauth-xx%2Foauth2?ref=badge_shield
[🏘fossa-img]: https://app.fossa.io/api/projects/git%2Bgithub.com%2Foauth-xx%2Foauth2.svg?type=shield
[🚎yard]: https://www.rubydoc.info/github/oauth-xx/oauth2
[🚎yard-img]: https://img.shields.io/badge/documentation-rubydoc-brightgreen.svg?style=flat
[🖐inch-ci-img]: http://inch-ci.org/github/oauth-xx/oauth2.png

<!-- 2️⃣ version & activity -->
[⛳️version-img]: http://img.shields.io/gem/v/oauth2.svg
[🖇DL-total-img]: https://img.shields.io/gem/dt/oauth2.svg
[🏘DL-rank-img]: https://img.shields.io/gem/rt/oauth2.svg
[🚎src-home]: https://github.com/oauth-xx/oauth2
[🚎src-home-img]: https://img.shields.io/badge/source-github-brightgreen.svg?style=flat
[🖐prs-open]: https://github.com/oauth-xx/oauth2/pulls
[🖐prs-open-img]: https://img.shields.io/github/issues-pr/oauth-xx/oauth2
[🧮prs-closed]: https://github.com/oauth-xx/oauth2/pulls?q=is%3Apr+is%3Aclosed
[🧮prs-closed-img]: https://img.shields.io/github/issues-pr-closed/oauth-xx/oauth2

<!-- 3️⃣ maintanence & linting -->
[⛳cclim-maint]: https://codeclimate.com/github/oauth-xx/oauth2/maintainability
[⛳cclim-maint-img]: https://api.codeclimate.com/v1/badges/688c612528ff90a46955/maintainability
[🖇triage-help]: https://www.codetriage.com/oauth-xx/oauth2
[🖇triage-help-img]: https://www.codetriage.com/oauth-xx/oauth2/badges/users.svg
[🏘depfu]: https://depfu.com/github/oauth-xx/oauth2?project_id=4445
[🏘depfu-img]: https://badges.depfu.com/badges/6d34dc1ba682bbdf9ae2a97848241743/count.svg
[🚎contributors]: https://github.com/oauth-xx/oauth2/graphs/contributors
[🚎contributors-img]: https://img.shields.io/github/contributors-anon/oauth-xx/oauth2
[🖐style-wf]: https://github.com/oauth-xx/oauth2/actions/workflows/style.yml
[🖐style-wf-img]: https://github.com/oauth-xx/oauth2/actions/workflows/style.yml/badge.svg
[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[🧮kloc-img]: https://img.shields.io/tokei/lines/github.com/oauth-xx/oauth2

<!-- 4️⃣ testing -->
[⛳️tot-bld]: https://actions-badge.atrox.dev/oauth-xx/oauth2/goto
[⛳️tot-bld-img]: https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Foauth-xx%2Foauth2%2Fbadge&style=flat
[🖇supported-wf]: https://github.com/oauth-xx/oauth2/actions/workflows/supported.yml
[🖇supported-wf-img]: https://github.com/oauth-xx/oauth2/actions/workflows/supported.yml/badge.svg
[🏘eol-wf]: https://github.com/oauth-xx/oauth2/actions/workflows/coverage.yml
[🏘eol-wf-img]: https://github.com/oauth-xx/oauth2/actions/workflows/coverage.yml/badge.svg
[🚎unsupported-wf]: https://github.com/oauth-xx/oauth2/actions/workflows/unsupported.yml
[🚎unsupported-wf-img]: https://github.com/oauth-xx/oauth2/actions/workflows/unsupported.yml/badge.svg
[🖐issues]: https://github.com/oauth-xx/oauth2/issues
[🖐issues-img]: https://github.com/oauth-xx/oauth2/issues

<!-- 5️⃣ coverage & security -->
[⛳cclim-cov]: https://codeclimate.com/github/oauth-xx/oauth2/test_coverage
[⛳cclim-cov-img]: https://api.codeclimate.com/v1/badges/688c612528ff90a46955/test_coverage
[🖇codecov-img]: https://codecov.io/gh/oauth-xx/oauth2/branch/1-4-stable/graph/badge.svg?token=bNqSzNiuo2
[🖇codecov]: https://codecov.io/gh/oauth-xx/oauth2
[🏘coveralls]: https://coveralls.io/github/oauth-xx/oauth2?branch=1-4-stable
[🏘coveralls-img]: https://coveralls.io/repos/github/oauth-xx/oauth2/badge.svg?branch=1-4-stable
[🚎sec-pol]: https://github.com/oauth-xx/oauth2/blob/master/SECURITY.md
[🚎sec-pol-img]: https://img.shields.io/badge/security-policy-brightgreen.svg?style=flat
[🖐codeQL]: https://github.com/oauth-xx/oauth2/security/code-scanning
[🖐codeQL-img]: https://github.com/oauth-xx/oauth2/actions/workflows/codeql-analysis.yml/badge.svg

<!-- 6️⃣ resources -->
[⛳gh-discussions]: https://github.com/oauth-xx/oauth2/discussions
[⛳gh-discussions-img]: https://img.shields.io/github/discussions/oauth-xx/oauth2
[🖇codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
[🖇codementor-img]: https://cdn.codementor.io/badges/get_help_github.svg
[🏘chat]: https://gitter.im/oauth-xx/oauth2
[🏘chat-img]: https://img.shields.io/gitter/room/oauth-xx/oauth2.svg
[🚎blog]: http://www.railsbling.com/tags/oauth2/
[🚎blog-img]: https://img.shields.io/badge/blog-railsbling-brightgreen.svg?style=flat
[🖐wiki]: https://github.com/oauth-xx/oauth2/wiki
[🖐wiki-img]: https://img.shields.io/badge/wiki-examples-brightgreen.svg?style=flat

<!-- 7️⃣ spread 💖 -->
[⛳liberapay-img]: https://img.shields.io/liberapay/patrons/pboling.svg?logo=liberapay
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇sponsor-img]: https://img.shields.io/badge/sponsor-pboling.svg?style=social&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🏘tweet-img]: https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow
[🏘tweet]: http://twitter.com/galtzo

<!-- Maintainer Contact Links -->
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[aboutme]: https://about.me/peter.boling
[angelme]: https://angel.co/peter-boling
[coderme]:http://coderwall.com/pboling
[politicme]: https://nationalprogressiveparty.org


## Installation

```shell
gem install oauth2
```

Or inside a `Gemfile`

```ruby
gem 'oauth2'
```
And then execute in a shell:
```shell
bundle
```


## Compatibility

Targeted ruby compatibility is non-EOL versions of Ruby, currently 2.7, 3.0 and
3.1. Compatibility is further distinguished by supported and unsupported versions of Ruby.
Ruby is limited to 1.9+ in the gemspec for the 1.4.x series and will be 2.2+ for 2.x releases (see `master` branch).

<details>
  <summary>Ruby Engine Compatibility Policy</summary>

This gem is tested against MRI, JRuby, and Truffleruby.
Each of those has varying versions that target a specific version of MRI Ruby.
This gem should work in the just-listed Ruby engines according to the targeted MRI compatibility in the table below.
If you would like to add support for additional engines,
  first make sure Github Actions supports the engine,
  then submit a PR to the correct maintenance branch as according to the table below.
</details>

<details>
  <summary>Ruby Version Compatibility Policy</summary>

If something doesn't work on one of these interpreters, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be responsible for providing patches in a timely
fashion. If critical issues for a particular implementation exist at the time
of a major release, support for that Ruby version may be dropped.
</details>

|     | Ruby OAuth 2 Version | Maintenance Branch | Supported Officially    | Supported Unofficially | Supported Incidentally |
|:----|----------------------|--------------------|-------------------------|------------------------|------------------------|
| 1️⃣ | 2.0.x (unreleased)   | `master`           | 2.7, 3.0, 3.1           | 2.6, 2.5               | 2.4, 2.3, 2.2          |
| 2️⃣ | 1.4.x                | `1-4-stable`       | 2.5, 2.6, 2.7, 3.0, 3.1 | 2.1, 2.2, 2.3, 2.4     | 2.0, 1.9               |
| 3️⃣ | older                | N/A                | Best of luck to you!    | Please upgrade!        |                        |

NOTE: Once 2.0 is released, the 1.4 series will only receive critical bug and security updates.
See [SECURITY.md][🚎sec-pol]

## Usage Examples

```ruby
require 'oauth2'
client = OAuth2::Client.new('client_id', 'client_secret', :site => 'https://example.org')

client.auth_code.authorize_url(:redirect_uri => 'http://localhost:8080/oauth2/callback')
# => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"

token = client.auth_code.get_token('authorization_code_value', :redirect_uri => 'http://localhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})
response = token.get('/api/resource', :params => {'query_foo' => 'bar'})
response.class.name
# => OAuth2::Response
```

<details>
  <summary>Debugging</summary>

Set an environment variable, however you would [normally do that](https://github.com/bkeepers/dotenv).

```ruby
# will log both request and response, including bodies
ENV['OAUTH_DEBUG'] = 'true'
```

By default, debug output will go to `$stdout`. This can be overridden when
initializing your OAuth2::Client.

```ruby
require 'oauth2'
client = OAuth2::Client.new(
  'client_id',
  'client_secret',
  :site => 'https://example.org',
  :logger => Logger.new('example.log', 'weekly')
)
```
</details>

## OAuth2::Response

The `AccessToken` methods `#get`, `#post`, `#put` and `#delete` and the generic `#request`
will return an instance of the #OAuth2::Response class.

This instance contains a `#parsed` method that will parse the response body and
return a Hash if the `Content-Type` is `application/x-www-form-urlencoded` or if
the body is a JSON object.  It will return an Array if the body is a JSON
array.  Otherwise, it will return the original body string.

The original response body, headers, and status can be accessed via their
respective methods.

## OAuth2::AccessToken

If you have an existing Access Token for a user, you can initialize an instance
using various class methods including the standard new, `from_hash` (if you have
a hash of the values), or `from_kvform` (if you have an
`application/x-www-form-urlencoded` encoded string of the values).

## OAuth2::Error

On 400+ status code responses, an `OAuth2::Error` will be raised.  If it is a
standard OAuth2 error response, the body will be parsed and `#code` and `#description` will contain the values provided from the error and
`error_description` parameters.  The `#response` property of `OAuth2::Error` will
always contain the `OAuth2::Response` instance.

If you do not want an error to be raised, you may use `:raise_errors => false`
option on initialization of the client.  In this case the `OAuth2::Response`
instance will be returned as usual and on 400+ status code responses, the
Response instance will contain the `OAuth2::Error` instance.

## Authorization Grants

Currently the Authorization Code, Implicit, Resource Owner Password Credentials, Client Credentials, and Assertion
authentication grant types have helper strategy classes that simplify client
use. They are available via the `#auth_code`, `#implicit`, `#password`, `#client_credentials`, and `#assertion` methods respectively.

```ruby
auth_url = client.auth_code.authorize_url(:redirect_uri => 'http://localhost:8080/oauth/callback')
token = client.auth_code.get_token('code_value', :redirect_uri => 'http://localhost:8080/oauth/callback')

auth_url = client.implicit.authorize_url(:redirect_uri => 'http://localhost:8080/oauth/callback')
# get the token params in the callback and
token = OAuth2::AccessToken.from_kvform(client, query_string)

token = client.password.get_token('username', 'password')

token = client.client_credentials.get_token

token = client.assertion.get_token(assertion_params)
```

If you want to specify additional headers to be sent out with the
request, add a 'headers' hash under 'params':

```ruby
token = client.auth_code.get_token('code_value', :redirect_uri => 'http://localhost:8080/oauth/callback', :headers => {'Some' => 'Header'})
```

You can always use the `#request` method on the `OAuth2::Client` instance to make
requests for tokens for any Authentication grant type.

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver].
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency 'oauth2', '~> 1.4'
```

[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint

## License

[![License: MIT][🖇src-license-img]][🖇src-license]

- Copyright (c) 2011-2013 Michael Bleigh and Intridea, Inc.
- Copyright (c) 2017-2022 [oauth-xx organization][oauth-xx]
- See [LICENSE][license] for details.

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Foauth-xx%2Foauth2.svg?type=large)][fossa2]

[license]: https://github.com/oauth-xx/oauth2/blob/master/LICENSE
[oauth-xx]: https://github.com/oauth-xx
[fossa2]: https://app.fossa.io/projects/git%2Bgithub.com%2Foauth-xx%2Foauth2?ref=badge_large

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle excec rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oauth-xx/oauth2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the OAuth2 project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/oauth-xx/oauth2/blob/master/CODE_OF_CONDUCT.md).
