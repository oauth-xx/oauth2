require 'spec_helper'

describe OAuth2::Strategy::WebServer do
  let(:client) do
    cli = OAuth2::Client.new('abc','def', :site => 'http://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/access_token') do |env| 
          [200, {}, 'a=1&access_token=salmon&refresh_token=trout']
        end
      end
    end
    cli
  end
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
      subject.authorize_url(:redirect_uri => cb).should be_include("redirect_uri=#{Rack::Utils.escape(cb)}")
    end
  end

  describe "#get_access_token" do
    before do
      @access = subject.get_access_token('sushi')
    end

    it 'returns AccessToken with same Client' do
      @access.client.should == client
    end

    it 'returns AccessToken with #token' do
      @access.token.should == 'salmon'
    end

    it 'returns AccessToken with #refresh_token' do
      @access.refresh_token.should == 'trout'
    end
  end
end

describe OAuth2::Strategy::WebServer do
  let(:client) do
    cli = OAuth2::Client.new('abc','def', :site => 'http://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/access_token') do |env| 
          [200, {}, '{"a":"1","access_token":"salmon","refresh_token":"trout"}']
        end
      end
    end
    cli
  end
  subject { client.web_server }

  describe "#get_access_token" do
    before do
      @access = subject.get_access_token('sushi')
    end

    it 'returns AccessToken with #token' do
      @access.token.should == 'salmon'
    end

    it 'returns AccessToken with #refresh_token' do
      @access.refresh_token.should == 'trout'
    end
  end
end
