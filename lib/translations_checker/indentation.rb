module TranslationsChecker
  module Indentation
    refine String do
      def indent(indentation = "  ")
        gsub(/^/, indentation)
      end
    end
  end
end
