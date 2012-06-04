require 'helper'

describe OAuth2::Strategy::Implicit do
  let(:client) { OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com') }

  subject {client.implicit}

  describe '#authorize_url' do
    it 'should include the client_id' do
      subject.authorize_url.should be_include('client_id=abc')
    end

    it 'should include the type' do
      subject.authorize_url.should be_include('response_type=token')
    end

    it 'should include passed in options' do
      cb = 'http://myserver.local/oauth/callback'
      subject.authorize_url(:redirect_uri => cb).should be_include("redirect_uri=#{Rack::Utils.escape(cb)}")
    end
  end

  describe "#get_token" do
    it "should raise NotImplementedError" do
      lambda {subject.get_token}.should raise_error(NotImplementedError)
    end
  end
end
