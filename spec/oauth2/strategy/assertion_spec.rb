require 'jwt'

RSpec.describe OAuth2::Strategy::Assertion do
  subject { client.assertion }

  let(:client) do
    cli = OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/token') do |env|
          @request_body = env.body
          
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

  let(:algorithm) { 'HS256' }
  let(:key) { 'arowana' }
  let(:timestamp) { Time.now.to_i }
  let(:claims) do
    {
      :iss => 'carp@example.com',
      :scope => 'https://oauth.example.com/auth/flounder',
      :aud => 'https://sturgeon.example.com/oauth2/token',
      :exp => timestamp + 3600,
      :iat => timestamp,
      :sub => '12345',
      :custom_claim => 'ling cod',
    }
  end

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  describe '#get_token' do
    before do
      @mode = 'json'
    end
    
    describe 'JWT assertion' do
      context 'when encoding as HS256' do
        let(:algorithm) { 'HS256' }
        let(:key) { 'super_secret!' }
        
        before do
          subject.get_token(claims, algorithm, key)
          expect(@request_body).not_to be_nil
          expect(@request_body[:assertion]).not_to be_nil
        end

        it 'indicates HS256 in the header' do
          coded_header = @request_body[:assertion].split('.').first
          header = JWT::Decode.base64url_decode(coded_header)
          expect(MultiJson.decode(header)['alg']).to eq('HS256')
        end
        
        it 'encodes the JWT as HS256' do
          jwt, _header = JWT.decode(@request_body[:assertion], key, true, :algorithm => algorithm)
          expect(jwt.keys).to match_array(%w[iss scope aud exp iat sub custom_claim])
          jwt.each do |key, claim|
            expect(claims[key.to_sym]).to eq(claim)
          end
        end
      end
      
      context 'when encoding as RS256' do
        let(:algorithm) { 'RS256' }
        let(:key) { OpenSSL::PKey::RSA.new(1024) }

        before do
          subject.get_token(claims, algorithm, key)
          expect(@request_body).not_to be_nil
          expect(@request_body[:assertion]).not_to be_nil
        end

        it 'indicates RS256 in the header' do
          coded_header = @request_body[:assertion].split('.').first
          header = JWT::Decode.base64url_decode(coded_header)
          expect(MultiJson.decode(header)['alg']).to eq('RS256')
        end

        it 'encodes the JWT as RS256' do
          jwt, _header = JWT.decode(@request_body[:assertion], key, true, :algorithm => algorithm)
          expect(jwt.keys).to match_array(%w[iss scope aud exp iat sub custom_claim])
          jwt.each do |key, claim|
            expect(claims[key.to_sym]).to eq(claim)
          end
        end
      end
      
      context 'with bad encoding params' do
        let(:algorithm) { 'the blockchain' }
        let(:key) { 'machine learning' }
        
        it 'raises' do
          # this behavior is handled by the JWT gem, but this should make sure it is consistent
          expect { subject.get_token(claims, algorithm, key) }.to raise_error
        end
      end
    end

    describe 'POST request parameters' do
      it 'includes assertion and grant_type by default' do
        subject.get_token(claims, algorithm, key)
        expect(@request_body).not_to be_nil
        expect(@request_body.keys).to match_array([:assertion, :grant_type])
        expect(@request_body[:grant_type]).to eq('urn:ietf:params:oauth:grant-type:jwt-bearer')
        expect(@request_body[:assertion]).to be_a(String) # tested in detail in JWT assertion contexts
      end

      it 'includes others via request_options' do
        subject.get_token(claims, algorithm, key, {:scope => 'dover sole'})
        expect(@request_body).not_to be_nil
        expect(@request_body.keys).to match_array([:assertion, :grant_type, :scope])
        expect(@request_body[:grant_type]).to eq('urn:ietf:params:oauth:grant-type:jwt-bearer')
        expect(@request_body[:assertion]).to be_a(String) # tested in detail in JWT assertion contexts
        expect(@request_body[:scope]).to eq('dover sole')
      end
    end
    
    describe 'AccessToken options' do
      it 'sets refresh_token to nil' do
        token = subject.get_token(claims, algorithm, key)
        expect(token).to be_an(AccessToken)
        expect(token.params).to eq({})
        expect(token.refresh_token).to eq(nil)
      end
      
      it 'passes custom opts via request_options' do
        custom_token_option = {:custom_token_option => 'mackerel'}
        token = subject.get_token(claims, algorithm, key, {}, custom_token_option)
        expect(token).to be_an(AccessToken)
        expect(token.params).to eq(custom_token_option)
      end
    end

    describe 'response type' do
      %w[json formencoded].each do |mode|
        context "when #{mode}" do
          before do
            @mode = mode
            @access = subject.get_token(claims, algorithm, key)
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
  end
end
