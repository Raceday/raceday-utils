# lib/raceday/data_object/fields/base.rb

module Raceday
  module DataObject
    module Fields
      class Base
        attr_accessor :name, :options

        def initialize(name, options = {})
          @name = name
          @options = options
        end

        def default_value
          @options.fetch(:default, nil)
        end

        def type
          @type ||= options[:type] || Object
        end
      end
    end
  end
end
