# lib/raceday/presenter.rb

module Raceday
  class Presenter < SimpleDelegator

    def initialize(base, view_context = nil)
      if base.is_a? Array
        self.class.wrap_collection base
      else
        @view_context = view_context || ActionController::Base.new.view_context
        super(base)
      end
    end

    def context
      @view_context
    end

    def model
      @model ||= __getobj__
    end

    class << self
      # Wraps a a collection of objects with the presenter
      def wrap_collection(collection)
        collection.map{ |_obj| self.new(_obj) }
      end
    end

  end
end
