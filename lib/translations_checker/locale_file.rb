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
    delegate :key_at,        to: :new_key_map, prefix: :new
    delegate :key_at,        to: :old_key_map, prefix: :old

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

    def new_content
      @new_content ||= LocaleFileContent.new(GitShow.call(path))
    end

    def new_key_map
      @new_key_map ||= LocaleFileKeyMap.new(new_content)
    end

    def old_content
      @old_content ||= LocaleFileContent.new(GitShow.call(path, ref: :original))
    end

    def old_key_map
      @old_key_map ||= LocaleFileKeyMap.new(old_content)
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
