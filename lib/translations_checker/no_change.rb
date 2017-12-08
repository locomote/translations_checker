require "translations_checker/change"

require "naught"

module TranslationsChecker
  # TODO: I'm being a bit lazy here - I'm using the naught gem, even though this doesn't exactly fit the usual
  #       null-object pattern
  NoChange = Naught.build do |config|
    config.predicates_return false
    config.mimic Change

    attr_reader :file_diff, :full_key

    delegate :locale, :locale_file, to: :file_diff

    def initialize(file_diff, full_key)
      @file_diff = file_diff
      @full_key = full_key
    end

    def name
      full_key.last
    end

    def display_key
      full_key.drop(1)
    end

    def new_line
      locale_file.new_key_line(full_key)
    end
  end
end
