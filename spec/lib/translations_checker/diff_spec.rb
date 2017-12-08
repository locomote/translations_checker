require "spec_helper"

require "translations_checker/diff"

RSpec.describe TranslationsChecker::Diff do
  describe "#locale_file" do
    it "returns a locale file for the given path" do
      path = "xx/yy.yml"
      diff = described_class.new(path, [])
      expect(diff.locale_file).to eq TranslationsChecker::LocaleFile.new(path)
    end
  end

  describe "#blocks" do
    it "returns diff blocks built from the given diff hunks", :aggregate_failures do
      path = "xx/yy.yml"
      hunks = [
        [ 8...9, 8...8, "-  key: value" ]
      ]
      diff = described_class.new(path, hunks)
      block = double(:block)

      expect(TranslationsChecker::DiffBlock).to receive(:new).with(diff, 8...9, 8...8, "-  key: value").and_return block
      expect(diff.blocks).to eq [ block ]
    end
  end

  describe "#changes" do
    it "returns changes collected from the diff blocks" do
      diff = described_class.new("xx/yy.yml", [])

      changes = [
        instance_double("TranslationsChecker::Change", :first_change),
        instance_double("TranslationsChecker::Change", :second_change)
      ]
      blocks = changes.map do |change|
        instance_double "TranslationsChecker::DiffBlock", changes: [ change ]
      end
      allow(diff).to receive(:blocks).and_return(blocks)

      expect(diff.changes).to eq changes
    end
  end

  describe "#match_change" do
    context "when there is a matching change" do
      it "returns the matching change" do
        other_change = instance_double("TranslationsChecker::Change", :other_change)
        matching_change = instance_double("TranslationsChecker::Change", :matching_change)
        allow(other_change).to receive(:matches?).and_return false
        expect(other_change).to receive(:matches?).with(matching_change).and_return true
        changes = [
          instance_double("TranslationsChecker::Change", :first_change),
          matching_change,
          instance_double("TranslationsChecker::Change", :last_change)
        ]

        diff = described_class.new("xx/yy.yml", [])
        allow(diff).to receive(:changes).and_return changes

        expect(diff.match_change(other_change)).to be matching_change
      end
    end

    context "when there is no matching change" do
      context "when the other change has a full key" do
        it "returns a 'no change' object with the full key in this locale", :aggregate_failures do
          other_change = instance_double(
            "TranslationsChecker::Change",
            :other_change,
            matches?: false,
            full_key: %w(zz yy)
          )
          diff = described_class.new("xx/yy.yml", [])
          allow(diff).to receive(:locale).and_return "zz"

          no_change = instance_double "TranslationsChecker::NoChange", :no_change

          expect(TranslationsChecker::NoChange).to receive(:new).with(diff, %w(zz yy)).and_return no_change
          expect(diff.match_change(other_change)).to be no_change
        end
      end
    end
  end

  describe "#match_changes" do
    it "returns matching changes from the other diff, with 'no-change' objects for changes without matches"
  end
end
