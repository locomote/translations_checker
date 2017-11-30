require "translations_checker/locale_file"
require "translations_checker/diff_block"
require "translations_checker/delegation"

module TranslationsChecker
  class Diff
    include Delegation

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
      @blocks ||= hunks.map { |old_lines, new_lines, body| DiffBlock.new(self, old_lines, new_lines, body) }
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
