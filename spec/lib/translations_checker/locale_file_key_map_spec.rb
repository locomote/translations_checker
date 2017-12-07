require "spec_helper"

require "translations_checker/locale_file_content"
require "translations_checker/locale_file_key_map"

RSpec.describe TranslationsChecker::LocaleFileKeyMap do
  let(:content) { TranslationsChecker::LocaleFileContent.new(yaml) }
  let(:key_map) { described_class.new(content) }

  describe "#key_at" do
    context "given a line number with a key" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child 1"
              child_2: "child 2"
            parent_2:
              child_1: "child 1"
              child_2: "child 2"
        YAML
      end

      it "returns the full key for the given line number" do
        expect(key_map.key_at(6)).to eq %w(root parent_2 child_1)
      end
    end

    context "given a line number for a blank line" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child 1"
              child_2: "child 2"

            parent_2:
              child_1: "child 1"
              child_2: "child 2"
        YAML
      end

      it "returns nil" do
        expect(key_map.key_at(5)).to be_nil
      end
    end

    context "given a line number for a comment line" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child 1"
              child_2: "child 2"
            # TODO: Clean this up
            parent_2:
              child_1: "child 1"
              child_2: "child 2"
        YAML
      end

      it "returns nil" do
        expect(key_map.key_at(5)).to be_nil
      end
    end

    context "given a line number inside a multi-line value that looks like a key" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child 1"
              child_2: >
                some text
                looks_like_a_key: blah
            parent_2:
              child_1: "child 1"
              child_2: "child 2"
        YAML
      end

      it "returns nil" do
        expect(key_map.key_at(6)).to be_nil
      end
    end

    context "given a line nested inside a key containing slashes" do
      let(:yaml) do
        <<~YAML
          root:
            parent/1:
              child_1: "child 1"
              child_2: "child 2"
        YAML
      end

      it "returns the full key for the given line number" do
        expect(key_map.key_at(4)).to eq %w(root parent/1 child_2)
      end
    end
  end

  describe "#key_line" do
    context "given a valid key" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child A"
              child_2: "child B"
            parent_2:
              child_1: "child C"
              child_2: "child D"
        YAML
      end

      it "returns the line number for the key" do
        expect(key_map.key_line(%w(root parent_2 child_1))).to eq 6
      end
    end

    context "given a key that does not exist" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child A"
              child_2: "child B"
            parent_2:
              child_1: "child C"
              child_2: "child D"
        YAML
      end

      it "returns nil" do
        expect(key_map.key_line(%w(root parent_3 child_1))).to be_nil
      end
    end

    context "given an empty key" do
      let(:yaml) do
        <<~YAML
          root:
            parent_1:
              child_1: "child A"
              child_2: "child B"
            parent_2:
              child_1: "child C"
              child_2: "child D"
        YAML
      end

      it "returns nil" do
        expect(key_map.key_line([])).to be_nil
      end
    end
  end
end
