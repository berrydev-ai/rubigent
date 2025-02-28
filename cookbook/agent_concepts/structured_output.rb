# frozen_string_literal: true

require "rubigent"

module Cookbook
  module AgentConcepts
    class StructuredOutput
      def self.run_example
        # Agent that uses JSON mode
        json_mode_agent = Rubigent::Agent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
          description: "You write movie scripts. Provide output as JSON with keys: setting, ending, genre, name, characters (array), storyline.",
          response_model: Rubigent::Examples::MovieScript,
          structured_outputs: true
        )

        # Get the response in a variable
        response = json_mode_agent.run("New York")
        movie_script = response.content

        # Print the structured output
        puts "Setting: #{movie_script.setting}"
        puts "Ending: #{movie_script.ending}"
        puts "Genre: #{movie_script.genre}"
        puts "Name: #{movie_script.name}"
        puts "Characters: #{movie_script.characters.join(", ")}"
        puts "Storyline: #{movie_script.storyline}"
      end
    end
  end
end

# You can run: ruby cookbook/agent_concepts/structured_output.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::AgentConcepts::StructuredOutput.run_example
end
