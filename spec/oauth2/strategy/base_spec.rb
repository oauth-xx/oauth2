require 'helper'

describe OAuth2::Strategy::Base do
  let(:client) { OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com') }
  subject { client.client_credentials }

  it 'initializes with a Client' do
    expect { OAuth2::Strategy::Base.new(OAuth2::Client.new('abc', 'def')) }.not_to raise_error
  end
end
