require "translations_checker/locale_file"

require "yaml"

module TranslationsChecker
  class LocaleFileContent
    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml
    end

    def [](key_path)
      return content if key_path.empty?

      content.dig(*key_path)
    end

    def to_h
      content
    end

    private

    def content
      @content ||= YAML.safe_load(yaml, aliases: true)
    end
  end
end
