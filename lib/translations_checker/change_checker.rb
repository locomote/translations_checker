require "translations_checker/concerns/service"
require "translations_checker/issue"

module TranslationsChecker
  ChangeChecker = Struct.new(:this_change, :other_change) do
    include Concerns::Service

    def not_a_string
      return NonIssue.new unless this_change.new_value.is_a?(String)
    end

    def not_deleted
      return unless this_change.deleted?
      return NonIssue.new if other_change.deleted?

      NotDeleted.new(this_change, other_change)
    end

    def missing_or_unchanged
      return unless other_change.is_a? NoChange

      if this_change.added?
        MissingNewKey.new(this_change, other_change)
      else
        UnchangedKey.new(this_change, other_change)
      end
    end

    def incorrect_format
      return NonIssue.new if other_change.new_value =~ /\A\[#{other_change.locale}\]/i

      IncorrectFormat.new(this_change, other_change)
    end

    def call
      not_a_string || not_deleted || missing_or_unchanged || incorrect_format
    end
  end
end
