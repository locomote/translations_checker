module TranslationsChecker
  class GitDiff
    DEFAULT_OPTIONS = { diff_filter: "AM" }.freeze

    attr_reader :path, :ref

    def initialize(path, ref:)
      @path = path
      @ref = ref
    end

    def diff
      cmd = %w(git diff --diff-filter=AM --unified=0) + %W("#{ref}" "#{path}")
      `#{cmd.join(" ")}`
    end

    def call
      diff.split(/^(?=diff\s--git\s)/).each_with_object({}) do |file_diff, memo|
        memo[path_from_file_diff(file_diff)] = hunks_from_file_diff(file_diff)
      end
    end

    def self.call(path, ref: "origin/master")
      new(path, ref: ref).call
    end

    private

    def path_from_file_diff(file_diff)
      file_diff.scan(%r[^\+{3}\sb/(.*?)$]).flatten.first
    end

    # Parses hunk ranges in the format "<line>[,<size>]". Note that <size> defaults to 1.
    #
    #   "123,4" => 123...127
    #   "321,0" => 321...321
    #   "123"   => 123...124
    #
    # :reek:NilCheck
    def to_hunk_range(string)
      line, size = string.scan(/\A(\d+)(?:,(\d+))?\z/).flatten
      line = line.to_i
      line...(line + (size&.to_i || 1))
    end

    def hunks_from_file_diff(file_diff)
      file_diff.split(/(?=^@@\s+.*?\s+@@)/).drop(1).map do |diff_hunk|
        *hunk_ranges, body = diff_hunk.scan(/\A@@\s+-(\d+(?:,\d+)?)\s+\+(\d+(?:,\d+)?).*?\n(.*)\z/m).flatten
        [*hunk_ranges.map(&method(:to_hunk_range)), body]
      end
    end
  end
end
