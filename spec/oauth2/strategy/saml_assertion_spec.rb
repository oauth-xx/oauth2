require 'helper'

describe OAuth2::Strategy::SamlAssertion do
  let(:client) { double('client', id: '123', secret: 'def') }
  let(:token_value) { 'token123' }
  let(:assertion) { 'assertion' }

  it 'should merge params with client params' do
    expect(client).to receive(:get_token) { |hash, _options|
      expect(hash).to eq(assertion: assertion, 'client_id' => '123', 'client_secret' => 'def')
    }.and_return token_value

    token = described_class.new(client).get_token(assertion: assertion)

    expect(token).to be token_value
  end

  it 'should set refresh token to nil as default option' do
    expect(client).to receive(:get_token) { |_hash, options|
      expect(options).to eq('refresh_token' => nil)
    }.and_return token_value

    described_class.new(client).get_token({})
  end

  it 'should merge options with refresh token being nil' do
    expect(client).to receive(:get_token) { |_hash, options|
      expect(options).to eq(auth_scheme: 'body', 'refresh_token' => nil)
    }.and_return token_value

    described_class.new(client).get_token({}, auth_scheme: 'body')
  end
end