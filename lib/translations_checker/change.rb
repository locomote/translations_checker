require "naught"

module TranslationsChecker
  class Change
    attr_reader :file_diff, :name, :new_line, :old_line

    def initialize(file_diff, name, change)
      @file_diff = file_diff
      @name = name
      @new_line, @old_line = change.values_at("+", "-")
    end

    def new_value
      deleted? ? nil : file_diff.locale_file[full_key]
    end

    def full_key
      file_diff.locale_file.key_at(new_line)
    end

    def display_key
      deleted? ? [name] : full_key.drop(1)
    end

    # :reek:NilCheck
    def added?
      old_line.nil?
    end

    # :reek:NilCheck
    def deleted?
      new_line.nil?
    end

    # rubocop:disable Style/DoubleNegation
    def changed?
      !!(old_line && new_line)
    end
    # rubocop:enable Style/DoubleNegation

    def matches?(other)
      other_key = other.full_key
      if full_key && other_key
        full_key[1..-1] == other_key[1..-1]
      else
        name == other.name
      end
    end

    def ==(other)
      file_diff == other.file_diff && name == other.name && old_line == other.old_line && new_line == other.new_line
    end
  end

  # TODO: I'm being a bit lazy here - I'm using the naught gem, even though this doesn't exactly fit the usual
  #       null-object pattern
  NoChange = Naught.build do |config|
    config.predicates_return false
    config.mimic Change

    attr_reader :file_diff, :full_key

    def initialize(file_diff, full_key)
      @file_diff = file_diff
      @full_key = full_key
    end

    def name
      full_key.last
    end

    def display_key
      full_key.drop([1, full_key.size - 1].min)
    end

    def nil?
      true
    end
  end
end
