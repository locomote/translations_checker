require "spec_helper"

require "translations_checker/terminal_colours"

RSpec.describe TranslationsChecker::TerminalColours do
  let(:attributes_off) { TranslationsChecker::TerminalColours::ATTRIBUTES_OFF }

  describe ".colourize" do
    TranslationsChecker::TerminalColours::COLOURS.each do |colour, code|
      context "when the colour is #{colour.inspect}" do
        it "prefixes the string with the colour code and suffixes it with the 'attributes off' code" do
          expect(described_class.colourize("quick brown fox", colour)).to eq "#{code}quick brown fox#{attributes_off}"
        end
      end
    end
  end

  class ExampleClass
    include TranslationsChecker::TerminalColours
  end

  TranslationsChecker::TerminalColours::COLOURS.each do |colour, code|
    describe "##{colour}" do
      it "prefixes the string with the colour code and suffixes it with the 'attributes off' code" do
        expect(ExampleClass.new.send(colour, "quick brown fox")).to eq "#{code}quick brown fox#{attributes_off}"
      end
    end
  end
end
