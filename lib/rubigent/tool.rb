# frozen_string_literal: true

module Rubigent
  class Tool
    attr_reader :name, :description

    def initialize(name:, description:)
      @name = name
      @description = description
    end

    # Subclasses must override run(input)
    def run(input)
      raise NotImplementedError, "Subclasses must implement #run"
    end
  end
end
