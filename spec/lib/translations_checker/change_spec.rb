require "spec_helper"

require "translations_checker/change"

RSpec.describe TranslationsChecker::Change do
  describe "#new_value" do
    it "returns the value from the new version of the locale file"
  end

  describe "#full_key" do
    it "returns the full key for the changed value"
  end

  describe "#display_key" do
    context "when there is a full key" do
      it "returns the full key for the changed value without the locale name"
    end

    context "when there is not a full key" do
      it "returns the name for the changed value"
    end
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
