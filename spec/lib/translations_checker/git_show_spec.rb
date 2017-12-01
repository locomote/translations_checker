require "spec_helper"

require "translations_checker/git_show"

RSpec.describe TranslationsChecker::GitShow do
  describe "#call" do
    let(:git_show) { described_class.new("the_path", ref: "a/ref") }

    it "invokes `git show`", :aggregate_failures do
      show_output = double :show_output

      expect(git_show).to receive(:`).with('git show "a/ref:the_path"').and_return show_output
      expect(git_show.call).to be show_output
    end
  end
end
