require 'helper'

VERBS = [:get, :post, :put, :delete]

describe AccessToken do
  let(:token) {'monkey'}
  let(:token_body) {MultiJson.encode(:access_token => 'foo', :expires_in => 600, :refresh_token => 'bar')}
  let(:refresh_body) {MultiJson.encode(:access_token => 'refreshed_foo', :expires_in => 600, :refresh_token => 'refresh_bar')}
  let(:client) do
    Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.request :url_encoded
      builder.adapter :test do |stub|
        VERBS.each do |verb|
          stub.send(verb, '/token/header') {|env| [200, {}, env[:request_headers]['Authorization']]}
          stub.send(verb, "/token/query?bearer_token=#{token}") {|env| [200, {}, Addressable::URI.parse(env[:url]).query_values['bearer_token']]}
          stub.send(verb, '/token/body') {|env| [200, {}, env[:body]]}
        end
        stub.post('/oauth/token') {|env| [200, {'Content-Type' => 'application/json'}, refresh_body]}
      end
    end
  end

  subject {AccessToken.new(client, token)}

  describe '#initialize' do
    it 'assigns client and token' do
      subject.client.should == client
      subject.token.should  == token
    end

    it 'assigns extra params' do
      target = AccessToken.new(client, token, 'foo' => 'bar')
      target.params.should include('foo')
      target.params['foo'].should == 'bar'
    end

    def assert_initialized_token(target)
      target.token.should eq(token)
      target.should be_expires
      target.params.keys.should include('foo')
      target.params['foo'].should == 'bar'
    end

    it 'initializes with a Hash' do
      hash = {:access_token => token, :expires_at => Time.now.to_i + 200, 'foo' => 'bar'}
      target = AccessToken.from_hash(client, hash)
      assert_initialized_token(target)
    end

    it 'initalizes with a form-urlencoded key/value string' do
      kvform = "access_token=#{token}&expires_at=#{Time.now.to_i+200}&foo=bar"
      target = AccessToken.from_kvform(client, kvform)
      assert_initialized_token(target)
    end

    it 'sets options' do
      target = AccessToken.new(client, token, :param_name => 'foo', :header_format => 'Bearer %', :mode => :body)
      target.options[:param_name].should == 'foo'
      target.options[:header_format].should == 'Bearer %'
      target.options[:mode].should == :body
    end
  end

  describe '#request' do
    context ':mode => :header' do
      before :all do
        subject.options[:mode] = :header
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          subject.post('/token/header').body.should include(token)
        end
      end
    end

    context ':mode => :query' do
      before :all do
        subject.options[:mode] = :query
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          subject.post('/token/query').body.should == token
        end
      end
    end

    context ':mode => :body' do
      before :all do
        subject.options[:mode] = :body
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          subject.post('/token/body').body.split('=').last.should == token
        end
      end
    end
  end

  describe '#expires?' do
    it 'should be false if there is no expires_at' do
      AccessToken.new(client, token).should_not be_expires
    end

    it 'should be true if there is an expires_in' do
      AccessToken.new(client, token, :refresh_token => 'abaca', :expires_in => 600).should be_expires
    end

    it 'should be true if there is an expires_at' do
      AccessToken.new(client, token, :refresh_token => 'abaca', :expires_in => Time.now.getutc.to_i+600).should be_expires
    end
  end

  describe '#expired?' do
    it 'should be false if there is no expires_in or expires_at' do
      AccessToken.new(client, token).should_not be_expired
    end

    it 'should be false if expires_in is in the future' do
      AccessToken.new(client, token, :refresh_token => 'abaca', :expires_in => 10800).should_not be_expired
    end

    it 'should be true if expires_at is in the past' do
      access = AccessToken.new(client, token, :refresh_token => 'abaca', :expires_in => 600)
      @now = Time.now + 10800
      Time.stub!(:now).and_return(@now)
      access.should be_expired
    end

  end

  describe '#refresh!' do
    it 'returns a refresh token with appropriate values carried over' do
      access = AccessToken.new(client, token, :refresh_token  => 'abaca',
                                              :expires_in     => 600,
                                              :param_name     => 'o_param')
      refreshed = access.refresh!
      access.client.should == refreshed.client
      access.options[:param_name].should == refreshed.options[:param_name]
    end
  end
end
