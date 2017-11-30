require "translations_checker/issue_presenter"

module TranslationsChecker
  class IssuesPresenter
    include TerminalColours

    using Indentation

    attr_reader :issues

    def initialize(issues)
      @issues = issues
    end

    def issues_by_destination_path
      issues.group_by(&:destination_path)
    end

    # :reek:NestedIterators
    def to_s
      issues_by_destination_path.map do |path, issues|
        [green(path), *issues.map { |issue| IssuePresenter.present(issue).strip.indent("  ") }].join("\n")
      end.join("\n\n")
    end
  end
end
