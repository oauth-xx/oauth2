describe OAuth2::Version do
  context 'Constant' do
    it 'is a sting' do
      expect(OAuth2::Version::VERSION).to be_a(String)
    end
  end
end