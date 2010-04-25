require 'spec_helper'

describe OAuth2::Client do
  subject do
    cli = OAuth2::Client.new('abc','def', :site => 'https://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.get('/success')      { |env| [200, {'Content-Type' => 'text/awesome'}, 'yay'] }
        stub.get('/unauthorized') { |env| [401, {}, '']    }
        stub.get('/error')        { |env| [500, {}, '']    }
      end
    end
    cli
  end
  
  describe '#initialize' do
    it 'should assign id and secret' do
      subject.id.should == 'abc'
      subject.secret.should == 'def'
    end
    
    it 'should assign site from the options hash' do
      subject.site.should == 'https://api.example.com'
    end

    it 'should assign Faraday::Connection#host' do
      subject.connection.host.should == 'api.example.com'
    end
  end
  
  %w(authorize access_token).each do |path_type|
    describe "##{path_type}_url" do
      it "should default to a path of /oauth/#{path_type}" do
        subject.send("#{path_type}_url").should == "https://api.example.com/oauth/#{path_type}"
      end
    
      it "should be settable via the :#{path_type}_path option" do
        subject.options[:"#{path_type}_path"] = '/oauth/custom'
        subject.send("#{path_type}_url").should == 'https://api.example.com/oauth/custom'
      end
    
      it "should be settable via the :#{path_type}_url option" do
        subject.options[:"#{path_type}_url"] = 'https://abc.com/authorize'
        subject.send("#{path_type}_url").should == 'https://abc.com/authorize'
      end
    end
  end

  describe "#request" do
    it "returns ResponseString on successful response" do
      response = subject.request(:get, '/success', {}, {})
      response.should == 'yay'
      response.status.should == 200
      response.headers.should == {'Content-Type' => 'text/awesome'}
    end

    it "raises OAuth2::AccessDenied on 401 response" do
      lambda { subject.request(:get, '/unauthorized', {}, {}) }.should raise_error(OAuth2::AccessDenied)
    end

    it "raises OAuth2::HTTPError on error response" do
      lambda { subject.request(:get, '/error', {}, {}) }.should raise_error(OAuth2::HTTPError)
    end
  end

  it '#web_server should instantiate a WebServer strategy with this client' do
    subject.web_server.should be_kind_of(OAuth2::Strategy::WebServer)
  end
end