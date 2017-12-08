require "translations_checker/concerns/service"

module TranslationsChecker
  class GitShow
    include Concerns::Service

    attr_reader :path, :ref

    REF_ALIASES = {
      current:  "HEAD",
      original: "$(git merge-base origin/master HEAD)"
    }.freeze

    def initialize(path, ref: :current)
      @path = path
      @ref = REF_ALIASES.fetch(ref, ref)
    end

    def call
      cmd = %W(git show "#{ref}:#{path}")
      `#{cmd.join(" ")}`
    end
  end
end
