require "translations_checker/locale_file_key_map"
require "translations_checker/locale_file_content"
require "translations_checker/git_show"

require "pathname"
require "active_support/all"

# :reek:TooManyInstanceVariables
module TranslationsChecker
  class LocaleFile
    attr_reader :path

    delegate :exist?, :to_s, to: :path
    delegate :key_at,        to: :key_map
    delegate :[],            to: :content

    def initialize(path)
      @path = Pathname(path)
    end

    def locale
      @locale ||= path.relative_path_from(LOCALES_DIR).descend.first.to_s
    end

    def for_locale(other_locale)
      return self if other_locale == locale

      other_path = LOCALES_DIR + other_locale + relative_path
      if other_path.basename.to_s == "#{locale}.yml"
        other_path = other_path.parent + "#{other_locale}.yml"
      end

      LocaleFile.new(other_path)
    end

    def ==(other)
      path == other.path
    end

    def content
      @content ||= LocaleFileContent.new(GitShow.call(path))
    end

    def key_map
      @key_map ||= LocaleFileKeyMap.new(content)
    end

    private

    def locale_dir
      LOCALES_DIR + locale
    end

    def relative_path
      @relative_path ||= path.relative_path_from(locale_dir)
    end
  end
end
