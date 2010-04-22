require 'spec_helper'

describe OAuth2::Strategy::WebServer do
  let(:client){ OAuth2::Client.new('abc','def', :site => 'http://api.example.com') }
  subject { client.web_server }
  describe '#authorize_url' do
    it 'should include the client_id' do
      subject.authorize_url.should be_include('client_id=abc')
    end
    
    it 'should include the type' do
      subject.authorize_url.should be_include('type=web_server')
    end
    
    it 'should include passed in options' do
      cb = 'http://myserver.local/oauth/callback'
      subject.authorize_url(:redirect_uri => cb).should be_include("redirect_uri=#{CGI.escape(cb)}")
    end
  end
end