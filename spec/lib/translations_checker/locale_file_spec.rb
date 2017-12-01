require "spec_helper"

require "translations_checker/locale_file"

RSpec.describe TranslationsChecker::LocaleFile do
  let(:locales_dir) { TranslationsChecker::LOCALES_DIR }
  let(:locale_file) { described_class.new(path) }
  let(:fixture_dir) { Pathname(__dir__).join("..", "..", "fixtures", "locales") }

  context "when the file exists" do
    subject { locale_file }

    let(:path) { fixture_dir.join("xx/xx.yml") }

    it { is_expected.to be_exist }
  end

  context "when the file does not exist" do
    subject { locale_file }

    let(:path) { fixture_dir.join("xx/bogus.yml") }

    it { is_expected.to_not be_exist }
  end

  describe "#to_s" do
    subject { locale_file.to_s }

    let(:path) { "xx/yy.yml" }

    it { is_expected.to eq "xx/yy.yml" }
  end

  describe "#locale" do
    let(:path) { locales_dir.join("en", "locale.yml") }

    it "returns the first component of the file path after the locales directory" do
      expect(locale_file.locale).to eq "en"
    end
  end

  describe "#for_locale" do
    context "given the same locale" do
      let(:path) { locales_dir.join("ja", "file.yml") }

      it "returns itself" do
        expect(locale_file.for_locale("ja")).to be locale_file
      end
    end

    context "given a different locale" do
      let(:path) { locales_dir.join("en", "file.yml") }

      it "returns the equivalent locale file for the given locale" do
        expected_locale_file = described_class.new(locales_dir.join("ja", "file.yml"))
        expect(locale_file.for_locale("ja")).to eq expected_locale_file
      end
    end

    context "when the locale file is named after the locale" do
      let(:path) { locales_dir.join("en", "translations", "en.yml") }

      it "returns a locale file named after the given locale" do
        expected_locale_file = described_class.new(locales_dir.join("ja", "translations", "ja.yml"))
        expect(locale_file.for_locale("ja")).to eq expected_locale_file
      end
    end
  end

  describe "#==" do
    let(:path) { "xx/yy.yml" }

    context "when the other locale file has the same path" do
      it "returns true" do
        other_locale_file = described_class.new(Pathname("xx/yy.yml"))
        expect(locale_file == other_locale_file).to be_truthy
      end
    end

    context "when the other locale file has a different path" do
      it "returns false" do
        other_locale_file = described_class.new(Pathname("xx/zz.yml"))
        expect(locale_file == other_locale_file).to be_falsey
      end
    end
  end

  describe "#content" do
    let(:path) { fixture_dir.join("xx/xx.yml") }

    it "returns a locale file content object built from the locale file's contents fetched using `git show`", :aggregate_failures do
      file_content = path.read
      expected_locale_file_content = double :locale_file_content

      expect(TranslationsChecker::GitShow).to receive(:call).with(path).and_return file_content
      expect(TranslationsChecker::LocaleFileContent).to receive(:new).with(file_content).and_return(expected_locale_file_content)
      expect(locale_file.content).to be expected_locale_file_content
    end
  end

  describe "#[]" do
    let(:path) { "xx/yy.yml" }

    it "delegates to the locale file's content" do
      expected_value = double :value
      content = instance_double "TranslationsChecker::LocaleFileContent", :locale_file_content
      allow(locale_file).to receive(:content).and_return(content)

      expect(content).to receive(:[]).with(%w(en hello)).and_return(expected_value)
      expect(locale_file[%w(en hello)]).to be expected_value
    end
  end

  describe "#key_map" do
    let(:path) { "xx/yy.yml" }

    it "returns a locale file key map object built from the locale file's contents", :aggregate_failures do
      locale_file_content = instance_double "TranslationsChecker::LocaleFileContent", :locale_file_content
      expected_locale_file_key_map = double :locale_file_key_map

      expect(locale_file).to receive(:content).and_return(locale_file_content)
      expect(TranslationsChecker::LocaleFileKeyMap).to receive(:new).with(locale_file_content).and_return(expected_locale_file_key_map)
      expect(locale_file.key_map).to be expected_locale_file_key_map
    end
  end

  describe "#key_at" do
    let(:path) { "xx/yy.yml" }

    it "delegates to the locale file's key map" do
      expected_key = double :key
      key_map = instance_double "TranslationsChecker::LocaleFileKeyMap", :locale_file_key_map
      allow(locale_file).to receive(:key_map).and_return(key_map)

      expect(key_map).to receive(:key_at).with(12).and_return(expected_key)
      expect(locale_file.key_at(12)).to be expected_key
    end
  end
end
