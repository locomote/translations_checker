require "spec_helper"

require "translations_checker/change"

RSpec.describe TranslationsChecker::Change do
  describe "#new_value" do
    context "for a deletion" do
      it "returns nil" do
        change = described_class.new(nil, nil, "-" => 321)
        expect(change.new_value).to be_nil
      end
    end

    context "for a non-deletion" do
      it "returns the value from the new version of the locale file", :aggregate_failures do
        change = described_class.new(nil, nil, "-" => 123, "+" => 456)
        new_content = instance_double TranslationsChecker::LocaleFileContent
        expected_value = double :value
        key = double :key
        allow(change).to receive(:full_key).and_return key
        allow(change).to receive(:new_content).and_return new_content

        expect(new_content).to receive(:[]).with(key).and_return expected_value
        expect(change.new_value).to be expected_value
      end
    end
  end

  describe "#old_value" do
    context "for an addition" do
      it "returns nil" do
        change = described_class.new(nil, nil, "+" => 321)
        expect(change.old_value).to be_nil
      end
    end

    context "for a non-addition" do
      it "returns the value from the old version of the locale file", :aggregate_failures do
        change = described_class.new(nil, nil, "-" => 123, "+" => 456)
        old_content = instance_double TranslationsChecker::LocaleFileContent
        expected_value = double :value
        key = double :key
        allow(change).to receive(:full_key).and_return key
        allow(change).to receive(:old_content).and_return old_content

        expect(old_content).to receive(:[]).with(key).and_return expected_value
        expect(change.old_value).to be expected_value
      end
    end
  end

  describe "#full_key" do
    context "for a non-deletion" do
      it "returns the full key from the new version", :aggregate_failures do
        change = described_class.new(nil, nil, "-" => 123, "+" => 456)
        expected_key = double :key

        expect(change).to receive(:new_key_at).with(456).and_return expected_key
        expect(change.full_key).to be expected_key
      end
    end

    context "for a deletion" do
      it "returns the full key from the old version", :aggregate_failures do
        change = described_class.new(nil, nil, "-" => 321)
        expected_key = double :key

        expect(change).to receive(:old_key_at).with(321).and_return expected_key
        expect(change.full_key).to be expected_key
      end
    end
  end

  describe "#display_key" do
    it "returns the full key without the locale name"
  end

  context "when a value has been added" do
    subject { described_class.new(nil, nil, "+" => 1) }

    it { is_expected.to be_added }
  end

  context "when a value has been removed" do
    subject { described_class.new(nil, nil, "-" => 1) }

    it { is_expected.to be_deleted }
  end

  context "when a value has been replaced" do
    subject { described_class.new(nil, nil, "-" => 1, "+" => 1) }

    it { is_expected.to be_changed }
  end

  describe "#matches?" do
    context "when both changes have a full key" do
      it "matches on full key"
    end

    context "when this change does not have a full key" do
      it "matches on name"
    end

    context "when the other change does not have a full key" do
      it "matches on name"
    end

    context "when neither change does not have a full key" do
      it "matches on name"
    end
  end
end
