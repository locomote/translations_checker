require "spec_helper"

require "translations_checker/no_change"

RSpec.describe TranslationsChecker::NoChange do
  describe "#name" do
    it "returns the last component of the full key" do
      expected_name = double :name
      change = described_class.new(nil, ["xx", "yy", expected_name])

      expect(change.name).to be expected_name
    end
  end

  describe "#display_key" do
    it "returns the full key without the locale name" do
      change = described_class.new(nil, %w(xx yy zz))

      expect(change.display_key).to eq %w(yy zz)
    end

    context "when the full key is empty" do
      it "returns an empty key" do
        change = described_class.new(nil, [])

        expect(change.display_key).to eq []
      end
    end
  end

  describe "#new_line" do
    it "uses the key line from the file content" do
      locale_file = instance_double TranslationsChecker::LocaleFile, :locale_file
      full_key = double :full_key
      change = described_class.new(nil, full_key)
      allow(change).to receive(:locale_file).and_return locale_file
      expected_line_number = double :line_number

      expect(locale_file).to receive(:new_key_line).and_return expected_line_number
      expect(change.new_line).to be expected_line_number
    end
  end
end

