require 'spec_helper'

describe OAuth2::Response do

  describe '#initialize' do
    let(:status) { 200 }
    let(:headers) { { 'foo' => 'bar' } }
    let(:body) { 'foo' }

    it 'returns the status, headers and body' do
      response = double('response', :headers  => headers,
                                    :status   => status,
                                    :body     => body)
      subject = Response.new(response)
      subject.headers.should == headers
      subject.status.should == status
      subject.body.should == body
    end
  end

  describe '#parsed' do
    %w(application/x-www-form-urlencoded).each do |content_type|
      [:url, :automatic].each do |parse|
        it "parses application/x-www-form-urlencoded body with a #{content_type} header and the parse option #{parse}" do
          headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
          body = 'foo=bar&answer=42'
          response = double('response', :headers => headers, :body => body)
          subject = Response.new(response)
          subject.parsed.keys.size.should == 2
          subject.parsed['foo'].should == 'bar'
          subject.parsed['answer'].should == '42'
        end
      end
    end

    %w(application/json text/plain whatever).each do |content_type|
      [:json, :automatic].each do |parse|
        it "parses json body with a #{content_type} header and the parse option #{parse}" do
          headers = { 'Content-Type' => content_type }
          body = MultiJson.encode(:foo => 'bar', :answer => 42)
          response = double('response', :headers => headers, :body => body)
          subject = Response.new(response)
          subject.parsed.keys.size.should == 2
          subject.parsed['foo'].should == 'bar'
          subject.parsed['answer'].should == 42
        end
      end
    end
    
    it 'returns original body if it cannot be parsed' do 
      body = 'blah'
      response = double('response', :body => body, :headers => {}, :status => 400)
      subject = Response.new(response)
      subject.parsed.should == body
    end
  end
end