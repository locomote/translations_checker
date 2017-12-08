require "active_support/all"

module TranslationsChecker
  class Change
    attr_reader :file_diff, :name, :new_line, :old_line

    delegate :locale, :locale_file,                                to: :file_diff
    delegate :old_key_at, :new_key_at, :old_content, :new_content, to: :locale_file

    def initialize(file_diff, name, change)
      @file_diff = file_diff
      @name = name
      @new_line, @old_line = change.values_at("+", "-")
    end

    def full_key
      deleted? ? old_key_at(old_line) : new_key_at(new_line)
    end

    def new_value
      deleted? ? nil : new_content[full_key]
    end

    def old_value
      added? ? nil : old_content[full_key]
    end

    def display_key
      full_key.drop(1)
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
end
