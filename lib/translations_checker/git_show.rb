require "translations_checker/concerns/service"

module TranslationsChecker
  class GitShow
    include Concerns::Service

    attr_reader :path, :ref

    def initialize(path, ref: "HEAD")
      @path = path
      @ref = ref
    end

    def call
      cmd = %W(git show "#{ref}:#{path}")
      `#{cmd.join(" ")}`
    end
  end
end
