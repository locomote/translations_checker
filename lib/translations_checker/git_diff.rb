require "translations_checker/concerns/service"

module TranslationsChecker
  class GitDiff
    include Concerns::Service

    attr_reader :path, :ref

    def initialize(path, ref: "origin/master...HEAD")
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

    private

    def path_from_file_diff(file_diff)
      file_diff.scan(%r[^\+{3}\sb/(.*?)$]).flatten.first
    end

    def hunks_from_file_diff(file_diff)
      file_diff.split(/(?=^@@\s+.*?\s+@@)/).drop(1).map do |diff_hunk|
        *hunk_lines, body = diff_hunk.scan(/\A@@\s+-(\d+)(?:,\d+)?\s+\+(\d+)(?:,\d+)?.*?\n(.*)\z/m).flatten
        [*hunk_lines.map(&:to_i), body]
      end
    end
  end
end
