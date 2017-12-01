require "translations_checker/issue_presenter"
require "translations_checker/concerns/service"

module TranslationsChecker
  class IssuesPresenter
    include Concerns::Service
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
    def call
      issues_by_destination_path.map do |path, issues|
        [green(path), *issues.map { |issue| IssuePresenter.present(issue).strip.indent("  ") }].join("\n")
      end.join("\n\n")
    end
  end
end
