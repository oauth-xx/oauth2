require 'helper'

describe OAuth2::Strategy::Base do
  let(:client) { OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com') }
  subject { client.client_credentials }

  it 'initializes with a Client' do
    expect { OAuth2::Strategy::Base.new(OAuth2::Client.new('abc', 'def')) }.not_to raise_error
  end

  describe '#client_params' do
    let(:basic_auth) { {:headers => {'Authorization' => subject.authorization(client.id, client.secret)}} }
    let(:request_body) { {'client_id' => client.id, 'client_secret' => client.secret} }

    it 'generates header values with no explicit auth scheme' do
      expect(subject.client_params).to eq(basic_auth)
    end

    context 'with auth_scheme=basic_auth' do
      let(:client) { OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com', :auth_scheme => :basic_auth) }

      it 'generates header values' do
        expect(subject.client_params).to eq(basic_auth)
      end
    end

    context 'with auth_scheme=request_body' do
      let(:client) { OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com', :auth_scheme => :request_body) }

      it 'generates body values' do
        expect(subject.client_params).to eq(request_body)
      end
    end
  end

  describe '#authorization' do
    it 'generates an Authorization header value for HTTP Basic Authentication' do
      [
        ['abc', 'def', 'Basic YWJjOmRlZg=='],
        ['xxx', 'secret', 'Basic eHh4OnNlY3JldA=='],
      ].each do |client_id, client_secret, expected|
        expect(subject.authorization(client_id, client_secret)).to eq(expected)
      end
    end
  end
end
