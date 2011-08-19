# OAuth2
A Ruby wrapper for the OAuth 2.0 specification. This is a work in progress, being built first to solve the pragmatic process of connecting to existing OAuth 2.0 endpoints (a.k.a. Facebook) with the goal of building it up to meet the entire specification over time.

## <a name="installation">Installation</a>
    gem install oauth2

## <a name="ci">Continuous Integration</a>
[![Build Status](https://secure.travis-ci.org/intridea/oauth2.png)](http://travis-ci.org/intridea/oauth2)

## <a name="resources">Resources</a>
* View Source on GitHub (https://github.com/intridea/oauth2)
* Report Issues on GitHub (https://github.com/intridea/oauth2/issues)
* Read More at the Wiki (https://wiki.github.com/intridea/oauth2)

## <a name="examples">Usage Examples</a>
    require 'oauth2'
    client = OAuth2::Client.new('client_id', 'client_secret', :site => 'https://example.org')

    client.auth_code.authorize_url(:redirect_uri => 'http://localhost:8080/oauth2/callback')
    # => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"

    token = client.auth_code.get_token('authorization_code_value', :redirect_uri => 'http://localhost:8080/oauth2/callback')
    response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
    response.class.name
    # => OAuth2::Response

## <a name="response">OAuth2::Response</a>
The AccessToken methods #get, #post, #put and #delete and the generic #request will return an instance of the #OAuth2::Response class.
This instance contains a #parsed method that will parse the response body and return a Hash if the Content-Type is application/x-www-form-urlencoded or if the body is a JSON object.  It will return an Array if the body is a JSON array.  Otherwise, it will return the original body string.

The original response body, headers, and status can be accessed via their respective methods.

## <a name="access_token">OAuth2::AccessToken</a>
If you have an existing Access Token for a user, you can initialize an instance using various class methods including the standard new, from_hash (if you have a hash of the values), or from_kvform (if you have an application/x-www-form-urlencoded encoded string of the values).

## <a name="error">OAuth2::Error</a>
On 400+ status code responses, an OAuth2::Error will be raised.  If it is a standard OAuth2 error response, the body will be parsed and #code and #description will contain the values provided from the error and error_description parameters.  The #response property of OAuth2::Error will always contain the OAuth2::Response instance.

If you do not want an error to be raised, you may use :raise_errors => false option on initialization of the client.  In this case the OAuth2::Response instance will be returned as usual and on 400+ status code responses, the Response instance will contain the OAuth2::Error instance.

## <a name="authorization_grants">Authorization Grants</a>
Currently the Authorization Code and Resource Owner Password Credentials authentication grant types have helper strategy classes that simplify client use.  They are available via the #auth_code and #password methods respectively.

    auth_url = client.auth_code.authorization_url(:redirect_uri => 'http://localhost:8080/oauth/callback')
    token = client.auth_code.get_token('code_value', :redirect_uri => 'http://localhost:8080/oauth/callback')

    token = client.password.get_token('username', 'password')

You can always use the #request method on the OAuth2::Client instance to make requests for tokens for any Authentication grant type.

## <a name="pulls">Submitting a Pull Request</a>
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Add specs for your feature or bug fix.
6. Run <tt>bundle exec rake spec</tt>. If your changes are not 100% covered, go back to step 5.
7. Commit and push your changes.
8. Submit a pull request. Please do not include changes to the [gemspec](https://github.com/intridea/oauth2/blob/master/oauth2.gemspec), [version](https://github.com/intridea/oauth2/blob/master/lib/oauth2/version.rb), or [changelog](https://github.com/intridea/oauth2/wiki/Changelg) . (If you want to create your own version for some reason, please do so in a separate commit.)

## <a name="rubies">Supported Rubies</a>
This library aims to support and is [tested
against](http://travis-ci.org/intridea/oauth2) the following Ruby
implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* [JRuby](http://www.jruby.org/)
* [Rubinius](http://rubini.us/)
* [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/)

If something doesn't work on one of these interpreters, it should be considered
a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be personally responsible for providing patches in a
timely fashion. If critical issues for a particular implementation exist at the
time of a major release, support for that Ruby version may be dropped.

## <a name="copyright">Copyright</a>
Copyright (c) 2011 Intridea, Inc. and Michael Bleigh.
See [LICENSE](https://github.com/intridea/oauth2/blob/master/LICENSE.md) for details.
