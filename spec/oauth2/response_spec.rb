require 'helper'

describe OAuth2::Response do
  describe '#initialize' do
    let(:status) {200}
    let(:headers) {{'foo' => 'bar'}}
    let(:body) {'foo'}

    it 'returns the status, headers and body' do
      response = double('response', :headers => headers,
                                    :status  => status,
                                    :body    => body)
      subject = Response.new(response)
      subject.headers.should == headers
      subject.status.should == status
      subject.body.should == body
    end
  end

  describe '.register_parser' do
    let(:response) {
      double('response', :headers => {'Content-Type' => 'application/foo-bar'},
                         :status => 200,
                         :body => 'baz')
    }
    before do
      OAuth2::Response.register_parser(:foobar, 'application/foo-bar') do |body|
        "foobar #{body}"
      end
    end

    it 'should add to the content types and parsers' do
      OAuth2::Response::PARSERS.keys.should be_include(:foobar)
      OAuth2::Response::CONTENT_TYPES.keys.should be_include('application/foo-bar')
    end

    it 'should be able to parse that content type automatically' do
      OAuth2::Response.new(response).parsed.should == 'foobar baz'
    end
  end

  describe '#parsed' do
    it "parses application/x-www-form-urlencoded body" do
      headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
      body = 'foo=bar&answer=42'
      response = double('response', :headers => headers, :body => body)
      subject = Response.new(response)
      subject.parsed.keys.size.should == 2
      subject.parsed['foo'].should == 'bar'
      subject.parsed['answer'].should == '42'
    end

    it "parses application/json body" do
      headers = {'Content-Type' => 'application/json'}
      body = MultiJson.encode(:foo => 'bar', :answer => 42)
      response = double('response', :headers => headers, :body => body)
      subject = Response.new(response)
      subject.parsed.keys.size.should == 2
      subject.parsed['foo'].should == 'bar'
      subject.parsed['answer'].should == 42
    end

    it "doesn't try to parse other content-types" do
      headers = {'Content-Type' => 'text/html'}
      body = '<!DOCTYPE html><html><head></head><body></body></html>'

      response = double('response', :headers => headers, :body => body)

      MultiJson.should_not_receive(:decode)
      Rack::Utils.should_not_receive(:parse_query)

      subject = Response.new(response)
      subject.parsed.should be_nil
    end
  end

  context 'xml parser registration' do
    it 'should try to load multi_xml and use it' do
      OAuth2::Response::PARSERS[:xml].should_not be_nil
    end

    it 'should be able to parse xml' do
      headers = {'Content-Type' => 'text/xml'}
      body = '<?xml version="1.0" standalone="yes" ?><foo><bar>baz</bar></foo>'

      response = double('response', :headers => headers, :body => body)
      OAuth2::Response.new(response).parsed.should == {"foo" => {"bar" => "baz"}}
    end
  end
end
