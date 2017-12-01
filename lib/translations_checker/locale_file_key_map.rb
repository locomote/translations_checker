module TranslationsChecker
  class LocaleFileKeyMap
    def initialize(content)
      @content = content
    end

    def key_at(line_number)
      key_map[line_number]
    end

    def key_line(key)
      key_map.key(key)
    end

    private

    attr_reader :content

    def lines
      content.yaml.lines
    end

    def key_lines
      lines.each_with_index.map do |line, index|
        indent, key = line.scan(/(\A\s*)(?:(\w+):)?/).flatten
        [index + 1, indent.size / 2, key]
      end.select(&:last)
    end

    def parent_key(key_map, depth)
      key_map.values.reverse_each.detect { |key_path| key_path.size <= depth }
    end

    # :reek:ManualDispatch
    def key_map
      @key_map ||= begin
        key_map = key_lines.each_with_object({}) do |(line_number, depth, key), memo|
          memo[line_number] = [*parent_key(memo, depth), key]
        end

        key_map.select do |_, (*parent_key, name)|
          parent = content[parent_key]
          parent.respond_to?(:key?) && parent.key?(name)
        end
      end
    end
  end
end
