# lib/raceday/banker.rb

module Raceday
  module Banker
    extend ActiveSupport::Concern

    module ClassMethods
      def currency_fields(*args)
        args.each do |field_name|
          getter           = field_name.to_sym
          setter           = "#{field_name}=".to_sym
          instance_getter  = "#{field_name}_in_cents".to_sym
          instance_setter  = "#{field_name}_in_cents=".to_sym

          # define the getter method
          send :define_method, getter do
            value = send(instance_getter)
            banker_convert_currency(value, :to_dollars)
          end

          # define the setter method
          send :define_method, setter do |value|
            send instance_setter, banker_convert_currency(value, :to_cents)
          end
        end
      end
    end

    # Instance Methods --------------------------------------------------------
    def banker_convert_currency(value, conversion)
      case conversion.to_sym
      when :to_cents
        return (value.to_s.gsub(/,/, '').to_d * 100).to_i
      when :to_dollars
        return Money.new(value).to_s
      end
    end
  end
end
