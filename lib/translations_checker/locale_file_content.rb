require "translations_checker/locale_file"

require "yaml"
require "fossicker"

module TranslationsChecker
  class LocaleFileContent
    using Fossicker

    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml
    end

    def [](key_path)
      content.fossick(*key_path, default: nil)
    end

    def to_h
      content
    end

    private

    def content
      @content ||= YAML.safe_load(yaml, [], [], true)
    end
  end
end
