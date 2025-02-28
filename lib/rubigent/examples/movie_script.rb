# frozen_string_literal: true

module Rubigent
  module Examples
    class MovieScript
      attr_accessor :setting, :ending, :genre, :name, :characters, :storyline

      def initialize(setting:, ending:, genre:, name:, characters:, storyline:)
        @setting = setting
        @ending = ending
        @genre = genre
        @name = name
        @characters = characters
        @storyline = storyline
      end
    end
  end
end
