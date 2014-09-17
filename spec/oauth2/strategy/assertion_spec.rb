require 'helper'

describe OAuth2::Strategy::Assertion do
  let(:client) do
    cli = OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/token') do |env|
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

  let(:params) { {:hmac_secret => 'foo'} }

  subject { client.assertion }

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode})" do
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

  describe '#build_assertion' do

    # Claim base params
    let(:claim) do
      {
        :iss => 'some issuer',
        :aud => 'some audience',
        :prn => 'some principal',
        :exp => Time.now.utc.to_i + 3600,
      }
    end

    let(:secret) { 'secret string' }
    let(:params) { claim.merge(:hmac_secret => secret) }
    let(:other_params) { {:iat => Time.now.utc.to_i - 60} }

    it 'builds the assertion with all params but secret' do
      expect(JWT).to receive(:encode).with(claim, secret, 'HS256')
      subject.build_assertion(params)
    end

    it 'raises without :private_key or :hmac_secret' do
      expect { subject.build_assertion(claim) }.to raise_error ArgumentError, /:private_key or :hmac_secret/
    end

  end

end
