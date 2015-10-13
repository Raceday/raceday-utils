# lib/raceday/data_object/base.rb

require_relative "./dsl"

module Raceday
  module DataObject
    class Base
      include ActiveModel::Model
      include ActiveModel::Dirty
      extend ActiveModel::Callbacks
      include Raceday::DataObject::Dsl

      def initialize(attributes = {})
        super attributes
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
    end
  end
end
