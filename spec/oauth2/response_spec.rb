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
    it 'parses x-www-form-urlencoded body' do
      headers = { 'Content-Type' => 'x-www-form-urlencoded' }
      body = 'foo=bar&answer=42'
      response = double('response', :headers => headers, :body => body)
      subject = Response.new(response)
      subject.parsed.keys.size.should == 2
      subject.parsed['foo'].should == 'bar'
      subject.parsed['answer'].should == '42'
    end

    %w(application/json text/plain whatever).each do |content_type|
      it "parses json body with a #{content_type} header" do
        headers = { 'Content-Type' => content_type }
        body = MultiJson.encode(:foo => 'bar', :answer => 42)
        response = double('response', :headers => headers, :body => body)
        subject = Response.new(response)
        subject.parsed.keys.size.should == 2
        subject.parsed['foo'].should == 'bar'
        subject.parsed['answer'].should == 42
      end
    end
    
    it 'returns original body it cannot be parsed' do 
      body = 'blah'
      response = double('response', :body => body, :headers => {}, :status => 400)
      subject = Response.new(response)
      subject.parsed.should == body
    end
  end
end