require "spec_helper"

require "translations_checker/locale_file_content"

RSpec.describe TranslationsChecker::LocaleFileContent do
  let(:content) { described_class.new(yaml) }

  describe "#to_h" do
    let(:yaml) do
      <<~YAML
        root:
          parent_1:
            child_1: "child A"
            child_2: "child B"
      YAML
    end

    it "returns the content hash" do
      expect(content.to_h).to eq YAML.safe_load(yaml)
    end
  end

  describe "#[]" do
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

      it "returns the value" do
        expect(content[%w(root parent_2 child_1)]).to eq "child C"
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
        expect(content[%w(root parent_3 child_1)]).to be_nil
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

      it "returns the entire content hash" do
        expect(content[%w()]).to eq YAML.safe_load(yaml)
      end
    end
  end
end
