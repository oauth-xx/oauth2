# frozen_string_literal: true

RSpec.describe OAuth2::SnakyHash do
  subject { described_class.new }

  describe '.build' do
    context 'when build from hash' do
      subject { described_class.new('AccessToken' => '1') }

      it 'create correct snake hash' do
        expect(subject).to be_a(described_class)
        expect(subject['AccessToken']).to eq('1')
        expect(subject['access_token']).to eq('1')
      end
    end

    context 'when build from snake_hash' do
      subject do
        h = described_class.new
        h['AccessToken'] = '1'

        described_class.new(h)
      end

      it 'create correct snake hash' do
        expect(subject).to be_a(described_class)
        expect(subject['AccessToken']).to eq('1')
        expect(subject['access_token']).to eq('1')
      end
    end
  end

  describe 'assign and query' do
    it 'returns assigned value with camel key' do
      subject['AccessToken'] = '1'

      expect(subject['AccessToken']).to eq('1')
      expect(subject['access_token']).to eq('1')
    end

    it 'returns assigned value with snake key' do
      subject['access_token'] = '1'

      expect(subject['AccessToken']).to eq('1')
      expect(subject['access_token']).to eq('1')
    end

    it 'overwrite by alternate key' do
      subject['AccessToken'] = '1'

      expect(subject['AccessToken']).to eq('1')
      expect(subject['access_token']).to eq('1')

      subject['access_token'] = '2'

      expect(subject['AccessToken']).to eq('2')
      expect(subject['access_token']).to eq('2')
    end
  end

  describe '#fetch' do
    context 'when Camel case key' do
      subject { described_class.new('AccessToken' => '1') }

      it 'return correct token' do
        expect(subject.fetch('access_token')).to eq('1')
      end
    end

    context 'when Camel case key with down-cased first letter' do
      subject { described_class.new('accessToken' => '1') }

      it 'return correct token' do
        expect(subject.fetch('access_token')).to eq('1')
      end
    end

    context 'when snake case key' do
      subject { described_class.new('access_token' => '1') }

      it 'return correct token' do
        expect(subject.fetch('access_token')).to eq('1')
      end
    end

    context 'when missing any key' do
      subject { described_class.new }

      it 'raise KeyError with key' do
        pending_for(engine: 'jruby', versions: '3.1.0', reason: 'https://github.com/jruby/jruby/issues/7112')
        expect do
          subject.fetch('access_token')
        end.to raise_error(KeyError, /access_token/)
      end

      it 'return default value' do
        expect(subject.fetch('access_token', 'default')).to eq('default')
      end
    end
  end

  describe '#key?' do
    context 'when Camel case key' do
      subject { described_class.new('AccessToken' => '1') }

      it 'return true' do
        expect(subject.key?('access_token')).to be(true)
      end
    end

    context 'when Camel case key with down-cased first letter' do
      subject { described_class.new('accessToken' => '1') }

      it 'return true' do
        expect(subject.key?('access_token')).to be(true)
      end
    end

    context 'when snake case key' do
      subject { described_class.new('access_token' => '1') }

      it 'return true' do
        expect(subject.key?('access_token')).to be(true)
      end
    end

    context 'when missing any key' do
      subject { described_class.new }

      it 'return false' do
        expect(subject.key?('access_token')).to be(false)
      end
    end
  end
end
