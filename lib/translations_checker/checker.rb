require "translations_checker/diff"
require "translations_checker/empty_diff"
require "translations_checker/issues_presenter"
require "translations_checker/terminal_colours"
require "translations_checker/indentation"
require "translations_checker/git_diff"
require "translations_checker/change_checker"
require "translations_checker/concerns/service"

module TranslationsChecker
  class Checker
    include Concerns::Service
    include TerminalColours

    using Indentation

    SUPPORTED_FORMATS = %w(.yml).freeze

    # :reek:TooManyStatements
    def call
      if issues.empty?
        puts green("No translations issues detected.")
        return
      end

      puts yellow("Please correct the following translations issues before pushing:\n")
      puts IssuesPresenter.call(issues)
      puts "\n#{example}\n"
      puts yellow("Don't forget to keep the .yml keys hierarchy\n")
      exit 1
    end

    private

    def file_issues(en_diff)
      translated_locales.flat_map { |locale| check_translation(locale, en_diff) }
    end

    def issues
      @issues ||= diffs_for_locale("en").flat_map(&method(:file_issues))
    end

    def example
      <<~EXAMPLE
        ===========================
        Example:

          config/locales/en/en.yml:
            en:
              new: New

          config/locales/ja/ja.yml:
            ja:
              new: [ja] New
        ===========================
      EXAMPLE
    end

    def diffs_for_locale(locale)
      diffs.select { |diff| diff.locale == locale }
    end

    def diff_for_locale_file(locale_file)
      diffs.detect { |diff| diff.locale_file == locale_file } || EmptyDiff.new(locale_file.path)
    end

    def locales
      @locales ||= LOCALES_DIR.children.select(&:directory?).map(&:basename).map(&:to_s)
    end

    def translated_locales
      @translated_locales ||= locales - %w(en en-AU)
    end

    def git_diffs
      GitDiff.call(LOCALES_DIR)
    end

    def diffs
      @diffs ||= supported_git_diffs.map do |path, hunks|
        Diff.new(path, hunks)
      end
    end

    def supported_git_diffs
      git_diffs.select { |path, _| SUPPORTED_FORMATS.include?(File.extname(path)) }
    end

    # :reek:FeatureEnvy
    def check_translation(locale, en_diff)
      locale_diff = diff_for_locale_file(en_diff.locale_file.for_locale(locale))
      en_diff.match_changes(locale_diff).map do |en_change, locale_change|
        ChangeChecker.call(en_change, locale_change)
      end.select(&:problem?)
    end
  end
end
