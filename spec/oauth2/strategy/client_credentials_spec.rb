require 'helper'

describe OAuth2::Strategy::ClientCredentials do
  let(:kvform_token) { 'expires_in=600&access_token=salmon&refresh_token=trout' }
  let(:json_token) { '{"expires_in":600,"access_token":"salmon","refresh_token":"trout"}' }

  let(:client) do
    OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com') do |builder|
      builder.adapter :test do |stub|
        stub.post('/oauth/token', 'grant_type' => 'client_credentials') do |env|
          client_id, client_secret = Base64.decode64(env[:request_headers]['Authorization'].split(' ', 2)[1]).split(':', 2)
          client_id == 'abc' && client_secret == 'def' || fail(Faraday::Adapter::Test::Stubs::NotFound)
          case @mode
          when 'formencoded'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, kvform_token]
          when 'json'
            [200, {'Content-Type' => 'application/json'}, json_token]
          end
        end
        stub.post('/oauth/token', 'client_id' => 'abc', 'client_secret' => 'def', 'grant_type' => 'client_credentials') do |env|
          case @mode
          when 'formencoded'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, kvform_token]
          when 'json'
            [200, {'Content-Type' => 'application/json'}, json_token]
          end
        end
      end
    end
  end

  subject { client.client_credentials }

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  describe '#authorization' do
    it 'generates an Authorization header value for HTTP Basic Authentication' do
      [
        ['abc', 'def', 'Basic YWJjOmRlZg=='],
        ['xxx', 'secret', 'Basic eHh4OnNlY3JldA==']
      ].each do |client_id, client_secret, expected|
        expect(subject.authorization(client_id, client_secret)).to eq(expected)
      end
    end
  end

  %w(json formencoded).each do |mode|
    %w(default basic_auth request_body).each do |auth_scheme|
      describe "#get_token (#{mode}) (#{auth_scheme})" do
        before do
          @mode = mode
          @access = subject.get_token({}, auth_scheme == 'default' ? {} : {'auth_scheme' => auth_scheme})
        end

        it 'returns AccessToken with same Client' do
          expect(@access.client).to eq(client)
        end

        it 'returns AccessToken with #token' do
          expect(@access.token).to eq('salmon')
        end

        it 'returns AccessToken without #refresh_token' do
          expect(@access.refresh_token).to be_nil
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
