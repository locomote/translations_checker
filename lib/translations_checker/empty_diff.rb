require "translations_checker/diff"

module TranslationsChecker
  class EmptyDiff < Diff
    def initialize(path)
      super(path, [])
    end
  end
end
