require 'openssl'

describe OAuth2::Strategy::Assertion do
  let(:client_assertion) { client.assertion }

  let(:client) do
    cli = OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com')
    cli.connection = Faraday.new(cli.site, cli.options[:connection_opts]) do |b|
      b.request :url_encoded
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

  let(:params) do
    {
      :hmac_secret => 'foo',
      :exp => Time.now.utc.to_i + 3600,
    }
  end

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { client_assertion.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  %w[json formencoded].each do |mode|
    before { @mode = mode }

    shared_examples_for "get_token #{mode}" do
      describe "#get_token (#{mode})" do
        subject(:get_token) { client_assertion.get_token(params) }

        it 'returns AccessToken with same Client' do
          expect(get_token.client).to eq(client)
        end

        it 'returns AccessToken with #token' do
          expect(get_token.token).to eq('salmon')
        end

        it 'returns AccessToken with #expires_in' do
          expect(get_token.expires_in).to eq(600)
        end

        it 'returns AccessToken with #expires_at' do
          expect(get_token.expires_at).not_to be_nil
        end
      end
    end

    it_behaves_like "get_token #{mode}"
    describe "#build_assertion (#{mode})" do
      context 'with hmac_secret' do
        subject(:build_assertion) { client_assertion.build_assertion(params) }

        let(:hmac_secret) { '1883be842495c3b58f68ca71fbf1397fbb9ed2fdf8990f8404a25d0a1b995943' }
        let(:params) do
          {
            :iss => 2345,
            :aud => 'too',
            :prn => 'much',
            :exp => 123_456_789,
            :hmac_secret => hmac_secret,
          }
        end
        let(:jwt) { 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOjIzNDUsImF1ZCI6InRvbyIsInBybiI6Im11Y2giLCJleHAiOjEyMzQ1Njc4OX0.GnZjgcdc5WSWKNW0p9S4GuhpBs3LJCEqjPm6turLG-c' }

        it 'returns JWT' do
          expect(build_assertion).to eq(jwt)
        end

        it_behaves_like "get_token #{mode}"
      end

      context 'with private_key' do
        subject(:build_assertion) { client_assertion.build_assertion(params) }

        let(:private_key_file) { 'spec/fixtures/RS256/jwtRS256.key' }
        let(:password) { '' }
        let(:private_key) { OpenSSL::PKey::RSA.new(File.read(private_key_file), password) }
        let(:params) do
          {
            :iss => 2345,
            :aud => 'too',
            :prn => 'much',
            :exp => 123_456_789,
            :private_key => private_key,
          }
        end
        let(:jwt) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOjIzNDUsImF1ZCI6InRvbyIsInBybiI6Im11Y2giLCJleHAiOjEyMzQ1Njc4OX0.vJ32OiPVMdJrlNkPw02Y9u6beiFY0Mfndhg_CkEDLtOYn8dscQIEpWoR4GzH8tiQVOQ1fOkqxE95tNIKOTjnIoskmYnfzhzIl9fnfQ_lsEuLC-nq45KhPzSM2wYgF2ZEIjDq51daK70bRPzTBr1Id45cTY-jJSito0lbKXj2nPa_Gs-_vyEU2MSxjiMaIxxccfY4Ow5zN3AUMTKp6LjrpDKFxag3fJ1nrb6iDATa504gyJHVLift3ovhAwYidkA81WnmEtISWBY904CKIcZD9Cx3ifS5bc3JaLAteIBKAAyD8o7D60vOKutsjCMHUCKL357BQ36bW7fmaEtW367Ri-xgOsCY0_HeWp991vrJ-DxhFPeuF-8hn_9KggBzKbA2eKEOOY4iDKSFwjWQUFOcRdvHw9RgbGt0IjY3wdo8CaJVlhynh54YlaLgOFhTBPeMgZdqQUHOztljaK9zubeVkrDGNnGuSuq0KR82KArb1x2z7XyZpxiV5ZatP9SNyhn-YIWk7UeQYXaS0UfsBX7L5T1y_FZj84r7Vl42lj1DfdR5DyGvHfZyHotTnejdIrDuQfDL_bGe24eHsilzuEFaajYmu10hxflZ6Apm-lekRRV47tbxTF1zI5we14XsTeklrTXqgDkSw6gyOoNUJm-cQkJpfdvBgUHYGInC1ttz7NU' }

        it 'returns JWT' do
          expect(build_assertion).to eq(jwt)
        end

        it_behaves_like "get_token #{mode}"
      end
    end
  end
end
