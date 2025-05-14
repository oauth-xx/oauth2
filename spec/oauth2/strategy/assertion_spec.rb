# frozen_string_literal: true

require "openssl"
require "jwt"

RSpec.describe OAuth2::Strategy::Assertion do
  let(:client_assertion) { client.assertion }

  let(:client) do
    cli = OAuth2::Client.new("abc", "def", site: "http://api.example.com", auth_scheme: auth_scheme)
    cli.connection = Faraday.new(cli.site, cli.options[:connection_opts]) do |b|
      b.request :url_encoded
      b.adapter :test do |stub|
        stub.post("/oauth/token") do |token_request|
          @request_body = Rack::Utils.parse_nested_query(token_request.body).transform_keys(&:to_sym)

          case @response_format
          when "formencoded"
            [200, {"Content-Type" => "application/x-www-form-urlencoded"}, "expires_in=600&access_token=salmon&refresh_token=trout"]
          when "json"
            [200, {"Content-Type" => "application/json"}, '{"expires_in":600,"access_token":"salmon","refresh_token":"trout"}']
          else
            raise "Please define @response_format to choose a response content type!"
          end
        end
      end
    end
    cli
  end

  let(:auth_scheme) { :request_body }

  describe "#authorize_url" do
    it "raises NotImplementedError" do
      expect { client_assertion.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  describe "#get_token" do
    let(:algorithm) { "HS256" }
    let(:key) { "arowana" }
    let(:timestamp) { Time.now.to_i }
    let(:claims) do
      {
        iss: "carp@example.com",
        scope: "https://oauth.example.com/auth/flounder",
        aud: "https://sturgeon.example.com/oauth2/token",
        exp: timestamp + 3600,
        iat: timestamp,
        sub: "12345",
        custom_claim: "ling cod",
      }
    end

    before do
      @response_format = "json"
    end

    describe "assembling a JWT assertion" do
      let(:jwt) do
        payload, header = JWT.decode(@request_body[:assertion], key, true, algorithm: algorithm)
        {payload: payload, header: header}
      end

      let(:payload) { jwt[:payload] }
      let(:header) { jwt[:header] }

      shared_examples_for "encodes the JWT" do
        it "indicates algorithm in the header" do
          expect(header).not_to be_nil
          expect(header["alg"]).to eq(algorithm)
        end

        it "has claims" do
          expect(payload).not_to be_nil
          expect(payload.keys).to match_array(%w[iss scope aud exp iat sub custom_claim])
          payload.each do |key, claim|
            expect(claims[key.to_sym]).to eq(claim)
          end
        end
      end

      context "when encoding as HS256" do
        let(:algorithm) { "HS256" }
        let(:key) { "super_secret!" }

        before do
          client_assertion.get_token(claims, algorithm: algorithm, key: key)
          raise "No request made!" if @request_body.nil?
        end

        it_behaves_like "encodes the JWT"

        context "with real key" do
          let(:key) { "1883be842495c3b58f68ca71fbf1397fbb9ed2fdf8990f8404a25d0a1b995943" }

          it_behaves_like "encodes the JWT"
        end
      end

      context "when encoding as RS256" do
        let(:algorithm) { "RS256" }
        let(:key) { OpenSSL::PKey::RSA.new(1024) }

        before do
          client_assertion.get_token(claims, algorithm: algorithm, key: key)
          raise "No request made!" if @request_body.nil?
        end

        it_behaves_like "encodes the JWT"

        context "with private key" do
          let(:private_key_file) { "spec/fixtures/RS256/jwtRS256.key" }
          let(:password) { "" }
          let(:key) { OpenSSL::PKey::RSA.new(File.read(private_key_file), password) }

          it_behaves_like "encodes the JWT"
        end
      end

      context "with bad encoding params" do
        let(:encoding_opts) { {algorithm: algorithm, key: key} }

        describe "non-supported algorithms" do
          let(:algorithm) { "the blockchain" }
          let(:key) { "machine learning" }

          it "raises JWT::EncodeError" do
            # this behavior is handled by the JWT gem, but this should make sure it is consistent
            # On old Ruby (versions 2.4 and below) the error raised was different because
            #   an old version (< v2.4) of the jwt gem gets installed.
            if Gem::Version.create(JWT::VERSION::STRING) >= Gem::Version.create("2.4")
              expect { client_assertion.get_token(claims, encoding_opts) }.to raise_error(JWT::EncodeError, "Unsupported signing method")
            else
              expect { client_assertion.get_token(claims, encoding_opts) }.to raise_error(NotImplementedError)
            end
          end
        end

        describe "of a wrong object type" do
          let(:encoding_opts) { "the cloud" }

          it "raises ArgumentError" do
            expect { client_assertion.get_token(claims, encoding_opts) }.to raise_error(ArgumentError, /encoding_opts/)
          end
        end

        describe "missing encoding_opts[:algorithm]" do
          before do
            encoding_opts.delete(:algorithm)
          end

          it "raises ArgumentError" do
            expect { client_assertion.get_token(claims, encoding_opts) }.to raise_error(ArgumentError, /encoding_opts/)
          end
        end

        describe "missing encoding_opts[:key]" do
          before do
            encoding_opts.delete(:key)
          end

          it "raises ArgumentError" do
            expect { client_assertion.get_token(claims, encoding_opts) }.to raise_error(ArgumentError, /encoding_opts/)
          end
        end
      end
    end

    describe "POST request parameters" do
      context "when using :auth_scheme => :request_body" do
        let(:auth_scheme) { :request_body }

        it "includes assertion and grant_type, along with the client parameters" do
          client_assertion.get_token(claims, algorithm: algorithm, key: key)
          expect(@request_body).not_to be_nil
          expect(@request_body.keys).to match_array(%i[assertion grant_type client_id client_secret])
          expect(@request_body[:grant_type]).to eq("urn:ietf:params:oauth:grant-type:jwt-bearer")
          expect(@request_body[:assertion]).to be_a(String)
          expect(@request_body[:client_id]).to eq("abc")
          expect(@request_body[:client_secret]).to eq("def")
        end

        it "includes other params via request_options" do
          client_assertion.get_token(claims, {algorithm: algorithm, key: key}, {scope: "dover sole"})
          expect(@request_body).not_to be_nil
          expect(@request_body.keys).to match_array(%i[assertion grant_type scope client_id client_secret])
          expect(@request_body[:grant_type]).to eq("urn:ietf:params:oauth:grant-type:jwt-bearer")
          expect(@request_body[:assertion]).to be_a(String)
          expect(@request_body[:scope]).to eq("dover sole")
          expect(@request_body[:client_id]).to eq("abc")
          expect(@request_body[:client_secret]).to eq("def")
        end
      end

      context "when using :auth_scheme => :basic_auth" do
        let(:auth_scheme) { :basic_auth }

        it "includes assertion and grant_type by default" do
          client_assertion.get_token(claims, algorithm: algorithm, key: key)
          expect(@request_body).not_to be_nil
          expect(@request_body.keys).to match_array(%i[assertion grant_type])
          expect(@request_body[:grant_type]).to eq("urn:ietf:params:oauth:grant-type:jwt-bearer")
          expect(@request_body[:assertion]).to be_a(String)
        end

        it "includes other params via request_options" do
          client_assertion.get_token(claims, {algorithm: algorithm, key: key}, {scope: "dover sole"})
          expect(@request_body).not_to be_nil
          expect(@request_body.keys).to match_array(%i[assertion grant_type scope])
          expect(@request_body[:grant_type]).to eq("urn:ietf:params:oauth:grant-type:jwt-bearer")
          expect(@request_body[:assertion]).to be_a(String)
          expect(@request_body[:scope]).to eq("dover sole")
        end
      end
    end

    describe "returning the response" do
      let(:access_token) { client_assertion.get_token(claims, {algorithm: algorithm, key: key}, {}, response_opts) }
      let(:response_opts) { {} }

      %w[json formencoded].each do |mode|
        context "when the content type is #{mode}" do
          before do
            @response_format = mode
          end

          it "returns an AccessToken" do
            expect(access_token).to be_an(OAuth2::AccessToken)
          end

          it "returns AccessToken with same Client" do
            expect(access_token.client).to eq(client)
          end

          it "returns AccessToken with #token" do
            expect(access_token.token).to eq("salmon")
          end

          it "returns AccessToken with #expires_in" do
            expect(access_token.expires_in).to eq(600)
          end

          it "returns AccessToken with #expires_at" do
            expect(access_token.expires_at).not_to be_nil
          end

          it "sets AccessToken#refresh_token to nil" do
            expect(access_token.refresh_token).to eq("trout")
          end

          context "with custom response_opts" do
            let(:response_opts) { {"custom_token_option" => "mackerel"} }

            it "passes them into the token params" do
              expect(access_token.params).to eq(response_opts)
            end
          end

          context "when no custom opts are passed in" do
            let(:response_opts) { {} }

            it "does not set any params by default" do
              expect(access_token.params).to eq({})
            end
          end
        end
      end
    end
  end
end
