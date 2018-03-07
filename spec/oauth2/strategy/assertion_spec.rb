require 'jwt'

RSpec.describe OAuth2::Strategy::Assertion do
  subject { client.assertion }

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

  let(:key) { OpenSSL::PKey::RSA.new(1024) }
  let(:timestamp) { Time.now.to_i }
  let(:params) do
    {
      :url_params => {
        :custom_param => 'mackerel',
        :scope => 'sole',
      },

      :claims => {
        :iss => 'carp@example.com',
        :scope => 'https://oauth.example.com/auth/flounder',
        :aud => 'https://sturgeon.example.com/oauth2/token',
        :exp => timestamp + 3600,
        :iat => timestamp,
        :sub => '12345',
        :custom_claim => 'ling cod',
      },

      :private_key => key,
    }
  end

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  describe '#build_request' do
    let(:request) { subject.build_request(params) }

    it 'assembles the request body params from params[:url_params] and the claims from params[:claims]' do
      expect(request.keys).to match_array [:grant_type, :assertion, :custom_param, :scope]
      expect(request[:grant_type]).to eq('urn:ietf:params:oauth:grant-type:jwt-bearer')
      expect(request[:custom_param]).to eq('mackerel')
      expect(request[:scope]).to eq('sole')
      expect(request[:assertion]).not_to be_nil

      jwt, _header = JWT.decode(request[:assertion], key.public_key, true, :algorithm => 'RS256')

      expect(params[:claims].keys).to match_array(jwt.keys.map(&:to_sym))
      params[:claims].each do |key, claim|
        expect(jwt[key.to_s]).to eq(claim)
      end
    end

    context 'when hmac_secret is passed in' do
      before do
        params.merge!(:hmac_secret => 'thisiskey')
        params.delete(:private_key)
      end

      it 'encodes the JWT as HS256' do
        coded_header = request[:assertion].split('.').first
        header = JWT::Decode.base64url_decode(coded_header)
        expect(MultiJson.decode(header)['alg']).to eq('HS256')
      end
    end

    context 'when private_key is passed in' do
      before do
        expect(params[:private_key]).to be
        expect(params).to_not have_key(:hmac_secret)
      end

      it 'encodes the JWT as RS256' do
        coded_header = request[:assertion].split('.').first
        header = JWT::Decode.base64url_decode(coded_header)
        expect(MultiJson.decode(header)['alg']).to eq('RS256')
      end
    end

    context 'when neither private_key nor hmac_secret is passed in' do
      before do
        params.delete(:private_key)
        expect(params).to_not have_key(:hmac_secret)
      end

      it 'raises an argument error' do
        expect { subject.build_request(params) }.to raise_error(ArgumentError, /hmac_secret or private_key/)
      end
    end

    context 'when both private_key and hmac_secret are passed in' do
      before do
        expect(params[:private_key]).to be
        params.merge!(:hmac_secret => 'top_secret')
      end

      it 'defaults to HS256' do
        coded_header = request[:assertion].split('.').first
        header = JWT::Decode.base64url_decode(coded_header)
        expect(MultiJson.decode(header)['alg']).to eq('HS256')
      end
    end
  end

  %w[json formencoded].each do |mode|
    describe "#get_token (#{mode})" do
      let(:params) { { :hmac_secret => "#{mode}-foo" } }

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
