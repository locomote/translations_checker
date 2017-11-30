require "spec_helper"

require "translations_checker/git_diff"

RSpec.describe TranslationsChecker::GitDiff do
  describe "#diff" do
    let(:git_diff) { described_class.new("the_path", ref: "a/ref") }

    it "invokes `git diff`", :aggregate_failures do
      diff_output = double :diff_output

      expect(git_diff).to receive(:`).with('git diff --diff-filter=AM --unified=0 "a/ref" "the_path"').and_return diff_output
      expect(git_diff.diff).to be diff_output
    end
  end

  describe "#call" do
    let(:git_diff) { described_class.new("the_path", ref: "a/ref") }

    context "when there are no file diffs" do
      let(:diff_output) { "" }

      it "returns an empty hash" do
        allow(git_diff).to receive(:diff).and_return diff_output

        expect(git_diff.call).to eq({})
      end
    end

    context "when there are file diffs" do
      let(:diff_output) do
        <<~DIFF
          diff --git a/config/locales/en/old.yml b/config/locales/en/layouts.yml
          index 12b23b6f9..7880552d8 100644
          --- a/config/locales/en/old.yml
          +++ b/config/locales/en/layouts.yml
          @@ -8 +8 @@ en:
          -      country_risk_lists: "Country Risk Lists"
          +      country_risk_lists: "Country Risk List"
          @@ -14,2 +14,2 @@ en:
          -      risk_authorisers: "Risk Authorisers"
          -      travel_arrangers: Travel Arrangers
          +      risk_authorisers: "Risk Authoriser"
          +      travel_arrangers: Travel Arranger
          @@ -20 +19,0 @@ en:
          -      travel_doctor: "Travel Doctor"
          @@ -28,0 +28 @@ en:
          +        blah: Blah
          diff --git a/config/locales/ja/old.yml b/config/locales/ja/layouts.yml
          index 769b1b01b..2c79630e2 100644
          --- a/config/locales/ja/old.yml
          +++ b/config/locales/ja/layouts.yml
          @@ -8 +8 @@ ja:
          -      country_risk_lists: "国別リスク一覧"
          +      country_risk_lists: "[JP] Country Risk List"
          @@ -15 +15 @@ ja:
          -      travel_arrangers: "代理手配担当者"
          +      travel_arrangers: Travel Arranger
                  DIFF
      end
      let(:bodies) { diff_output.split(/^diff/).flat_map { |file_diff| file_diff.split(/^@@\s+.*?\n/).drop(1) } }

      it "returns file diffs broken into hunks" do
        allow(git_diff).to receive(:diff).and_return diff_output

        expect(git_diff.call).to eq(
          "config/locales/en/layouts.yml" => [
            [  8... 9,  8... 9, bodies[0] ],
            [ 14...16, 14...16, bodies[1] ],
            [ 20...21, 19...19, bodies[2] ],
            [ 28...28, 28...29, bodies[3] ]
          ],
          "config/locales/ja/layouts.yml" => [
            [  8... 9,  8... 9,  bodies[4] ],
            [ 15...16, 15...16, bodies[5] ]
          ]
        )
      end
    end
  end
end
