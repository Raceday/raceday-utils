# lib/raceday/data_object/base.rb

require_relative "./dsl"

module Raceday
  module DataObject
    class Base
      include ActiveModel::Model
      include ActiveModel::Dirty
      extend ActiveModel::Callbacks
      include Raceday::DataObject::Dsl::Fields
      include Raceday::DataObject::Dsl::Callbacks

      def initialize(attributes = {})
        hydrate_attributes attributes
        changes_applied
      end

      def reload!
        clear_changes_information
      end

      def save
        changes_applied
      end

      def rollback!
        restore_attributes
      end

      private # -------------------------------------------

      def hydrate_attributes(attributes = {})
        self.class.fields.each do |key, field|
          _attribute = attributes.fetch(key, nil) || field.default_value
          instance_variable_set field.instance_variable_name, _attribute
        end
      end
    end
  end
end
