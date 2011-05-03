require 'spec_helper'

describe OAuth2::AccessToken do
  let(:client) do
    OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.adapter :test do |stub|
        stub.get('/client')     {|env| [200, {}, env[:request_headers]['Authorization']]}
        stub.post('/client')    {|env| [200, {}, env[:request_headers]['Authorization']]}
        stub.get('/empty_get')  {|env| [204, {}, nil]}
        stub.put('/client')     {|env| [200, {}, env[:request_headers]['Authorization']]}
        stub.delete('/client')  {|env| [200, {}, env[:request_headers]['Authorization']]}
      end
    end
  end

  let(:token) {'monkey'}

  subject {OAuth2::AccessToken.new(client, token)}

  describe '#initialize' do
    it 'should assign client and token' do
      subject.client.should == client
      subject.token.should  == token
    end

    it 'should assign extra params' do
      target = OAuth2::AccessToken.new(client, token, nil, nil, {'foo' => 'bar'})
      target.params.should include('foo')
      target.params['foo'].should == 'bar'
    end

    %w(get delete).each do |http_method|
      it "makes #{http_method.upcase} requests with access token" do
        subject.send(http_method.to_sym, 'client').body.should == "OAuth #{token}"
      end
    end

    %w(post put).each do |http_method|
      it "makes #{http_method.upcase} requests with access token" do
        subject.send(http_method.to_sym, 'client').body.should == "OAuth #{token}"
      end
    end

    it "works with a null response body" do
      subject.get('empty_get').body.should == ''
    end
  end

  describe '#expires?' do
    it 'should be false if there is no expires_at' do
      OAuth2::AccessToken.new(client, token).should_not be_expires
    end

    it 'should be true if there is an expires_at' do
      OAuth2::AccessToken.new(client, token, 'abaca', 600).should be_expires
    end
  end

  describe '#expires_at' do
    before do
      @now = Time.now
      Time.stub!(:now).and_return(@now)
    end

    subject{OAuth2::AccessToken.new(client, token, 'abaca', 600)}

    it 'should be a time representation of #expires_in' do
      subject.expires_at.should == (@now + 600)
    end
  end

  describe '#expired?' do
    it 'should be false if there is no expires_at' do
      OAuth2::AccessToken.new(client, token).should_not be_expired
    end

    it 'should be false if expires_at is in the future' do
      OAuth2::AccessToken.new(client, token, 'abaca', 10800).should_not be_expired
    end

    it 'should be true if expires_at is in the past' do
      access = OAuth2::AccessToken.new(client, token, 'abaca', 600)
      @now = Time.now + 10800
      Time.stub!(:now).and_return(@now)
      access.should be_expired
    end
  end
end
