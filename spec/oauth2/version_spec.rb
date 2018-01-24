RSpec.describe OAuth2::Version do
  it 'has a version number' do
    expect(OAuth2::Version).not_to be nil
  end
  it 'is greater than 0.1.0' do
    expect(Gem::Version.new(OAuth2::Version) > Gem::Version.new('0.1.0')).to be(true)
  end
end
