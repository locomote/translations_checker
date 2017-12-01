require "spec_helper"

require "translations_checker/indentation"

RSpec.describe TranslationsChecker::Indentation do
  describe "#indent" do
    class ExampleClass
      using TranslationsChecker::Indentation

      def self.test(string, *parameters)
        string.indent(*parameters)
      end
    end

    context "without a parameter" do
      it "indents the string by two spaces" do
        expect(ExampleClass.test("The quick\n  Brown\nFox")).to eq "  The quick\n    Brown\n  Fox"
      end
    end

    context "with an indentation parameter" do
      it "indents the string using the given indentation string" do
        expect(ExampleClass.test("The quick\n  Brown\nFox", "->")).to eq "->The quick\n->  Brown\n->Fox"
      end
    end
  end
end
