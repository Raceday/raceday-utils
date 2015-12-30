# lib/raceday/enums/bitwise.rb

module Raceday
  module Enums
    module Bitwise
      extend ActiveSupport::Concern

      included do
        class_attribute :ofi_bitwise_enumerations
        self.ofi_bitwise_enumerations = {}
      end

      ## General Class Methods ------------------------------
      ##
      module ClassMethods
        ## Take the enum values that have been provided and
        ## build the enumeration power of 2 values
        ##
        def build_enumeration_from(values)
          enumeration = {}
          values.each_with_index.map{ |name, idx| enumeration[name.to_sym] = 2 ** idx }
          return enumeration
        end

        ## Define the Enum test methods
        ##
        ## @example myObject.enum_value?
        ## => true | false
        ##
        def define_enum_tests(enum_name)
          enumeration = ofi_bitwise_enumerations[enum_name][:values]

          enumeration.each do |name, value|
            method_name = "#{ name }?".to_sym
            raise RuntimeError.new "The method #{ method_name } already exists on this class." if respond_to? method_name

            define_method method_name do
              current_value = instance_variable_get "@#{ enum_name }"
              current_value | value == current_value
            end
          end
        end

        ## Define a method that will return the currently
        ## set flags for the object
        ##
        ## @example myObject.current_my_enum_flags
        ## => [:status1, :status2, ...]
        ##
        ## This method will define a method that allows you
        ## to see which flags have currently been set on this
        ## object using the enumerations setter method
        ##
        def define_current_flags_method(enum_name)
          method_name = "current_#{ enum_name }_flags".to_sym
          raise RuntimeError.new "The method #{ method_name } already exists on this class." if respond_to? method_name

          define_method method_name do
            enumeration   = ofi_bitwise_enumerations[enum_name.to_sym][:values]
            current_state = instance_variable_get "@#{ enum_name }".to_sym

            enumeration.select{ |k,v| (current_state | v == current_state) }.map{ |k,v| k }
          end
        end

        ## Define the Enum getter method
        ##
        ## @example myObject.my_enums
        ## => [:status1, :status2, :status3, ...]
        ##
        ## This method will define a pluralized getter for
        ## the enumeration that will return an array of
        ## of the values you defined for the enumeration.
        ##
        def define_enum_getter(enum_name)
          method_name = "#{ enum_name.to_s.pluralize }"
          raise RuntimeError.new "The method #{ method_name } already exists on this class." if respond_to? method_name

          define_method method_name do
            ofi_bitwise_enumerations[enum_name.to_sym][:values].map{ |k,v| k }
          end
        end

        ## Define the Enum setter method
        ##
        ## @example myObject.my_enum = :status1, :status2, ...
        ##
        ## This method will set teh enum attribute to the
        ## proper bitwise value so that each flag can
        ## be properly tested for using the test helpers
        ##
        def define_enum_setter(enum_name)
          method_name = "#{ enum_name }="
          raise RuntimeError.new "The method #{ method_name } already exists on this class." if respond_to? method_name

          define_method method_name do |*values|
            enumeration             = ofi_bitwise_enumerations[enum_name][:values].select{ |k,v| values.flatten.include?(k) }
            instance_variable_name  = "@#{ enum_name }".to_sym

            ## Using a Bitwise "|" (OR) we will combine all of our flags
            ## to create the value to be stored.
            ##
            instance_variable_set instance_variable_name.to_sym, enumeration.map{ |k,v| v }.reduce(0) { |result, n| result | n }
          end
        end

        def bitwise_enum(enum_name, *enum_values)
          options     = enum_values.extract_options!
          enumeration = build_enumeration_from(enum_values)

          ofi_bitwise_enumerations[enum_name.to_sym] = {
            values: enumeration,
            options: options
          }

          ## Add the attribute that will hold the value for
          ## this enum
          ##
          attr_accessor enum_name.to_sym

          ## Define a helper for getting an array with all of
          ## the enum values
          ##
          define_enum_getter enum_name

          ## Define the setter for this enumeration
          ##
          define_enum_setter enum_name

          # build_helper_methods! enum_name, enum_values
          define_enum_tests enum_name
          define_current_flags_method enum_name
        end
      end
    end
  end
end
