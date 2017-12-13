require "spec_helper"

require "translations_checker/change"
require "translations_checker/no_change"
require "translations_checker/change_checker"

RSpec.describe TranslationsChecker::ChangeChecker do
  describe "#not_a_string" do
    subject(:not_a_string_result) { checker.not_a_string }

    let(:checker) { described_class.new this_change, nil }

    context "when this change is a string value" do
      let(:this_change) { instance_double TranslationsChecker::Change, :this_change, new_value: "A string" }

      it "returns nil" do
        expect(not_a_string_result).to be_nil
      end
    end

    context "when this change is not a string value" do
      let(:this_change) { instance_double TranslationsChecker::Change, :this_change, new_value: { a: "non-string value" } }

      it "returns a non-issue" do
        expect(not_a_string_result).to be_a TranslationsChecker::NonIssue
      end
    end
  end

  describe "#not_deleted" do
    context "when this change is not a deletion" do
      it "returns nil" do
        checker = described_class.new(instance_double(TranslationsChecker::Change, :this_change, deleted?: false), nil)
        expect(checker.not_deleted).to be_nil
      end
    end

    context "when this change is a deletion" do
      subject(:not_deleted_result) { checker.not_deleted }

      let(:this_change) { instance_double TranslationsChecker::Change, :this_change, deleted?: true }
      let(:checker)     { described_class.new this_change, other_change }

      context "when the other change is not a deletion" do
        let(:other_change) { instance_double TranslationsChecker::Change, :other_change, deleted?: false }

        it "returns a not-deleted issue", :aggregate_failures do
          expect(not_deleted_result).to be_a TranslationsChecker::NotDeleted
          expect(not_deleted_result.change).to be this_change
          expect(not_deleted_result.locale_change).to be other_change
        end
      end

      context "when the other change is a deletion" do
        let(:other_change) { instance_double TranslationsChecker::Change, :other_change, deleted?: true }

        it "returns a non-issue" do
          expect(not_deleted_result).to be_a TranslationsChecker::NonIssue
        end
      end
    end
  end

  describe "#missing_or_unchanged" do
    subject(:missing_or_unchanged_result) { checker.missing_or_unchanged }

    let(:checker) { described_class.new(this_change, other_change) }

    context "when the other change is a no-change" do
      let(:other_change) { TranslationsChecker::NoChange.new(nil, nil) }

      context "when this change is an addition" do
        let(:this_change) { instance_double TranslationsChecker::Change, :this_change, added?: true }

        it "returns a missing-new-key issue", :aggregate_failures do
          expect(missing_or_unchanged_result).to be_a TranslationsChecker::MissingNewKey
          expect(missing_or_unchanged_result.change).to be this_change
          expect(missing_or_unchanged_result.locale_change).to be other_change
        end
      end

      context "when this change is not an addition" do
        let(:this_change) { instance_double TranslationsChecker::Change, :this_change, added?: false }

        it "returns an unchanged issue", :aggregate_failures do
          expect(missing_or_unchanged_result).to be_a TranslationsChecker::UnchangedKey
          expect(missing_or_unchanged_result.change).to be this_change
          expect(missing_or_unchanged_result.locale_change).to be other_change
        end
      end
    end

    context "when the other change is not a no-change" do
      let(:other_change) { instance_double TranslationsChecker::Change, :other_change }
      let(:this_change)  { instance_double TranslationsChecker::Change, :this_change }

      it "returns nil" do
        expect(missing_or_unchanged_result).to be_nil
      end
    end
  end

  describe "#incorrect_format" do
    subject(:incorrect_format_result) { checker.incorrect_format }

    let(:this_change) { instance_double TranslationsChecker::Change, :this_change }
    let(:checker)     { described_class.new(this_change, other_change) }

    context "when the new value for the other change has the correct locale prefix" do
      let(:other_change) { instance_double TranslationsChecker::Change, :other_change, new_value: "[ja] the text", locale: "ja" }

      it "returns a non-issue" do
        expect(incorrect_format_result).to be_a TranslationsChecker::NonIssue
      end
    end

    context "when the new value for the other change has an incorrect locale prefix" do
      let(:other_change) { instance_double TranslationsChecker::Change, :other_change, new_value: "[JP] the text", locale: "ja" }

      it "returns an incorrect-format issue", :aggregate_failures do
        expect(incorrect_format_result).to be_a TranslationsChecker::IncorrectFormat
        expect(incorrect_format_result.change).to be this_change
        expect(incorrect_format_result.locale_change).to be other_change
      end
    end

    context "when the new value for the other change has no locale prefix" do
      let(:other_change) { instance_double TranslationsChecker::Change, :other_change, new_value: "the text", locale: "ja" }

      it "returns an incorrect-format issue" do
        expect(incorrect_format_result).to be_a TranslationsChecker::IncorrectFormat
        expect(incorrect_format_result.change).to be this_change
        expect(incorrect_format_result.locale_change).to be other_change
      end
    end
  end

  describe "#call" do
    let(:checker) { described_class.new(nil, nil) }

    context "when this change is not a string value" do
      it "returns a non-issue" do
        non_issue = double :non_issue
        expect(checker).to receive(:not_a_string).and_return non_issue
        expect(checker.call).to be non_issue
      end
    end

    context "when this change is a string value" do
      before do
        allow(checker).to receive(:not_a_string).and_return nil
      end

      context "when this change is a deletion" do
        before do
          allow(checker).to receive(:missing_or_unchanged).and_return "missing or unchanged"
          allow(checker).to receive(:incorrect_format).and_return "incorrect format"
        end

        context "when the other change is a deletion" do
          it "returns a non-issue" do
            non_issue = double :non_issue
            expect(checker).to receive(:not_deleted).and_return non_issue
            expect(checker.call).to be non_issue
          end
        end

        context "when the other change is not a deletion" do
          it "returns a not-deleted issue" do
            not_deleted_issue = double :not_deleted
            expect(checker).to receive(:not_deleted).and_return not_deleted_issue
            expect(checker.call).to be not_deleted_issue
          end
        end
      end

      context "when this change is not a deletion" do
        before do
          allow(checker).to receive(:not_deleted).and_return nil
        end

        context "when the other change is a no-change" do
          it "returns either a missing-new-key or unchanged-key issue" do
            allow(checker).to receive(:incorrect_format).and_return "incorrect format"

            missing_or_unchanged_issue = double :missing_or_unchanged
            expect(checker).to receive(:missing_or_unchanged).and_return missing_or_unchanged_issue
            expect(checker.call).to be missing_or_unchanged_issue
          end
        end

        context "when the other change is not a no-change" do
          before do
            allow(checker).to receive(:missing_or_unchanged).and_return nil
          end

          context "when there is an incorrect-format issue" do
            it "returns an incorrect-format issue" do
              incorrect_format_issue = double :incorrect_format_issue
              expect(checker).to receive(:incorrect_format).and_return incorrect_format_issue
              expect(checker.call).to be incorrect_format_issue
            end
          end

          context "when there is not an incorrect-format issue" do
            it "returns a non-issue" do
              non_issue = double :non_issue
              expect(checker).to receive(:incorrect_format).and_return non_issue
              expect(checker.call).to be non_issue
            end
          end
        end
      end
    end
  end
end
