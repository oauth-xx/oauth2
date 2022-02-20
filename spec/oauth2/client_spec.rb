# coding: utf-8
# frozen_string_literal: true

require 'nkf'

describe OAuth2::Client do
  subject do
    described_class.new('abc', 'def', {:site => 'https://api.example.com'}.merge(options)) do |builder|
      builder.adapter :test do |stub|
        stub.get('/success')             { |env| [200, {'Content-Type' => 'text/awesome'}, 'yay'] }
        stub.get('/reflect')             { |env| [200, {}, env[:body]] }
        stub.post('/reflect')            { |env| [200, {}, env[:body]] }
        stub.get('/unauthorized')        { |env| [401, {'Content-Type' => 'application/json'}, MultiJson.encode(:error => error_value, :error_description => error_description_value)] }
        stub.get('/conflict')            { |env| [409, {'Content-Type' => 'text/plain'}, 'not authorized'] }
        stub.get('/redirect')            { |env| [302, {'Content-Type' => 'text/plain', 'location' => '/success'}, ''] }
        stub.get('/redirect_no_loc')     { |_env| [302, {'Content-Type' => 'text/plain'}, ''] }
        stub.post('/redirect')           { |env| [303, {'Content-Type' => 'text/plain', 'location' => '/reflect'}, ''] }
        stub.get('/error')               { |env| [500, {'Content-Type' => 'text/plain'}, 'unknown error'] }
        stub.get('/empty_get')           { |env| [204, {}, nil] }
        stub.get('/different_encoding')  { |env| [500, {'Content-Type' => 'application/json'}, NKF.nkf('-We', MultiJson.encode(:error => error_value, :error_description => '∞'))] }
        stub.get('/ascii_8bit_encoding') { |env| [500, {'Content-Type' => 'application/json'}, MultiJson.encode(:error => 'invalid_request', :error_description => 'é').force_encoding('ASCII-8BIT')] }
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
      client = described_class.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => false)
      expect(client.options[:raise_errors]).to be false
      client = described_class.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => true)
      expect(client.options[:raise_errors]).to be true
    end

    it 'allows override of raise_errors option' do
      client = described_class.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => true) do |builder|
        builder.adapter :test do |stub|
          stub.get('/notfound') { |_env| [404, {}, nil] }
        end
      end
      expect(client.options[:raise_errors]).to be true
      expect { client.request(:get, '/notfound') }.to raise_error(OAuth2::Error)
      response = client.request(:get, '/notfound', :raise_errors => false)
      expect(response.status).to eq(404)
    end

    it 'allows get/post for access_token_method option' do
      client = described_class.new('abc', 'def', :site => 'https://api.example.com', :access_token_method => :get)
      expect(client.options[:access_token_method]).to eq(:get)
      client = described_class.new('abc', 'def', :site => 'https://api.example.com', :access_token_method => :post)
      expect(client.options[:access_token_method]).to eq(:post)
    end

    it 'does not mutate the opts hash argument' do
      opts = {:site => 'http://example.com/'}
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
          {:site => 'https://example.com/blog'}
        end

        it 'generates an authorization URL relative to the site' do
          expect(subject.send("#{url_type}_url")).to eq("https://example.com/blog/oauth/#{url_type}")
        end
      end

      context 'when a URL with path is used in the site and urls overridden' do
        let(:options) do
          {
            :site => 'https://example.com/blog',
            :authorize_url => "oauth/#{url_type}/lampoon",
            :token_url => "oauth/#{url_type}/lampoon",
          }
        end

        it 'generates an authorization URL relative to the site' do
          expect(subject.send("#{url_type}_url")).to eq("https://example.com/blog/oauth/#{url_type}/lampoon")
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
        client = described_class.new('abc', 'def', :site => 'https://api.example.com') do |builder|
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
        client = described_class.new('abc', 'def', :redirect_uri => 'https://site.com/oauth/callback', :site => 'https://api.example.com') do |builder|
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
          client = described_class.new('abc', 'def', :site => 'https://api.example.com', :auth_scheme => :request_body) do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include({'CustomHeader' => 'CustomHeader'})
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
          client = described_class.new('abc', 'def', :site => 'https://api.example.com', :auth_scheme => :request_body) do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include({'CustomHeader' => 'CustomHeader'})
                [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
              end
            end
          end
          header_params = {:headers => {'CustomHeader' => 'CustomHeader'}}
          client.auth_code.get_token('code', header_params)
        end
      end

      context 'string key custom headers with basic auth' do
        it 'adds the custom headers to request' do
          client = described_class.new('abc', 'def', :site => 'https://api.example.com') do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include({'CustomHeader' => 'CustomHeader'})
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
          client = described_class.new('abc', 'def', :site => 'https://api.example.com') do |builder|
            builder.adapter :test do |stub|
              stub.post('/oauth/token') do |env|
                expect(env.request_headers).to include({'CustomHeader' => 'CustomHeader'})
                [200, {'Content-Type' => 'application/json'}, '{"access_token":"token"}']
              end
            end
          end
          header_params = {:headers => {'CustomHeader' => 'CustomHeader'}}
          client.auth_code.get_token('code', header_params)
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

    it 'posts a body' do
      response = subject.request(:post, '/reflect', :body => 'foo=bar')
      expect(response.body).to eq('foo=bar')
    end

    it 'follows redirects properly' do
      response = subject.request(:get, '/redirect')
      expect(response.body).to eq('yay')
      expect(response.status).to eq(200)
      expect(response.headers).to eq('Content-Type' => 'text/awesome')
    end

    it 'redirects using GET on a 303' do
      response = subject.request(:post, '/redirect', :body => 'foo=bar')
      expect(response.body).to be_empty
      expect(response.status).to eq(200)
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
      expect(response.error).not_to be_nil
    end

    %w[/unauthorized /conflict /error /different_encoding /ascii_8bit_encoding].each do |error_path|
      it "raises OAuth2::Error on error response to path #{error_path}" do
        expect { subject.request(:get, error_path) }.to raise_error(OAuth2::Error)
      end
    end

    # rubocop:disable Style/RedundantBegin
    it 're-encodes response body in the error message' do
      begin
        subject.request(:get, '/ascii_8bit_encoding')
      rescue StandardError => e
        expect(e.message.encoding.name).to eq('UTF-8')
        expect(e.message).to eq("invalid_request: é\n{\"error\":\"invalid_request\",\"error_description\":\"��\"}")
      end
    end

    it 'parses OAuth2 standard error response' do
      begin
        subject.request(:get, '/unauthorized')
      rescue StandardError => e
        expect(e.code).to eq(error_value)
        expect(e.description).to eq(error_description_value)
        expect(e.to_s).to match(/#{error_value}/)
        expect(e.to_s).to match(/#{error_description_value}/)
      end
    end

    it 'provides the response in the Exception' do
      begin
        subject.request(:get, '/error')
      rescue StandardError => e
        expect(e.response).not_to be_nil
        expect(e.to_s).to match(/unknown error/)
      end
    end
    # rubocop:enable Style/RedundantBegin

    context 'with ENV' do
      include_context 'with stubbed env'
      before do
        stub_env('OAUTH_DEBUG' => 'true')
      end

      it 'outputs to $stdout when OAUTH_DEBUG=true' do
        output = capture(:stdout) do
          subject.request(:get, '/success')
        end
        logs = [
          '-- request: GET https://api.example.com/success',
          '-- response: Status 200',
          '-- response: Content-Type: "text/awesome"',
        ]
        expect(output).to include(*logs)
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
      client = stubbed_client(:auth_scheme => :request_body) do |stub|
        stub.post('/oauth/token', 'client_id' => 'abc', 'client_secret' => 'def') do |env|
          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end
      client.get_token({})
    end

    it 'authenticates with Basic auth' do
      client = stubbed_client(:auth_scheme => :basic_auth) do |stub|
        stub.post('/oauth/token') do |env|
          raise Faraday::Adapter::Test::Stubs::NotFound unless env[:request_headers]['Authorization'] == OAuth2::Authenticator.encode_basic_auth('abc', 'def')

          [200, {'Content-Type' => 'application/json'}, MultiJson.encode('access_token' => 'the-token')]
        end
      end
      client.get_token({})
    end

    describe 'extract_access_token option' do
      let(:client) do
        client = stubbed_client(:extract_access_token => extract_access_token) do |stub|
          stub.post('/oauth/token') do
            [200, {'Content-Type' => 'application/json'}, MultiJson.encode('data' => {'access_token' => 'the-token'})]
          end
        end
      end

      context 'with proc extract_access_token' do
        let(:extract_access_token) do
          proc do |client, hash|
            token = hash['data']['access_token']
            OAuth2::AccessToken.new(client, token, hash)
          end
        end

        it 'returns a configured AccessToken' do
          token = client.get_token({})
          expect(token).to be_a OAuth2::AccessToken
          expect(token.token).to eq('the-token')
        end
      end

      context 'with depracted Class.from_hash option' do
        let(:extract_access_token) do
          CustomAccessToken = Class.new(OAuth2::AccessToken)
          CustomAccessToken.define_singleton_method(:from_hash) do |client, hash|
            token = hash['data']['access_token']
            OAuth2::AccessToken.new(client, token, hash)
          end
          CustomAccessToken
        end

        it 'returns a configured AccessToken' do
          token = client.get_token({})
          expect(token).to be_a OAuth2::AccessToken
          expect(token.token).to eq('the-token')
        end
      end
    end

    describe ':raise_errors flag' do
      let(:options) { {} }
      let(:token_response) { nil }
      let(:post_args) { [] }

      let(:client) do
        stubbed_client(options.merge(:raise_errors => raise_errors)) do |stub|
          stub.post('/oauth/token', *post_args) do
            # stub 200 response so that we're testing the get_token handling of :raise_errors flag not request
            [200, {'Content-Type' => 'application/json'}, token_response]
          end
        end
      end

      context 'when set to false' do
        let(:raise_errors) { false }

        context 'when the request body is nil' do
          it 'returns a nil :access_token' do
            expect(client.get_token({})).to eq(nil)
          end
        end

        context 'when the request body is missing the access_token' do
          let(:token_response) { MultiJson.encode('unexpected_access_token' => 'the-token') }

          it 'returns a nil :access_token' do
            expect(client.get_token({})).to eq(nil)
          end
        end

        context 'when the request body has an access token' do
          let(:token_response) { MultiJson.encode('access_token' => 'the-token') }

          it 'returns the parsed :access_token from body' do
            token = client.get_token({})
            expect(token).to be_a OAuth2::AccessToken
            expect(token.token).to eq('the-token')
          end

          context 'when :auth_scheme => :request_body' do
            context 'when arbitrary params are present' do
              let(:post_args) { ['arbitrary' => 'parameter', 'client_id' => 'abc', 'client_secret' => 'def'] }
              let(:options) { {:auth_scheme => :request_body} }

              it 'does not affect access token' do
                token = client.get_token(*post_args)
                expect(token).to be_a OAuth2::AccessToken
                expect(token.token).to eq('the-token')
              end
            end
          end
        end

        context 'when extract_access_token raises an exception' do
          let(:options) do
            {
              :extract_access_token => proc { |client, hash| raise ArgumentError },
            }
          end

          it 'returns a nil :access_token' do
            expect(client.get_token({})).to eq(nil)
          end
        end
      end

      context 'when set to true' do
        let(:raise_errors) { true }

        context 'when the request body is nil' do
          it 'raises an error' do
            expect { client.get_token({}) }.to raise_error OAuth2::Error
          end
        end

        context 'when the request body is missing the access_token' do
          let(:token_response) { MultiJson.encode('unexpected_access_token' => 'the-token') }

          it 'raises an error' do
            expect { client.get_token({}) }.to raise_error OAuth2::Error
          end
        end

        context 'when extract_access_token raises an exception' do
          let(:options) do
            {
              :extract_access_token => proc { |client, hash| raise ArgumentError },
            }
          end

          it 'raises an error' do
            expect { client.get_token({}) }.to raise_error OAuth2::Error
          end
        end
      end
    end

    def stubbed_client(params = {}, &stubs)
      params = {:site => 'https://api.example.com'}.merge(params)
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
      cli = described_class.new('abc', 'def', :site => 'https://api.example.com', :ssl => {:ca_file => 'foo.pem'})
      cli.connection = Faraday.new(cli.site, cli.options[:connection_opts]) do |b|
        b.adapter :test
      end
      cli
    end

    it 'passes the SSL options along to Faraday::Connection#ssl' do
      expect(subject.connection.ssl.fetch(:ca_file)).to eq('foo.pem')
    end
  end
end
