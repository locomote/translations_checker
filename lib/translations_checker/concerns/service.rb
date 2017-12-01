require "active_support/all"

module TranslationsChecker
  module Concerns
    module Service
      extend ActiveSupport::Concern

      class_methods do
        def call(*args)
          new(*args).call
        end
      end
    end
  end
end