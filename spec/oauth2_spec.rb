# frozen_string_literal: true

RSpec.describe OAuth2 do
  it "silence_extra_tokens_warning is a boolean" do
    expect(described_class.config.silence_extra_tokens_warning).to be(true).or be(false)
  end

  describe ".configure" do
    subject(:configure) do
      described_class.configure do |config|
        config.silence_extra_tokens_warning = true
        config.silence_no_tokens_warning = true
      end
    end

    before do
      described_class.configure do |config|
        config.silence_extra_tokens_warning = false
        config.silence_no_tokens_warning = false
      end
    end

    after do
      described_class.configure do |config|
        config.silence_extra_tokens_warning = false
        config.silence_no_tokens_warning = false
      end
    end

    it "can change setting of silence_extra_tokens_warning" do
      block_is_expected.to change(described_class.config, :silence_extra_tokens_warning).from(false).to(true)
    end

    it "can change setting of silence_no_tokens_warning" do
      block_is_expected.to change(described_class.config, :silence_no_tokens_warning).from(false).to(true)
    end
  end
end
