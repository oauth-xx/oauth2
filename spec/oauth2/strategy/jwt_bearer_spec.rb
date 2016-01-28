require 'helper'

describe OAuth2::Strategy::JWTBearer do
  let(:client) do
    cli = OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/token') do |_env|
          case @mode
          when 'formencoded'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, 'expires_in=600&access_token=salmon&refresh_token=trout']
          when 'json'
            [200, {'Content-Type' => 'application/json'}, '{"expires_in":600,"access_token":"salmon","refresh_token":"trout"}']
          end
        end
      end
    end
    cli
  end

  subject { client.jwt_bearer }

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode}) HS256" do
      let(:params) { {:hmac_secret => 'foo'} }

      before do
        @mode = mode
        @access = subject.get_token(params)
      end

      it 'returns AccessToken with same Client' do
        expect(@access.client).to eq(client)
      end

      it 'returns AccessToken with #token' do
        expect(@access.token).to eq('salmon')
      end

      it 'returns AccessToken with #expires_in' do
        expect(@access.expires_in).to eq(600)
      end

      it 'returns AccessToken with #expires_at' do
        expect(@access.expires_at).not_to be_nil
      end
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode}) HS512" do
      let(:params) { {:hmac_secret => 'foo', :algorithm => 'HS512'} }

      before do
        @mode = mode
        @access = subject.get_token(params)
      end

      it 'returns AccessToken with same Client' do
        expect(@access.client).to eq(client)
      end

      it 'returns AccessToken with #token' do
        expect(@access.token).to eq('salmon')
      end

      it 'returns AccessToken with #expires_in' do
        expect(@access.expires_in).to eq(600)
      end

      it 'returns AccessToken with #expires_at' do
        expect(@access.expires_at).not_to be_nil
      end
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode}) RS256" do
      let(:params) { {:private_key => OpenSSL::PKey::RSA.generate(512)} }

      before do
        @mode = mode
        @access = subject.get_token(params)
      end

      it 'returns AccessToken with same Client' do
        expect(@access.client).to eq(client)
      end

      it 'returns AccessToken with #token' do
        expect(@access.token).to eq('salmon')
      end

      it 'returns AccessToken with #expires_in' do
        expect(@access.expires_in).to eq(600)
      end

      it 'returns AccessToken with #expires_at' do
        expect(@access.expires_at).not_to be_nil
      end
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode}) RS512" do
      let(:params) { {:private_key => OpenSSL::PKey::RSA.generate(1024), :algorithm => 'RS512'} }

      before do
        @mode = mode
        @access = subject.get_token(params)
      end

      it 'returns AccessToken with same Client' do
        expect(@access.client).to eq(client)
      end

      it 'returns AccessToken with #token' do
        expect(@access.token).to eq('salmon')
      end

      it 'returns AccessToken with #expires_in' do
        expect(@access.expires_in).to eq(600)
      end

      it 'returns AccessToken with #expires_at' do
        expect(@access.expires_at).not_to be_nil
      end
    end
  end
end
