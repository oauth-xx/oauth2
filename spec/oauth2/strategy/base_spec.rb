require 'helper'

describe OAuth2::Strategy::Base do
  it 'initializes with a Client' do
    expect { OAuth2::Strategy::Base.new(OAuth2::Client.new('abc', 'def')) }.not_to raise_error
  end
end
