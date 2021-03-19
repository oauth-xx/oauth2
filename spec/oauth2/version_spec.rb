# frozen_string_literal: true

RSpec.describe OAuth2::Version do
  it 'has a version number' do
    expect(described_class).not_to be nil
  end

  it 'can be a string' do
    expect(described_class.to_s).to be_a(String)
  end

  it 'allows Constant access' do
    expect(described_class::VERSION).to be_a(String)
  end

  it 'is greater than 0.1.0' do
    expect(Gem::Version.new(described_class) > Gem::Version.new('0.1.0')).to be(true)
  end

  it 'is not a pre-release' do
    expect(Gem::Version.new(described_class).prerelease?).to be(false)
  end
end
