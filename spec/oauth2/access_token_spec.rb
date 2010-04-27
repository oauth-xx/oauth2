require 'spec_helper'

describe OAuth2::AccessToken do
  let(:client) do 
    cli = OAuth2::Client.new('abc','def', :site => 'https://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.get('/client?access_token=monkey') { |env| [200, {}, 'get']    }
        stub.post('/client')                    { |env| [200, {}, 'access_token=' << env[:body]['access_token']] }
        stub.put('/client')                     { |env| [200, {}, 'access_token=' << env[:body]['access_token']] }
        stub.delete('/client')                  { |env| [200, {}, 'access_token=' << env[:body]['access_token']] }
      end
    end
    cli
  end

  let(:token)  { 'monkey' }

  subject { OAuth2::AccessToken.new(client, token) }

  describe '#initialize' do
    it 'should assign client and token' do
      subject.client.should == client
      subject.token.should  == token
    end

    it "makes GET requests with access token" do
      subject.send(:get, 'client').should == 'get'
    end

    %w(post put delete).each do |http_method|
      it "makes #{http_method.upcase} requests with access token" do
        subject.send(http_method.to_sym, 'client').should == 'access_token=monkey'
      end
    end
  end
end