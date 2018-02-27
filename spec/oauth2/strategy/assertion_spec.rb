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
  
  let(:params) {
    {
      :iss => 'google_api_account_name@developer.gserviceaccount.com',
      :scope => 'https://www.googleapis.com/auth/calendar',
      :aud => 'https://accounts.google.com/o/oauth2/token',
      :exp => Time.now.to_i + 3600,
      :iat => Time.now.to_i,
      :private_key => key
    }
  }

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  describe '#build_request' do
    it 'assembles the request from the given params' do
      request = subject.build_request(params)
      expect(request[:grant_type]).to eq('urn:ietf:params:oauth:grant-type:jwt-bearer')
      expect(request.keys).to match_array [:grant_type, :assertion]
      # TODO: client_id and client_secret were removed -- does this still work?
    end
  end

  describe '#build_assertion' do
    context 'when passed a prn param' do
      before do
        params.merge!(:prn => 'swayze@roadhouse.example.com')
      end
      
      it 'includes it in the claim' do
        expected_claim_keys = %w(iss scope aud exp iat prn)
        assertion = subject.build_assertion(params)

        jwt, _header = JWT.decode(assertion, key.public_key, true, { :algorithm => 'RS256' })
        expect(jwt.keys).to match_array(expected_claim_keys)
        expected_claim_keys.each do |claim_key|
          expect(jwt[claim_key]).to eq(params[claim_key.to_sym])
        end
      end
    end
    
    context 'when not passed a prn param' do
      before do
        expect(params).to_not have_key(:prn)
      end
      
      it 'constructs the claim with no prn key by default' do
        expected_claim_keys = %w(iss scope aud exp iat)
        assertion = subject.build_assertion(params)

        jwt, _header = JWT.decode(assertion, key.public_key, true, { :algorithm => 'RS256' })
        expect(jwt.keys).to match_array(expected_claim_keys)
        expected_claim_keys.each do |claim_key|
          expect(jwt[claim_key]).to eq(params[claim_key.to_sym])
        end
      end
    end

    describe 'JWT encoding' do
      context 'when hmac_secret is passed in' do
        before do
          params.merge!(:hmac_secret => 'thisiskey')
          params.delete(:private_key)
        end
        
        it 'encodes as HS256' do
          assertion = subject.build_assertion(params)
          coded_header = assertion.split('.').first
          header = JWT::Decode.base64url_decode(coded_header)
          expect(MultiJson.decode(header)['alg']).to eq('HS256')
        end
      end
      
      context 'when private_key is passed in' do
        before do
          expect(params[:private_key]).to be
          expect(params).to_not have_key(:hmac_secret)
        end
        
        it 'encodes as RS256' do
          assertion = subject.build_assertion(params)
          coded_header = assertion.split('.').first
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
          expect { subject.build_assertion(params) }.to raise_error(ArgumentError, /hmac_secret or private_key/)
        end
      end
      
      context 'if both private_key and hmac_secret are passed in' do
        before do
          expect(params[:private_key]).to be
          params.merge!(:hmac_secret => 'top_secret')
        end

        it 'defaults to HS256' do
          assertion = subject.build_assertion(params)
          coded_header = assertion.split('.').first
          header = JWT::Decode.base64url_decode(coded_header)
          expect(MultiJson.decode(header)['alg']).to eq('HS256')
        end
      end
    end
  end

  %w(json formencoded).each do |mode|
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
