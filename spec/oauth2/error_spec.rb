RSpec.describe OAuth2::Error do
  let(:subject) { described_class.new(response) }
  let(:response) do
    fake_response = double(
      'response',
      :status => 418,
      :headers => response_headers,
      :body => response_body
    )

    OAuth2::Response.new(fake_response)
  end

  let(:response_headers) { {'Content-Type' => 'application/json'} }
  let(:response_body) { {:text => 'Coffee brewing failed'}.to_json }

  it 'sets self to #error on the response object' do
    expect(response.error).to be_nil
    error = described_class.new(response)
    expect(response.error).to equal(error)
  end

  it 'sets the response object to #response on self' do
    error = described_class.new(response)
    expect(error.response).to equal(response)
  end

  describe 'attr_readers' do
    it 'has code' do
      expect(subject).to respond_to(:code)
    end

    it 'has description' do
      expect(subject).to respond_to(:description)
    end

    it 'has response' do
      expect(subject).to respond_to(:response)
    end
  end

  context 'when the response is parseable as a hash' do
    let(:response_body) { response_hash.to_json }
    let(:response_hash) { {:text => 'Coffee brewing failed'} }

    context 'when the response has an error and error_description' do
      before do
        response_hash[:error_description] = 'Short and stout'
        response_hash[:error] = 'i_am_a_teapot'
      end

      it 'prepends to the error message with a return character' do
        expect(subject.message.lines).to eq(
          [
            'i_am_a_teapot: Short and stout' + "\n",
            '{"text":"Coffee brewing failed","error_description":"Short and stout","error":"i_am_a_teapot"}',
          ]
        )
      end

      context 'when the response needs to be encoded' do
        let(:response_body) { MultiJson.encode(response_hash).force_encoding('ASCII-8BIT') }

        before do
          response_hash[:error_description] << ": 'A magical voyage of tea 🍵'"
        end

        it 'respects the encoding of the response body' do
          expect(subject.message).to match(/🍵/)
          # This will fail with Encoding::CompatibilityError if done incorrectly
        end
      end

      context 'when the response is not an encodable thing' do
        let(:response_headers) { {'Content-Type' => 'who knows'} }
        let(:response_body) { {:text => 'Coffee brewing failed'} }

        before do
          expect(response_body).not_to respond_to(:encode)
          # i.e. a Ruby hash
        end

        it 'does not try to encode the message string' do
          expect(subject.message).to eq(response_body.to_s)
        end
      end

      it 'sets the code attribute' do
        expect(subject.code).to eq('i_am_a_teapot')
      end

      it 'sets the description attribute' do
        expect(subject.description).to eq('Short and stout')
      end
    end

    context 'when there is no error description' do
      before do
        expect(response_hash).not_to have_key(:error)
        expect(response_hash).not_to have_key(:error_description)
      end

      it 'does not prepend anything to the message' do
        expect(subject.message.lines.count).to eq(1)
        expect(subject.message).to eq '{"text":"Coffee brewing failed"}'
      end

      it 'does not set code' do
        expect(subject.code).to be_nil
      end

      it 'does not set description' do
        expect(subject.description).to be_nil
      end
    end
  end

  context 'when the response does not parse to a hash' do
    let(:response_headers) { {'Content-Type' => 'text/html'} }
    let(:response_body) { '<!DOCTYPE html><html><head>Hello, I am a teapot</head><body></body></html>' }
    
    before do
      expect(response.parsed).not_to be_a(Hash)
    end

    it 'does not do anything to the message' do
      expect(subject.message.lines.count).to eq(1)
      expect(subject.message).to eq(response_body)
    end

    it 'does not set code' do
      expect(subject.code).to be_nil
    end

    it 'does not set description' do
      expect(subject.description).to be_nil
    end
  end
end
