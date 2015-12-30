require 'bigdecimal'

module Raceday
  module Utils
    module Banker
      extend ActiveSupport::Concern

      # Instance Methods ----------------------------------

      private # -------------------------------------------

      def banker_convert_to_dollars(value_in_cents)
        Money.new(value_in_cents).to_s
      end

      def banker_convert_to_cents(value_in_dollars)
        (value_in_dollars.to_s.gsub(',', '').to_d * 100).to_i
      end

      module ClassMethods # -------------------------------
        #
        ##
        def banker_fields(*args)
          args.each do |_field_name|
            _getter          = _field_name.to_sym
            _setter          = "#{ _field_name }=".to_sym
            _instance_getter = "#{ _field_name }_in_cents".to_sym
            _instance_setter = "#{ _field_name }_in_cents=".to_sym

            send :define_method, _getter do
              banker_convert_to_dollars send(_instance_getter)
            end

            send :define_method, _setter do |value|
              send _instance_setter, banker_convert_to_cents(value)
            end
          end
        end
      end
    end
  end
end
