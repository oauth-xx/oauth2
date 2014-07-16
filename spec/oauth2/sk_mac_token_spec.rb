require 'helper'

describe OAuth2::SkMACToken do
  let(:token) { 'Biggie Smalls' }
  let(:mac_key) { 'abc123' }
  let(:token_opts) { {'kid' => 1} }

  let(:client) do
    Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.request :url_encoded
      builder.adapter :test do |stub|
        VERBS.each do |verb|
          stub.send(verb, '/token/header') do |env|
            [200, {}, env[:request_headers]['Authorization']]
          end
        end
      end
    end
  end

  let(:request_line) { 'POST /end/point HTTP/1.1' }
  let(:host) { 'http://hostname.com' }

  subject{ described_class.new(client, token, mac_key, token_opts) }

  describe '.header' do
    let(:the_time) { double('time', utc: '12334445555') }

    let(:expected_header) do
      "Authorization: MAC kid=\"1\" ts=\"#{the_time.utc}\" "\
      "nonce=\"GET JIGGY WITH IT\" access_token=\"#{token}\" "\
      "mac=\"SHAKUR\""
    end

    before do
      allow(Digest::MD5).to receive(:hexdigest) { 'GET JIGGY WITH IT' }
      allow(subject).to receive(:signature) { 'SHAKUR' }
      allow(Time).to receive(:now){ the_time }
    end

    it 'generates a proper header' do
      expect(subject.header(request_line, host)).to eq(expected_header)
    end
  end

  describe '.signature' do
    let(:timestamp) { 0 }
    let(:nonce) { 123 }

    let(:expected_signature) { '1b698073d8c6bb0c7c9454687205493d24d5703379b2c6ecfc8be6e42fa8c44a' }

    it 'returns a properly generated signature' do
      expect(subject.signature(request_line, host, timestamp, nonce)).to eq(expected_signature)
    end
  end
end
