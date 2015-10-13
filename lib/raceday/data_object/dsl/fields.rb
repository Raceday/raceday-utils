# lib/raceday/data_object/dsl/fields.rb

module Raceday
  module DataObject
    module Dsl
      module Fields
        extend ActiveSupport::Concern

        included do
          class_attribute :fields
          self.fields = {}
        end

        module ClassMethods
          def field(name, options = {})
            _named = name.to_s
            _added = add_field(_named, options)

            # define_setter(name, type, options)
            # define_getter(name, options.delete(:default))

            _added
          end

          protected # ---------------------------------------

          def create_accessors(name, method_name, options = {})
            _field = fields[name]
            define_attribute_methods name.to_sym
            create_field_getter(name, method_name, _field)
            create_field_setter(name, method_name, _field)
          end

          def create_field_getter(name, method_name, field)
            generated_methods.module_eval do
              define_method("#{ method_name }") do
                _value = instance_variable_get "@#{ name }"
                _value.nil? ? field.default_value : _value
              end
            end
          end

          def create_field_setter(name, method_name, field)
            generated_methods.module_eval do
              define_method "#{ method_name }=" do |value|
                _current_value = instance_variable_get "@#{ name }"
                self.send "#{ method_name }_will_change!" unless _current_value == value
                instance_variable_set "@#{ name }", value
              end
            end
          end

          def generated_methods
            @generated_methods ||= begin
              _module = Module.new
              include(_module)
              _module
            end
          end

          def add_field(name, options = {})
            _field = field_for(name, options)
            fields[name] = _field
            create_accessors name, name, options
            _field
          end

          def field_for(name, options)
            _options = options.merge(klass: self)
            Raceday::DataObject::Fields::Standard.new(name, options)
          end
        end
      end
    end
  end
end
