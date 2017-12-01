require "translations_checker/terminal_colours"
require "translations_checker/indentation"

module TranslationsChecker
  class IssuePresenter
    include TerminalColours

    using Indentation

    attr_reader :issue

    def initialize(issue)
      @issue = issue
    end

    def report
      @report ||= issue.report
    end

    def reason
      [red(issue.reason), yellow(issue.reason_detail)].compact.join(" -> ")
    end

    def path_with_line(path, new_line, old_line)
      [cyan(path), yellow(new_line) || red(old_line)].compact.join(":")
    end

    def source
      path_with_line(issue.source_path, issue.new_source_line, issue.old_source_line)
    end

    def destination
      path_with_line(issue.destination_path, issue.new_destination_line, issue.old_destination_line)
    end

    def to_s
      <<~TEXT
        #{magenta(issue.display_key.join('.'))}:
          source:      #{source}
          destination: #{destination}
          reason:      #{reason}
      TEXT
    end

    def self.present(issue)
      new(issue).to_s
    end
  end
end
