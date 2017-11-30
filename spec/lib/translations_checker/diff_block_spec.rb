require "spec_helper"

require "translations_checker/diff_block"

RSpec.describe TranslationsChecker::DiffBlock do
  describe "#changes" do
    let(:file_diff) { double :file_diff }

    context "when there are multiple changes" do
      let(:body) do
        <<~BODY
          -  key_1: Old value 1
          -  key_2: Old value 2
          +  key_1: New value 1
          +  key_2: New value 2
        BODY
      end

      let(:diff_block) { described_class.new(file_diff, 8...10, 4...6, body) }

      it "returns the changes" do
        changes = [ double(:first_change), double(:second_change) ]
        allow(TranslationsChecker::Change).to receive(:new).with(file_diff, "key_1", "-" => 8, "+" => 4).and_return changes[0]
        allow(TranslationsChecker::Change).to receive(:new).with(file_diff, "key_2", "-" => 9, "+" => 5).and_return changes[1]
        expect(diff_block.changes).to eq changes
      end
    end

    context "when a key has been removed" do
      let(:body) do
        <<~BODY
          -  key: Value
        BODY
      end

      let(:diff_block) { described_class.new(file_diff, 6...7, 8...8, body) }

      it "returns the changes" do
        change = double(:change)
        allow(TranslationsChecker::Change).to receive(:new).with(file_diff, "key", "-" => 6).and_return change
        expect(diff_block.changes).to eq [ change ]
      end
    end

    context "when a key has been added" do
      let(:body) do
        <<~BODY
          +  key: Value
        BODY
      end

      let(:diff_block) { described_class.new(file_diff, 2...2, 5...6, body) }

      it "returns the changes" do
        change = double(:change)
        allow(TranslationsChecker::Change).to receive(:new).with(file_diff, "key", "+" => 5).and_return change
        expect(diff_block.changes).to eq [ change ]
      end
    end
  end
end
