require 'spec_helper'

describe URI::Generic do
  subject{ URI.parse('http://example.com')}
  
  describe '#query_hash' do
    it 'should be a hash of the query parameters' do
      subject.query_hash.should == {}
      subject.query = 'abc=def&foo=123'
      subject.query_hash.should == {'abc' => 'def', 'foo' => '123'}
    end
  end
  
  describe '#query_hash=' do
    it 'should set the query' do
      subject.query_hash = {'abc' => 'def'}
      subject.query.should == 'abc=def'
      subject.query_hash = {'abc' => 'foo', 'bar' => 'baz'}
      subject.query.should be_include('abc=foo')
      subject.query.should be_include('bar=baz')
      subject.query.split('&').size.should == 2
    end
    
    it 'should escape stuff' do
      subject.query_hash = {'abc' => '$%!!'}
      subject.query.should == "abc=#{CGI.escape('$%!!')}"
    end
  end
end