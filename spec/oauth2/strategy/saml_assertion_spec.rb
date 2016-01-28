require 'helper'

describe OAuth2::Strategy::SamlAssertion do
  let(:client) { OAuth2::Client.new('123', 'def') }
  let(:token_value) { 'token123' }
  let(:assertion) { 'assertion' }

  it 'should throw an exception when checking authorize_url' do
    expect { client.saml_assertion.authorize_url }.to raise_error(NotImplementedError)
  end

  it 'should merge params with client params' do
    cli = client
    expect(cli).to receive(:get_token).and_return token_value
    token = described_class.new(cli).get_token(:assertion => assertion)

    expect(token).to be token_value
  end

  it 'should set refresh token to nil as default option' do
    cli = client
    expect(cli).to receive(:get_token) { |_hash, options|
      expect(options).to eq('refresh_token' => nil)
    }.and_return token_value

    described_class.new(cli).get_token({})
  end

  it 'should merge options with refresh token being nil' do
    cli = client
    expect(cli).to receive(:get_token) { |_hash, options|
      expect(options).to eq(:auth_scheme => 'body', 'refresh_token' => nil)
    }.and_return token_value

    described_class.new(cli).get_token({}, :auth_scheme => 'body')
  end
end
