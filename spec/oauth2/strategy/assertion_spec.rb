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

  let(:params) { {:hmac_secret => 'foo'} }

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  context "when putting together a request" do
    before do
      @key = OpenSSL::PKey::RSA.new(1024)
      @params = {:iss => 'google_api_account_name@developer.gserviceaccount.com',
        :scope => 'https://www.googleapis.com/auth/calendar',
        :aud => 'https://accounts.google.com/o/oauth2/token',
        :exp => Time.now.to_i + 3600,
        :iat => Time.now.to_i,
        :private_key => @key}
    end

    describe "#build_request" do
      it "assembles the request from the given params" do
        request = subject.build_request(@params)
        expect(request[:grant_type]).to eq('urn:ietf:params:oauth:grant-type:jwt-bearer')
        expect(request.keys).to match_array [:grant_type, :assertion, "client_id", "client_secret"]
      end
    end

    describe "#build_assertion" do
      it "applies the parameters and constructs the claims" do
        assertion = subject.build_assertion(@params)

        claim_keys = %w(iss scope aud exp iat)
        jwt, _header = JWT.decode(assertion, @key.public_key)
        expect(jwt.keys).to match_array(claim_keys)
        claim_keys.each do |claim_key|
          expect(jwt[claim_key]).to eq(@params[claim_key.to_sym])
        end
      end

      it "optionally applies the prn param" do
        assertion = subject.build_assertion(@params.merge!(:prn => 'swayze@roadhouse.com'))

        claim_keys = %w(iss scope aud exp iat prn)
        jwt, _header = JWT.decode(assertion, @key.public_key)
        expect(jwt.keys).to match_array(claim_keys)
        claim_keys.each do |claim_key|
          expect(jwt[claim_key]).to eq(@params[claim_key.to_sym])
        end
      end

      describe "JWT encoding" do
        it "encodes as HS256 when hmac_secret is passed in" do
          @params.merge!(:hmac_secret => 'thisiskey')
          @params.delete(:private_key)

          expect(@params[:private_key]).to_not be
          expect(@params[:hmac_secret]).to be

          assertion = subject.build_assertion(@params)
          header = MultiJson.decode(JWT.base64url_decode(assertion.split('.').first))
          expect(header['alg']).to eq('HS256')
        end

        it "encodes as RS256 when private_key is passed in" do
          expect(@params[:private_key]).to be
          expect(@params[:hmac_secret]).to_not be

          assertion = subject.build_assertion(@params)
          header = MultiJson.decode(JWT.base64url_decode(assertion.split('.').first))
          expect(header['alg']).to eq('RS256')
        end

        it "raises an argument error when nothing is passed in" do
          @params.delete(:private_key)

          expect(@params[:private_key]).to_not be
          expect(@params[:hmac_secret]).to_not be

          expect(lambda{ subject.build_assertion(@params) }).to raise_error(ArgumentError, /hmac_secret or private_key/)
        end
      end
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
end
