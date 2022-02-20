# frozen_string_literal: true

describe OAuth2::AccessToken do
  subject { described_class.new(client, token) }

  let(:token) { 'monkey' }
  let(:refresh_body) { MultiJson.encode(:access_token => 'refreshed_foo', :expires_in => 600, :refresh_token => 'refresh_bar') }
  let(:client) do
    OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.request :url_encoded
      builder.adapter :test do |stub|
        VERBS.each do |verb|
          stub.send(verb, '/token/header') { |env| [200, {}, env[:request_headers]['Authorization']] }
          stub.send(verb, "/token/query?access_token=#{token}") { |env| [200, {}, Addressable::URI.parse(env[:url]).query_values['access_token']] }
          stub.send(verb, '/token/query_string') { |env| [200, {}, CGI.unescape(Addressable::URI.parse(env[:url]).query)] }
          stub.send(verb, '/token/body') { |env| [200, {}, env[:body]] }
        end
        stub.post('/oauth/token') { |env| [200, {'Content-Type' => 'application/json'}, refresh_body] }
      end
    end
  end

  describe '#initialize' do
    it 'assigns client and token' do
      expect(subject.client).to eq(client)
      expect(subject.token).to eq(token)
    end

    it 'assigns extra params' do
      target = described_class.new(client, token, 'foo' => 'bar')
      expect(target.params).to include('foo')
      expect(target.params['foo']).to eq('bar')
    end

    def assert_initialized_token(target)
      expect(target.token).to eq(token)
      expect(target).to be_expires
      expect(target.params.keys).to include('foo')
      expect(target.params['foo']).to eq('bar')
    end

    it 'initializes with a Hash' do
      hash = {:access_token => token, :expires_at => Time.now.to_i + 200, 'foo' => 'bar'}
      target = described_class.from_hash(client, hash)
      assert_initialized_token(target)
    end

    it 'from_hash does not modify opts hash' do
      hash = {:access_token => token, :expires_at => Time.now.to_i}
      hash_before = hash.dup
      described_class.from_hash(client, hash)
      expect(hash).to eq(hash_before)
    end

    it 'initializes with a form-urlencoded key/value string' do
      kvform = "access_token=#{token}&expires_at=#{Time.now.to_i + 200}&foo=bar"
      target = described_class.from_kvform(client, kvform)
      assert_initialized_token(target)
    end

    it 'sets options' do
      target = described_class.new(client, token, :param_name => 'foo', :header_format => 'Bearer %', :mode => :body)
      expect(target.options[:param_name]).to eq('foo')
      expect(target.options[:header_format]).to eq('Bearer %')
      expect(target.options[:mode]).to eq(:body)
    end

    it 'does not modify opts hash' do
      opts = {:param_name => 'foo', :header_format => 'Bearer %', :mode => :body}
      opts_before = opts.dup
      described_class.new(client, token, opts)
      expect(opts).to eq(opts_before)
    end

    describe 'expires_at' do
      let(:expires_at) { 1_361_396_829 }
      let(:hash) do
        {
          :access_token => token,
          :expires_at => expires_at.to_s,
          'foo' => 'bar',
        }
      end

      it 'initializes with an integer timestamp expires_at' do
        target = described_class.from_hash(client, hash.merge(:expires_at => expires_at))
        assert_initialized_token(target)
        expect(target.expires_at).to eql(expires_at)
      end

      it 'initializes with a string timestamp expires_at' do
        target = described_class.from_hash(client, hash)
        assert_initialized_token(target)
        expect(target.expires_at).to eql(expires_at)
      end

      it 'initializes with a string time expires_at' do
        target = described_class.from_hash(client, hash.merge(:expires_at => Time.at(expires_at).iso8601))
        assert_initialized_token(target)
        expect(target.expires_at).to eql(expires_at)
      end
    end
  end

  describe '#request' do
    context 'with :mode => :header' do
      before do
        subject.options[:mode] = :header
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          expect(subject.post('/token/header').body).to include(token)
        end
      end
    end

    context 'with :mode => :query' do
      before do
        subject.options[:mode] = :query
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          expect(subject.post('/token/query').body).to eq(token)
        end

        it "sends a #{verb.to_s.upcase} request and options[:param_name] include [number]." do
          subject.options[:param_name] = 'auth[1]'
          expect(subject.__send__(verb, '/token/query_string').body).to include("auth[1]=#{token}")
        end
      end
    end

    context 'with :mode => :body' do
      before do
        subject.options[:mode] = :body
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          expect(subject.post('/token/body').body.split('=').last).to eq(token)
        end
      end
    end

    context 'params include [number]' do
      VERBS.each do |verb|
        it "sends #{verb.to_s.upcase} correct query" do
          expect(subject.__send__(verb, '/token/query_string', :params => {'foo[bar][1]' => 'val'}).body).to include('foo[bar][1]=val')
        end
      end
    end
  end

  describe '#expires?' do
    it 'is false if there is no expires_at' do
      expect(described_class.new(client, token)).not_to be_expires
    end

    it 'is true if there is an expires_in' do
      expect(described_class.new(client, token, :refresh_token => 'abaca', :expires_in => 600)).to be_expires
    end

    it 'is true if there is an expires_at' do
      expect(described_class.new(client, token, :refresh_token => 'abaca', :expires_in => Time.now.getutc.to_i + 600)).to be_expires
    end
  end

  describe '#expired?' do
    it 'is false if there is no expires_in or expires_at' do
      expect(described_class.new(client, token)).not_to be_expired
    end

    it 'is false if expires_in is in the future' do
      expect(described_class.new(client, token, :refresh_token => 'abaca', :expires_in => 10_800)).not_to be_expired
    end

    it 'is true if expires_at is in the past' do
      access = described_class.new(client, token, :refresh_token => 'abaca', :expires_in => 600)
      @now = Time.now + 10_800
      allow(Time).to receive(:now).and_return(@now)
      expect(access).to be_expired
    end
  end

  describe '#refresh!' do
    let(:access) do
      described_class.new(client, token, :refresh_token => 'abaca',
                                         :expires_in => 600,
                                         :param_name => 'o_param')
    end

    it 'returns a refresh token with appropriate values carried over' do
      refreshed = access.refresh!
      expect(access.client).to eq(refreshed.client)
      expect(access.options[:param_name]).to eq(refreshed.options[:param_name])
    end

    context 'with a nil refresh_token in the response' do
      let(:refresh_body) { MultiJson.encode(:access_token => 'refreshed_foo', :expires_in => 600, :refresh_token => nil) }

      it 'copies the refresh_token from the original token' do
        refreshed = access.refresh!

        expect(refreshed.refresh_token).to eq(access.refresh_token)
      end
    end
  end

  describe '#to_hash' do
    it 'return a hash equals to the hash used to initialize access token' do
      hash = {:access_token => token, :refresh_token => 'foobar', :expires_at => Time.now.to_i + 200, 'foo' => 'bar'}
      access_token = described_class.from_hash(client, hash.clone)
      expect(access_token.to_hash).to eq(hash)
    end
  end
end
