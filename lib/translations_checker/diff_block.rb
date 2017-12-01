require "translations_checker/change"

module TranslationsChecker
  class DiffBlock
    attr_reader :file_diff, :old_line, :new_line, :body

    def initialize(file_diff, old_line, new_line, body)
      @file_diff = file_diff
      @old_line = old_line
      @new_line = new_line
      @body = body
    end

    # :reek:NestedIterators
    def changes
      @changes ||= begin
        @changes = key_changes_by_key.map do |key, key_changes|
          # Grouping by :last gives us something like this:
          #   "-" => [["key_2", 2, "-"]],
          #   "+" => [["key_2", 1, "+"]]
          # which we transform into:
          #   { "-" => 2, "+" => 1 }
          key_change = key_changes.group_by(&:last).map { |type, change| [type, change.flatten[1]] }.to_h
          Change.new(file_diff, key, key_change)
        end
      end
    end

    private

    def changed_lines
      body.lines
    end

    # This gives us an array of arrays in the form, with the middle value being the line number:
    #   ["key_1", 1, "-"],
    #   ["key_2", 2, "-"],
    #   ["key_2", 1, "+"],
    #   ["key_3", 2, "+"]
    # Note that any lines that don't match the regex will be discarded.
    def key_changes
      changed_lines.map(&key_change_factory).compact
    end

    def key_change_factory
      counters = { "-" => old_line - 1, "+" => new_line - 1 }
      proc do |line|
        counters[line[0]] += 1
        change_type, key = line.scan(/^([+-])\s*(\w+):/).flatten
        [key, counters[change_type], change_type] if change_type
      end
    end

    # Grouping key_changes by :first gives us:
    #   "key_1" => [["key_1", 1, "-"]],
    #   "key_2" => [["key_2", 2, "-"], ["key_2", 1, "+"]],
    #   "key_3" => [["key_3", 2, "+"]]
    def key_changes_by_key
      key_changes.group_by(&:first)
    end
  end
end
