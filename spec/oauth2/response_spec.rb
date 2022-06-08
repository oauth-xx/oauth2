# frozen_string_literal: true

RSpec.describe OAuth2::Response do
  subject { described_class.new(raw_response) }

  let(:raw_response) { Faraday::Response.new(status: status, response_headers: headers, body: body) }
  let(:status) { 200 }
  let(:headers) { {'foo' => 'bar'} }
  let(:body) { 'foo' }

  describe '#initialize' do
    it 'returns the status, headers and body' do
      expect(subject.headers).to eq(headers)
      expect(subject.status).to eq(status)
      expect(subject.body).to eq(body)
    end
  end

  describe '.register_parser' do
    let(:response) do
      double('response', headers: {'Content-Type' => 'application/foo-bar'},
                         status: 200,
                         body: 'baz')
    end

    before do
      described_class.register_parser(:foobar, ['application/foo-bar']) do |body|
        "foobar #{body}"
      end
    end

    it 'adds to the content types and parsers' do
      expect(described_class.send(:class_variable_get, :@@parsers).keys).to include(:foobar)
      expect(described_class.send(:class_variable_get, :@@content_types).keys).to include('application/foo-bar')
    end

    it 'is able to parse that content type automatically' do
      expect(described_class.new(response).parsed).to eq('foobar baz')
    end
  end

  describe '#content_type' do
    context 'when headers are blank' do
      let(:headers) { nil }

      it 'returns nil' do
        expect(subject.content_type).to be_nil
      end
    end

    context 'when content-type is not present' do
      let(:headers) { {'a fuzzy' => 'fuzzer'} }

      it 'returns empty string' do
        expect(subject.content_type).to eq('')
      end
    end

    context 'when content-type is present' do
      let(:headers) { {'Content-Type' => 'application/x-www-form-urlencoded'} }

      it 'returns the content type header contents' do
        expect(subject.content_type).to eq('application/x-www-form-urlencoded')
      end
    end
  end

  describe '#parsed' do
    subject(:parsed) do
      headers = {'Content-Type' => content_type}
      response = double('response', headers: headers, body: body)
      instance = described_class.new(response)
      instance.parsed
    end

    shared_examples_for 'parsing JSON-like' do
      it 'has num keys' do
        expect(parsed.keys.size).to eq(6)
      end

      it 'parses string' do
        expect(parsed['foo']).to eq('bar')
        expect(parsed.key('bar')).to eq('foo')
      end

      it 'parses non-zero number' do
        expect(parsed['answer']).to eq(42)
        expect(parsed.key(42)).to eq('answer')
      end

      it 'parses nil as NilClass' do
        expect(parsed['krill']).to be_nil
        expect(parsed.key(nil)).to eq('krill')
      end

      it 'parses zero as number' do
        expect(parsed['zero']).to eq(0)
        expect(parsed.key(0)).to eq('zero')
      end

      it 'parses false as FalseClass' do
        expect(parsed['malign']).to be(false)
        expect(parsed.key(false)).to eq('malign')
      end

      it 'parses false as TrueClass' do
        expect(parsed['shine']).to be(true)
        expect(parsed.key(true)).to eq('shine')
      end
    end

    context 'when application/json' do
      let(:content_type) { 'application/json' }
      let(:body) { JSON.dump(foo: 'bar', answer: 42, krill: nil, zero: 0, malign: false, shine: true) }

      it_behaves_like 'parsing JSON-like'
    end

    context 'when application/Json' do
      let(:content_type) { 'application/Json' }
      let(:body) { JSON.dump(foo: 'bar', answer: 42, krill: nil, zero: 0, malign: false, shine: true) }

      it_behaves_like 'parsing JSON-like'
    end

    context 'when application/hal+json' do
      let(:content_type) { 'application/hal+json' }
      let(:body) { JSON.dump(foo: 'bar', answer: 42, krill: nil, zero: 0, malign: false, shine: true) }

      it_behaves_like 'parsing JSON-like'
    end

    context 'when application/x-www-form-urlencoded' do
      let(:content_type) { 'application/x-www-form-urlencoded' }
      let(:body) { 'foo=bar&answer=42&krill=&zero=0&malign=false&shine=true' }

      it 'has num keys' do
        expect(parsed.keys.size).to eq(6)
      end

      it 'parses string' do
        expect(parsed['foo']).to eq('bar')
        expect(parsed.key('bar')).to eq('foo')
      end

      it 'parses non-zero number as string' do
        expect(parsed['answer']).to eq('42')
        expect(parsed.key('42')).to eq('answer')
      end

      it 'parses nil as empty string' do
        expect(parsed['krill']).to eq('')
        expect(parsed.key('')).to eq('krill')
      end

      it 'parses zero as string' do
        expect(parsed['zero']).to eq('0')
        expect(parsed.key('0')).to eq('zero')
      end

      it 'parses false as string' do
        expect(parsed['malign']).to eq('false')
        expect(parsed.key('false')).to eq('malign')
      end

      it 'parses true as string' do
        expect(parsed['shine']).to eq('true')
        expect(parsed.key('true')).to eq('shine')
      end
    end

    it 'parses application/vnd.collection+json body' do
      headers = {'Content-Type' => 'application/vnd.collection+json'}
      body = JSON.dump(collection: {})
      response = double('response', headers: headers, body: body)
      subject = described_class.new(response)
      expect(subject.parsed.keys.size).to eq(1)
    end

    it 'parses application/vnd.api+json body' do
      headers = {'Content-Type' => 'application/vnd.api+json'}
      body = JSON.dump(collection: {})
      response = double('response', headers: headers, body: body)
      subject = described_class.new(response)
      expect(subject.parsed.keys.size).to eq(1)
    end

    it 'parses application/problem+json body' do
      headers = {'Content-Type' => 'application/problem+json'}
      body = JSON.dump(type: 'https://tools.ietf.org/html/rfc7231#section-6.5.4', title: 'Not Found')
      response = double('response', headers: headers, body: body)
      subject = described_class.new(response)
      expect(subject.parsed.keys.size).to eq(2)
      expect(subject.parsed['type']).to eq('https://tools.ietf.org/html/rfc7231#section-6.5.4')
      expect(subject.parsed['title']).to eq('Not Found')
    end

    it "doesn't try to parse other content-types" do
      headers = {'Content-Type' => 'text/html'}
      body = '<!DOCTYPE html><html><head></head><body></body></html>'

      response = double('response', headers: headers, body: body)

      expect(JSON).not_to receive(:parse)
      expect(Rack::Utils).not_to receive(:parse_query)

      subject = described_class.new(response)
      expect(subject.parsed).to be_nil
    end

    it 'snakecases json keys when parsing' do
      headers = {'Content-Type' => 'application/json'}
      body = JSON.dump('accessToken' => 'bar', 'MiGever' => 'Ani')
      response = double('response', headers: headers, body: body)
      subject = described_class.new(response)
      expect(subject.parsed.keys.size).to eq(2)
      expect(subject.parsed['access_token']).to eq('bar')
      expect(subject.parsed['mi_gever']).to eq('Ani')
    end

    it 'supports registered parsers with arity == 0; passing nothing' do
      described_class.register_parser(:arity_0, []) do
        'a-ok'
      end

      headers   = {'Content-Type' => 'text/html'}
      body      = '<!DOCTYPE html><html><head></head><body></body></html>'
      response  = double('response', headers: headers, body: body)

      subject = described_class.new(response, parse: :arity_0)

      expect(subject.parsed).to eq('a-ok')
    end

    it 'supports registered parsers with arity == 2; passing body and response' do
      headers   = {'Content-Type' => 'text/html'}
      body      = '<!DOCTYPE html><html><head></head><body></body></html>'
      response  = double('response', headers: headers, body: body)

      described_class.register_parser(:arity_2, []) do |passed_body, passed_response|
        expect(passed_body).to eq(body)
        expect(passed_response).to eq(response)

        'a-ok'
      end

      subject = described_class.new(response, parse: :arity_2)

      expect(subject.parsed).to eq('a-ok')
    end

    it 'supports registered parsers with arity > 2; passing body and response' do
      headers   = {'Content-Type' => 'text/html'}
      body      = '<!DOCTYPE html><html><head></head><body></body></html>'
      response  = double('response', headers: headers, body: body)

      described_class.register_parser(:arity_3, []) do |passed_body, passed_response, *args|
        expect(passed_body).to eq(body)
        expect(passed_response).to eq(response)
        expect(args).to eq([])

        'a-ok'
      end

      subject = described_class.new(response, parse: :arity_3)

      expect(subject.parsed).to eq('a-ok')
    end

    it 'supports directly passed parsers' do
      headers   = {'Content-Type' => 'text/html'}
      body      = '<!DOCTYPE html><html><head></head><body></body></html>'
      response  = double('response', headers: headers, body: body)

      subject = described_class.new(response, parse: -> { 'a-ok' })

      expect(subject.parsed).to eq('a-ok')
    end
  end

  context 'with xml parser registration' do
    it 'tries to load multi_xml.rb and use it' do
      expect(described_class.send(:class_variable_get, :@@parsers)[:xml]).not_to be_nil
    end

    it 'is able to parse xml' do
      headers = {'Content-Type' => 'text/xml'}
      body = '<?xml version="1.0" standalone="yes" ?><foo><bar>baz</bar></foo>'

      response = double('response', headers: headers, body: body)
      expect(described_class.new(response).parsed).to eq('foo' => {'bar' => 'baz'})
    end

    it 'is able to parse application/xml' do
      headers = {'Content-Type' => 'application/xml'}
      body = '<?xml version="1.0" standalone="yes" ?><foo><bar>baz</bar></foo>'

      response = double('response', headers: headers, body: body)
      expect(described_class.new(response).parsed).to eq('foo' => {'bar' => 'baz'})
    end
  end

  describe 'converting to json' do
    it 'does not blow up' do
      expect { subject.to_json }.not_to raise_error
    end
  end
end
