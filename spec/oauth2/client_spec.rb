require 'spec_helper'

describe OAuth2::Client do
  subject{ OAuth2::Client.new('abc','def', :site => 'https://api.example.com')}
  
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
  
  it '#web_server should instantiate a WebServer strategy with this client' do
    subject.web_server.should be_kind_of(OAuth2::Strategy::WebServer)
  end
end