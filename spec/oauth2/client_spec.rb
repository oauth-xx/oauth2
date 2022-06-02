# coding: utf-8
# frozen_string_literal: true

require 'nkf'

RSpec.describe OAuth2::Client do
  subject do
    described_class.new('abc', 'def', {site: 'https://api.example.com'}.merge(options)) do |builder|
      builder.adapter :test do |stub|
        stub.get('/success')             { |_env| [200, {'Content-Type' => 'text/awesome'}, 'yay'] }
        stub.get('/reflect')             { |env| [200, {}, env[:body]] }
        stub.post('/reflect')            { |env| [200, {}, env[:body]] }
        stub.get('/unauthorized')        { |_env| [401, {'Content-Type' => 'application/json'}, MultiJson.encode(error: error_value, error_description: error_description_value)] }
        stub.get('/conflict')            { |_env| [409, {'Content-Type' => 'text/plain'}, 'not authorized'] }
        stub.get('/redirect')            { |_env| [302, {'Content-Type' => 'text/plain', 'location' => '/success'}, ''] }
        stub.get('/redirect_no_loc')     { |_env| [302, {'Content-Type' => 'text/plain'}, ''] }
        stub.post('/redirect')           { |_env| [303, {'Content-Type' => 'text/plain', 'location' => '/reflect'}, ''] }
        stub.get('/error')               { |_env| [500, {'Content-Type' => 'text/plain'}, 'unknown error'] }
        stub.get('/empty_get')           { |_env| [204, {}, nil] }
        stub.get('/different_encoding')  { |_env| [500, {'Content-Type' => 'application/json'}, NKF.nkf('-We', MultiJson.encode(error: error_value, error_description: '∞'))] }
        stub.get('/ascii_8bit_encoding') { |_env| [500, {'Content-Type' => 'application/json'}, MultiJson.encode(error: 'invalid_request', error_description: 'é').force_encoding('ASCII-8BIT')] }
      end
    end
  end

  let!(:error_value) { 'invalid_token' }
  let!(:error_description_value) { 'bad bad token' }
  let(:options) { {} }

  describe '#initialize' do
    it 'assigns id and secret' do
      expect(subject.id).to eq('abc')
      expect(subject.secret).to eq('def')
    end

    it 'assigns site from the options hash' do
      expect(subject.site).to eq('https://api.example.com')
    end

    it 'assigns Faraday::Connection#host' do
      expect(subject.connection.host).to eq('api.example.com')
    end

    it 'leaves Faraday::Connection#ssl unset' do
      expect(subject.connection.ssl).to be_empty
    end

    it 'is able to pass a block to configure the connection' do
      builder = double('builder')

      allow(Faraday).to receive(:new).and_yield(builder)
      allow(builder).to receive(:response)

      expect(builder).to receive(:adapter).with(:test)

      described_class.new('abc', 'def') do |client|
        client.adapter :test
      end.connection
    end

    it 'defaults raise_errors to true' do
      expect(subject.options[:raise_errors]).to be true
    end

    it 'allows true/false for raise_errors option' do
      client = described_class.new('abc', 'def', site: 'https://api.example.com', raise_errors: false)
      expect(client.options[:raise_errors]).to be false
      client = described_class.new('abc', 'def', site: 'https://api.example.com', raise_errors: true)
      expect(client.options[:raise_errors]).to be true
    end

    it 'allows override of raise_errors option' do
      client = described_class.new('abc', 'def', site: 'https://api.example.com', raise_errors: true) do |builder|
        builder.adapter :test do |stub|
          stub.get('/notfound') { |_env| [404, {}, nil] }
        end
      end
      expect(client.options[:raise_errors]).to be true
      expect { client.request(:get, '/notfound') }.to raise_error(OAuth2::Error)
      response = client.request(:get, '/notfound', raise_errors: false)
      expect(response.status).to eq(404)
    end

    it 'allows get/post for access_token_method option' do
      client = described_class.new('abc', 'def', site: 'https://api.example.com', access_token_method: :get)
      expect(client.options[:access_token_method]).to eq(:get)
      client = described_class.new('abc', 'def', site: 'https://api.example.com', access_token_method: :post)
      expect(client.options[:access_token_method]).to eq(:post)
    end

    it 'does not mutate the opts hash argument' do
      opts = {site: 'http://example.com/'}
      opts2 = opts.dup
      described_class.new 'abc', 'def', opts
      expect(opts).to eq(opts2)
    end
  end

  %w[authorize token].each do |url_type|
    describe ":#{url_type}_url option" do
      it "defaults to a path of /oauth/#{url_type}" do
        expect(subject.send("#{url_type}_url")).to eq("https://api.example.com/oauth/#{url_type}")
      end

      it "is settable via the :#{url_type}_url option" do
        subject.options[:"#{url_type}_url"] = '/oauth/custom'
        expect(subject.send("#{url_type}_url")).to eq('https://api.example.com/oauth/custom')
      end

      it 'allows a different host than the site' do
        subject.options[:"#{url_type}_url"] = 'https://api.foo.com/oauth/custom'
        expect(subject.send("#{url_type}_url")).to eq('https://api.foo.com/oauth/custom')
      end

      context 'when a URL with path is used in the site' do
        let(:options) do
          {site: 'https://example.com/blog'}
        end

        it 'generates an authorization URL relative to the site' do
          expect(subject.send("#{url_type}_url")).to eq("https://example.com/blog/oauth/#{url_type}")
        end
      end
    end
  end

  describe ':redirect_uri option' do
    let(:auth_code_params) do
      {
        'client_id' => 'abc',
        'client_secret' => 'def',
        'code' => 'code',
        'grant_type' => 'authorization_code',
      }
    end

    context 'when blank' do
      it 'there is no redirect_uri param added to authorization URL' do
        expect(subject.authorize_url('a' => 'b')).to eq('https://api.example.com/oauth/authorize?a=b')
      end

      it 'does not add the redirect_uri param to the auth_code token exchange request' do
        client = described_class.new('abc', 'def', site: 'https://api.example.com', auth_scheme: :request_body) do |builder|
          builder.adapter :test do |stub|
            stub.post('/oauth/token', auth_code_params) do
              [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
            end
          end
        end
        client.auth_code.get_token('code')
      end
    end

    context 'when set' do
      before { subject.options[:redirect_uri] = 'https://site.com/oauth/callback' }

      it 'adds the redirect_uri param to authorization URL' do
        expect(subject.authorize_url('a' => 'b')).to eq('https://api.example.com/oauth/authorize?a=b&redirect_uri=https%3A%2F%2Fsite.com%2Foauth%2Fcallback')
      end

      it 'adds the redirect_uri param to the auth_code token exchange request' do
        client = described_class.new('abc', 'def', redirect_uri: 'https://site.com/oauth/callback', site: 'https://api.example.com', auth_scheme: :request_body) do |builder|
          builder.adapter :test do |stub|
            stub.post('/oauth/token', auth_code_params.merge('redirect_uri' => 'https://site.com/oauth/callback')) do
              [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
            end
          end
        end
        client.auth_code.get_token('code')
      end
    end

    describe 'custom headers' do
      context 'string key headers' do
        it 'adds the custom headers to request' do
          client = described_class.new('abc', 'def', site: 'https://api.example.com', auth_scheme: :request_body) do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include('CustomHeader' => 'CustomHeader')
                [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
              end
            end
          end
          header_params = {'headers' => {'CustomHeader' => 'CustomHeader'}}
          client.auth_code.get_token('code', header_params)
        end
      end

      context 'symbol key headers' do
        it 'adds the custom headers to request' do
          client = described_class.new('abc', 'def', site: 'https://api.example.com', auth_scheme: :request_body) do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include('CustomHeader' => 'CustomHeader')
                [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
              end
            end
          end
          header_params = {headers: {'CustomHeader' => 'CustomHeader'}}
          client.auth_code.get_token('code', header_params)
        end
      end

      context 'string key custom headers with basic auth' do
        it 'adds the custom headers to request' do
          client = described_class.new('abc', 'def', site: 'https://api.example.com') do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include('CustomHeader' => 'CustomHeader')
                [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
              end
            end
          end
          header_params = {'headers' => {'CustomHeader' => 'CustomHeader'}}
          client.auth_code.get_token('code', header_params)
        end
      end

      context 'symbol key custom headers with basic auth' do
        it 'adds the custom headers to request' do
          client = described_class.new('abc', 'def', site: 'https://api.example.com') do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include('CustomHeader' => 'CustomHeader')
                [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
              end
            end
          end
          header_params = {headers: {'CustomHeader' => 'CustomHeader'}}
          client.auth_code.get_token('code', header_params)
        end
      end
    end
  end

  describe '#connection' do
    context 'when debugging' do
      include_context 'with stubbed env'
      before do
        stub_env('OAUTH_DEBUG' => debug_value)
      end

      context 'when OAUTH_DEBUG=true' do
        let(:debug_value) { 'true' }

        it 'smoothly handles successive requests' do
          silence_all do
            # first request (always goes smoothly)
            subject.request(:get, '/success')
          end

          expect do
            # second request (used to throw Faraday::RackBuilder::StackLocked)
            subject.request(:get, '/success')
          end.not_to raise_error
        end

        it 'prints both request and response bodies to STDOUT' do
          printed = capture(:stdout) do
            subject.request(:get, '/success')
            subject.request(:get, '/reflect', body: 'this is magical')
          end
          expect(printed).to match 'request: GET https://api.example.com/success'
          expect(printed).to match 'response: Content-Type:'
          expect(printed).to match 'response: yay'
          expect(printed).to match 'request: this is magical'
          expect(printed).to match 'response: this is magical'
        end
      end

      context 'when OAUTH_DEBUG=false' do
        let(:debug_value) { 'false' }

        it 'smoothly handles successive requests' do
          silence_all do
            # first request (always goes smoothly)
            subject.request(:get, '/success')
          end

          expect do
            # second request (used to throw Faraday::RackBuilder::StackLocked)
            subject.request(:get, '/success')
          end.not_to raise_error
        end

        it 'prints nothing to STDOUT' do
          printed = capture(:stdout) do
            subject.request(:get, '/success')
            subject.request(:get, '/reflect', body: 'this is magical')
          end
          expect(printed).to eq ''
        end
      end
    end
  end

  describe '#request' do
    it 'works with a null response body' do
      expect(subject.request(:get, 'empty_get').body).to eq('')
    end

    it 'returns on a successful response' do
      response = subject.request(:get, '/success')
      expect(response.body).to eq('yay')
      expect(response.status).to eq(200)
      expect(response.headers).to eq('Content-Type' => 'text/awesome')
    end

    context 'with ENV' do
      include_context 'with stubbed env'
      context 'when OAUTH_DEBUG=true' do
        before do
          stub_env('OAUTH_DEBUG' => 'true')
        end

        it 'outputs to $stdout when OAUTH_DEBUG=true' do
          output = capture(:stdout) do
            subject.request(:get, '/success')
          end
          logs = [
            'request: GET https://api.example.com/success',
            'response: Status 200',
            'response: Content-Type: "text/awesome"',
          ]
          expect(output).to include(*logs)
        end
      end
    end

    it 'posts a body' do
      response = subject.request(:post, '/reflect', body: 'foo=bar')
      expect(response.body).to eq('foo=bar')
    end

    it 'follows redirects properly' do
      response = subject.request(:get, '/redirect')
      expect(response.body).to eq('yay')
      expect(response.status).to eq(200)
      expect(response.headers).to eq('Content-Type' => 'text/awesome')
      expect(response.response.env.url.to_s).to eq('https://api.example.com/success')
    end

    it 'redirects using GET on a 303' do
      response = subject.request(:post, '/redirect', body: 'foo=bar')
      expect(response.body).to be_empty
      expect(response.status).to eq(200)
      expect(response.response.env.url.to_s).to eq('https://api.example.com/reflect')
    end

    it 'raises an error if a redirect has no Location header' do
      expect { subject.request(:get, '/redirect_no_loc') }.to raise_error(OAuth2::Error, 'Got 302 status code, but no Location header was present')
    end

    it 'obeys the :max_redirects option' do
      max_redirects = subject.options[:max_redirects]
      subject.options[:max_redirects] = 0
      response = subject.request(:get, '/redirect')
      expect(response.status).to eq(302)
      subject.options[:max_redirects] = max_redirects
    end

    it 'returns if raise_errors is false' do
      subject.options[:raise_errors] = false
      response = subject.request(:get, '/unauthorized')

      expect(response.status).to eq(401)
      expect(response.headers).to eq('Content-Type' => 'application/json')
    end

    %w[/unauthorized /conflict /error /different_encoding /ascii_8bit_encoding].each do |error_path|
      it "raises OAuth2::Error on error response to path #{error_path}" do
        pending_for(engine: 'jruby', reason: 'https://github.com/jruby/jruby/issues/4921') if error_path == '/different_encoding'
        expect { subject.request(:get, error_path) }.to raise_error(OAuth2::Error)
      end
    end

    it 're-encodes response body in the error message' do
      expect { subject.request(:get, '/ascii_8bit_encoding') }.to raise_error do |ex|
        expect(ex.message).to eq("invalid_request: é\n{\"error\":\"invalid_request\",\"error_description\":\"��\"}")
        expect(ex.message.encoding.name).to eq('UTF-8')
      end
    end

    it 'parses OAuth2 standard error response' do
      expect { subject.request(:get, '/unauthorized') }.to raise_error do |ex|
        expect(ex.code).to eq(error_value)
        expect(ex.description).to eq(error_description_value)
        expect(ex.to_s).to match(/#{error_value}/)
        expect(ex.to_s).to match(/#{error_description_value}/)
      end
    end

    it 'provides the response in the Exception' do
      expect { subject.request(:get, '/error') }.to raise_error do |ex|
        expect(ex.response).not_to be_nil
        expect(ex.to_s).to match(/unknown error/)
      end
    end

    context 'when errors are raised by Faraday' do
      let(:connection) { instance_double(Faraday::Connection, build_url: double) }

      it 'rescues Faraday::ConnectionFailed' do
        allow(connection).to(
          receive(:run_request).and_raise(Faraday::ConnectionFailed.new('fail'))
        )
        allow(subject).to receive(:connection).and_return(connection) # rubocop:disable RSpec/SubjectStub

        expect { subject.request(:get, '/redirect') }.to raise_error do |e|
          expect(e.class).to eq(OAuth2::ConnectionError)
          expect(e.message).to eq('fail')
        end
      end
    end
  end

  describe '#get_token' do
    it 'returns a configured AccessToken' do
      client = stubbed_client do |stub|
        stub.post('/oauth/token') do
          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end

      token = client.get_token({})
      expect(token).to be_a OAuth2::AccessToken
      expect(token.token).to eq('the-token')
    end

    it 'authenticates with request parameters' do
      client = stubbed_client(auth_scheme: :request_body) do |stub|
        stub.post('/oauth/token', 'client_id' => 'abc', 'client_secret' => 'def') do |_env|
          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end
      client.get_token({})
    end

    it 'authenticates with Basic auth' do
      client = stubbed_client(auth_scheme: :basic_auth) do |stub|
        stub.post('/oauth/token') do |env|
          raise Faraday::Adapter::Test::Stubs::NotFound unless env[:request_headers]['Authorization'] == OAuth2::Authenticator.encode_basic_auth('abc', 'def')

          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end
      client.get_token({})
    end

    it 'sets the response object on the access token' do
      client = stubbed_client do |stub|
        stub.post('/oauth/token') do
          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end

      token = client.get_token({})
      expect(token.response).to be_a OAuth2::Response
      expect(token.response.parsed).to eq('access_token' => 'the-token')
    end

    context 'when the :raise_errors flag is set to false' do
      context 'when the request body is nil' do
        subject(:get_token) { client.get_token({}) }

        let(:client) do
          stubbed_client(raise_errors: false) do |stub|
            stub.post('/oauth/token') do
              [500, {'Content-Type' => 'application/json'}, nil]
            end
          end
        end

        it 'raises error MultiJson::ParseError' do
          block_is_expected { get_token }.to raise_error(MultiJson::ParseError)
        end
      end

      context 'when the request body is not nil' do
        it 'returns the parsed :access_token from body' do
          client = stubbed_client do |stub|
            stub.post('/oauth/token') do
              [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
            end
          end

          token = client.get_token({})
          expect(token.response).to be_a OAuth2::Response
          expect(token.response.parsed).to eq('access_token' => 'the-token')
        end
      end
    end

    it 'forwards given token parameters' do
      client = stubbed_client(auth_scheme: :request_body) do |stub|
        stub.post('/oauth/token', 'arbitrary' => 'parameter', 'client_id' => 'abc', 'client_secret' => 'def') do |_env|
          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end
      client.get_token('arbitrary' => 'parameter')
    end

    context 'when token_method is set to post_with_query_string' do
      it 'uses the http post method and passes parameters in the query string' do
        client = stubbed_client(token_method: :post_with_query_string) do |stub|
          stub.post('/oauth/token?state=abc123') do |_env|
            [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
          end
        end
        client.get_token('state' => 'abc123')
      end
    end

    def stubbed_client(params = {}, &stubs)
      params = {site: 'https://api.example.com'}.merge(params)
      OAuth2::Client.new('abc', 'def', params) do |builder|
        builder.adapter :test, &stubs
      end
    end
  end

  it 'instantiates an AuthCode strategy with this client' do
    expect(subject.auth_code).to be_kind_of(OAuth2::Strategy::AuthCode)
  end

  it 'instantiates an Implicit strategy with this client' do
    expect(subject.implicit).to be_kind_of(OAuth2::Strategy::Implicit)
  end

  context 'with SSL options' do
    subject do
      cli = described_class.new('abc', 'def', site: 'https://api.example.com', ssl: {ca_file: 'foo.pem'})
      cli.connection = Faraday.new(cli.site, cli.options[:connection_opts]) do |b|
        b.adapter :test
      end
      cli
    end

    it 'passes the SSL options along to Faraday::Connection#ssl' do
      expect(subject.connection.ssl.fetch(:ca_file)).to eq('foo.pem')
    end
  end

  context 'without a connection-configuration block' do
    subject do
      described_class.new('abc', 'def', site: 'https://api.example.com')
    end

    it 'applies default faraday middleware to the connection' do
      expect(subject.connection.builder.handlers).to include(Faraday::Request::UrlEncoded)
    end
  end
end
