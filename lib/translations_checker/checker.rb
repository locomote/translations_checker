require "translations_checker/diff"
require "translations_checker/issue"
require "translations_checker/issues_presenter"
require "translations_checker/terminal_colours"
require "translations_checker/indentation"
require "translations_checker/git_diff"

module TranslationsChecker
  class Checker
    include TerminalColours

    using Indentation

    def file_issues(en_diff)
      translated_locales.flat_map { |locale| check_translation(locale, en_diff) }
    end

    def issues
      @issues ||= diffs_for_locale("en").flat_map(&method(:file_issues))
    end

    # :reek:TooManyStatements
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def run
      if issues.empty?
        puts green("No translations issues detected.")
        return
      end

      puts yellow("Please correct the following translations issues before pushing:")
      puts
      puts IssuesPresenter.new(diffs_for_locale("en").flat_map(&method(:file_issues)))
      puts
      puts example
      puts
      puts yellow("Don't forget to keep the .yml keys hierarchy\n")
      exit 1
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def self.run
      new.run
    end

    private

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
      diffs.detect { |diff| diff.locale_file == locale_file } || EmptyDiff.new(locale_file)
    end

    def check_deleted_change(en_change, locale_change)
      NotDeleted.new(en_change, locale_change) unless locale_change.deleted?
    end

    # :reek:NilCheck, :reek:FeatureEnvy
    # rubocop:disable Metrics/MethodLength
    def check_change(en_change, locale_change)
      if en_change.deleted?
        check_deleted_change(en_change, locale_change)
      elsif locale_change.nil?
        if en_change.added?
          MissingNewKey.new(en_change, locale_change)
        else
          UnchangedKey.new(en_change, locale_change)
        end
      elsif locale_change.new_value !~ /\A\[#{locale_change.file_diff.locale}\]/
        IncorrectFormat.new(en_change, locale_change)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def locales
      @locales ||= LOCALES_DIR.children.select(&:directory?).map(&:basename).map(&:to_s)
    end

    def translated_locales
      @translated_locales ||= locales - %w(en en-AU)
    end

    def diffs
      @diffs ||= GitDiff.call(LOCALES_DIR).map do |path, hunks|
        Diff.new(path, hunks)
      end
    end

    def check_translation(locale, en_diff)
      locale_diff = diff_for_locale_file(en_diff.locale_file.for_locale(locale))
      en_diff.match_changes(locale_diff).map do |en_change, locale_change|
        check_change(en_change, locale_change)
      end.compact
    end
  end
end
