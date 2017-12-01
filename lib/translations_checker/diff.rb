require "translations_checker/locale_file"
require "translations_checker/diff_block"

require "active_support/all"

module TranslationsChecker
  class Diff
    attr_reader :path, :hunks

    delegate :locale, to: :locale_file

    def initialize(path, hunks)
      @path = path
      @hunks = hunks
    end

    def locale_file
      @locale_file ||= LocaleFile.new(path)
    end

    def blocks
      @blocks ||= hunks.map { |*lines, body| DiffBlock.new(self, *lines, body) }
    end

    def changes
      blocks.flat_map(&:changes)
    end

    # :reek:FeatureEnvy
    def match_change(other_change)
      this_change = changes.detect(&other_change.method(:matches?))
      this_change || NoChange.new(self, other_change.full_key || other_change.name)
    end

    def match_changes(other_diff)
      changes.zip(changes.map(&other_diff.method(:match_change)))
    end
  end

  class EmptyDiff < Diff
    def initialize(path)
      super(path, [])
    end
  end
end
