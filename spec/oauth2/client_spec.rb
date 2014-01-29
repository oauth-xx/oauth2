require 'helper'

describe OAuth2::Client do
  let!(:error_value) { 'invalid_token' }
  let!(:error_description_value) { 'bad bad token' }

  subject do
    OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.adapter :test do |stub|
        stub.get('/success')      { |env| [200, {'Content-Type' => 'text/awesome'}, 'yay'] }
        stub.get('/reflect')      { |env| [200, {}, env[:body]] }
        stub.post('/reflect')     { |env| [200, {}, env[:body]] }
        stub.get('/unauthorized') { |env| [401, {'Content-Type' => 'application/json'}, MultiJson.encode(:error => error_value, :error_description => error_description_value)] }
        stub.get('/conflict')     { |env| [409, {'Content-Type' => 'text/plain'}, 'not authorized'] }
        stub.get('/redirect')     { |env| [302, {'Content-Type' => 'text/plain', 'location' => '/success'}, ''] }
        stub.post('/redirect')    { |env| [303, {'Content-Type' => 'text/plain', 'location' => '/reflect'}, ''] }
        stub.get('/error')        { |env| [500, {'Content-Type' => 'text/plain'}, 'unknown error'] }
        stub.get('/empty_get')    { |env| [204, {}, nil] }
      end
    end
  end

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
      connection = double('connection')
      builder = double('builder')
      allow(connection).to receive(:build).and_yield(builder)
      allow(Faraday::Connection).to receive(:new).and_return(connection)

      expect(builder).to receive(:adapter).with(:test)

      OAuth2::Client.new('abc', 'def') do |client|
        client.adapter :test
      end.connection
    end

    it 'defaults raise_errors to true' do
      expect(subject.options[:raise_errors]).to be true
    end

    it 'allows true/false for raise_errors option' do
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => false)
      expect(client.options[:raise_errors]).to be false
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => true)
      expect(client.options[:raise_errors]).to be true
    end

    it 'allows override of raise_errors option' do
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => true) do |builder|
        builder.adapter :test do |stub|
          stub.get('/notfound') { |env| [404, {}, nil] }
        end
      end
      expect(client.options[:raise_errors]).to be true
      expect { client.request(:get, '/notfound') }.to raise_error(OAuth2::Error)
      response = client.request(:get, '/notfound', :raise_errors => false)
      expect(response.status).to eq(404)
    end

    it 'allows get/post for access_token_method option' do
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :access_token_method => :get)
      expect(client.options[:access_token_method]).to eq(:get)
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :access_token_method => :post)
      expect(client.options[:access_token_method]).to eq(:post)
    end

    it 'does not mutate the opts hash argument' do
      opts = {:site => 'http://example.com/'}
      opts2 = opts.dup
      OAuth2::Client.new 'abc', 'def', opts
      expect(opts).to eq(opts2)
    end
  end

  %w(authorize token).each do |url_type|
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

    it 'outputs to $stdout when OAUTH_DEBUG=true' do
      ENV.stub(:[]).with('http_proxy').and_return(nil)
      ENV.stub(:[]).with('OAUTH_DEBUG').and_return('true')
      output = capture_output do
        subject.request(:get, '/success')
      end

      expect(output).to include 'INFO -- : get https://api.example.com/success', 'INFO -- : get https://api.example.com/success'
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

    %w(/unauthorized /conflict /error).each do |error_path|
      it "raises OAuth2::Error on error response to path #{error_path}" do
        expect { subject.request(:get, error_path) }.to raise_error(OAuth2::Error)
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
  end

  it 'instantiates an AuthCode strategy with this client' do
    expect(subject.auth_code).to be_kind_of(OAuth2::Strategy::AuthCode)
  end

  it 'instantiates an Implicit strategy with this client' do
    expect(subject.implicit).to be_kind_of(OAuth2::Strategy::Implicit)
  end

  context 'with SSL options' do
    subject do
      cli = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :ssl => {:ca_file => 'foo.pem'})
      cli.connection.build do |b|
        b.adapter :test
      end
      cli
    end

    it 'passes the SSL options along to Faraday::Connection#ssl' do
      expect(subject.connection.ssl.fetch(:ca_file)).to eq('foo.pem')
    end
  end
end
