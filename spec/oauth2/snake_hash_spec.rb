RSpec.describe SnakeHash do
  subject { described_class.new }

  describe 'assign and query' do
    it 'returns assigned value with camel key' do
      subject['AccessToken'] = '1'

      expect(subject['AccessToken']).to eq('1')
      expect(subject['access_token']).to eq('1')
    end

    it 'returns assigned value with snake key only' do
      subject['access_token'] = '1'

      expect(subject['AccessToken']).to eq(nil)
      expect(subject['access_token']).to eq('1')
    end

    it 'overwrite snake key' do
      subject['AccessToken'] = '1'

      expect(subject['AccessToken']).to eq('1')
      expect(subject['access_token']).to eq('1')

      subject['access_token'] = '2'

      expect(subject['AccessToken']).to eq('1')
      expect(subject['access_token']).to eq('2')
    end
  end

  describe 'fetch'
  describe 'key?'
end
