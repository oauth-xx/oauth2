# encoding: utf-8
# frozen_string_literal: true

describe OAuth2::Strategy::AuthCode do
  subject { client.auth_code }

  let(:code) { 'sushi' }
  let(:kvform_token) { 'expires_in=600&access_token=salmon&refresh_token=trout&extra_param=steve' }
  let(:facebook_token) { kvform_token.gsub('_in', '') }
  let(:json_token) { MultiJson.encode(:expires_in => 600, :access_token => 'salmon', :refresh_token => 'trout', :extra_param => 'steve') }

  let(:client) do
    OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com') do |builder|
      builder.adapter :test do |stub|
        stub.get("/oauth/token?client_id=abc&client_secret=def&code=#{code}&grant_type=authorization_code") do |env|
          case @mode
          when 'formencoded'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, kvform_token]
          when 'json'
            [200, {'Content-Type' => 'application/json'}, json_token]
          when 'from_facebook'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, facebook_token]
          end
        end
        stub.post('/oauth/token', 'client_id' => 'abc', 'client_secret' => 'def', 'code' => 'sushi', 'grant_type' => 'authorization_code') do |env|
          case @mode
          when 'formencoded'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, kvform_token]
          when 'json'
            [200, {'Content-Type' => 'application/json'}, json_token]
          when 'from_facebook'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, facebook_token]
          end
        end
      end
    end
  end

  describe '#authorize_url' do
    it 'includes the client_id' do
      expect(subject.authorize_url).to include('client_id=abc')
    end

    it 'includes the type' do
      expect(subject.authorize_url).to include('response_type=code')
    end

    it 'includes passed in options' do
      cb = 'http://myserver.local/oauth/callback'
      expect(subject.authorize_url(:redirect_uri => cb)).to include("redirect_uri=#{Rack::Utils.escape(cb)}")
    end
  end

  describe '#get_token (handling utf-8 data)' do
    let(:json_token) { MultiJson.encode(:expires_in => 600, :access_token => 'salmon', :refresh_token => 'trout', :extra_param => 'André') }

    before do
      @mode = 'json'
      client.options[:token_method] = :post
    end

    it 'does not raise an error' do
      expect { subject.get_token(code) }.not_to raise_error
    end

    it 'does not create an error instance' do
      expect(OAuth2::Error).not_to receive(:new)

      subject.get_token(code)
    end
  end

  %w[json formencoded from_facebook].each do |mode|
    [:get, :post].each do |verb|
      describe "#get_token (#{mode}, access_token_method=#{verb}" do
        before do
          @mode = mode
          client.options[:token_method] = verb
          @access = subject.get_token(code)
        end

        it 'returns AccessToken with same Client' do
          expect(@access.client).to eq(client)
        end

        it 'returns AccessToken with #token' do
          expect(@access.token).to eq('salmon')
        end

        it 'returns AccessToken with #refresh_token' do
          expect(@access.refresh_token).to eq('trout')
        end

        it 'returns AccessToken with #expires_in' do
          expect(@access.expires_in).to eq(600)
        end

        it 'returns AccessToken with #expires_at' do
          expect(@access.expires_at).to be_kind_of(Integer)
        end

        it 'returns AccessToken with params accessible via []' do
          expect(@access['extra_param']).to eq('steve')
        end
      end
    end
  end
end
