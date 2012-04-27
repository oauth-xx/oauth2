require 'helper'

describe OAuth2::Strategy::AuthCode do
  let(:code) {'sushi'}
  let(:kvform_token) {'expires_in=600&access_token=salmon&refresh_token=trout&extra_param=steve'}
  let(:facebook_token) {kvform_token.gsub('_in', '')}
  let(:json_token) {MultiJson.encode(:expires_in => 600, :access_token => 'salmon', :refresh_token => 'trout', :extra_param => 'steve')}

  let(:client) do
    OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com') do |builder|
      builder.adapter :test do |stub|
        stub.get("/oauth/token?client_id=abc&client_secret=def&code=#{code}&grant_type=authorization_code") do |env|
          case @mode
          when "formencoded"
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, kvform_token]
          when "json"
            [200, {'Content-Type' => 'application/json'}, json_token]
          when "from_facebook"
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, facebook_token]
          end
        end
        stub.post('/oauth/token', {'client_id' => 'abc', 'client_secret' => 'def', 'code' => 'sushi', 'grant_type' => 'authorization_code'}) do |env|
          case @mode
          when "formencoded"
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, kvform_token]
          when "json"
            [200, {'Content-Type' => 'application/json'}, json_token]
          when "from_facebook"
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, facebook_token]
          end
        end
      end
    end
  end

  subject {client.auth_code}

  describe '#authorize_url' do
    it 'should include the client_id' do
      subject.authorize_url.should be_include('client_id=abc')
    end

    it 'should include the type' do
      subject.authorize_url.should be_include('response_type=code')
    end

    it 'should include passed in options' do
      cb = 'http://myserver.local/oauth/callback'
      subject.authorize_url(:redirect_uri => cb).should be_include("redirect_uri=#{Rack::Utils.escape(cb)}")
    end
  end

  %w(json formencoded from_facebook).each do |mode|
    [:get, :post].each do |verb|
      describe "#get_token (#{mode}, access_token_method=#{verb}" do
        before :each do
          @mode = mode
          client.options[:token_method] = verb
          @access = subject.get_token(code)
        end

        it 'returns AccessToken with same Client' do
          @access.client.should == client
        end

        it 'returns AccessToken with #token' do
          @access.token.should == 'salmon'
        end

        it 'returns AccessToken with #refresh_token' do
          @access.refresh_token.should == 'trout'
        end

        it 'returns AccessToken with #expires_in' do
          @access.expires_in.should == 600
        end

        it 'returns AccessToken with #expires_at' do
          @access.expires_at.should be_kind_of(Integer)
        end

        it 'returns AccessToken with params accessible via []' do
          @access['extra_param'].should == 'steve'
        end
      end
    end
  end
end
