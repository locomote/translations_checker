module TranslationsChecker
  module Delegation
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    # :reek:NestedIterators
    module ClassMethods
      def delegate(*methods, to:, prefix: nil)
        methods.each do |method|
          prefixed_method = [prefix, method].compact.join("_")
          define_method(prefixed_method) do |*args|
            send(to).send(method, *args)
          end
        end
      end
    end
  end
end
