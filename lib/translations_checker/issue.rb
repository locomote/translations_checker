require "active_support/all"

module TranslationsChecker
  class Issue
    attr_reader :change, :locale_change

    delegate :display_key, to: :change

    def initialize(change, locale_change)
      @change = change
      @locale_change = locale_change
    end

    def locale_diff
      locale_change.file_diff
    end

    def source_path
      change.file_diff.path
    end

    def new_source_line
      change.new_line
    end

    def old_source_line
      change.old_line
    end

    def destination_path
      locale_diff.path
    end

    def new_destination_line
      locale_change.new_line
    end

    def old_destination_line
      locale_change.old_line
    end

    def reason_detail
      nil
    end

    def problem?
      true
    end
  end

  class NonIssue
    def problem?
      false
    end
  end

  class MissingNewKey < Issue
    def reason
      "MISSING"
    end
  end

  class UnchangedKey < Issue
    def reason
      "NOT CHANGED IN DESTINATION"
    end
  end

  class NotDeleted < Issue
    def reason
      "NOT REMOVED FROM DESTINATION"
    end
  end

  class IncorrectFormat < Issue
    delegate :new_value, to: :locale_change

    def destination
      "#{destination_path}:#{locale_change.new_line}"
    end

    def reason_detail
      new_value.inspect
    end

    def incorrect?
      new_value =~ /\A\[\w+\]/
    end

    def reason
      [incorrect? ? "INCORRECT" : "MISSING", "TRANSLATION LABEL"].join(" ")
    end
  end
end
