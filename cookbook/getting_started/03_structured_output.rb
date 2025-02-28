# frozen_string_literal: true

require "rubigent"

module Cookbook
  module GettingStarted
    class StructuredOutput
      def self.run_example
        # Create an agent with structured output
        agent = Rubigent::Agent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
          description: "You write movie scripts. Provide output as JSON with keys: setting, ending, genre, name, characters (array), storyline.",
          response_model: Rubigent::Examples::MovieScript,
          structured_outputs: true
        )

        # Run the agent with a prompt
        puts "Running structured output example..."
        puts "=" * 50

        prompt = "Create a movie script set in New York"
        puts "PROMPT: #{prompt}"
        puts "-" * 50

        # Get the response as a structured object
        response = agent.run(prompt)
        movie_script = response.content

        # Access the structured data
        puts "STRUCTURED OUTPUT:"
        puts "Title: #{movie_script.name}"
        puts "Genre: #{movie_script.genre}"
        puts "Setting: #{movie_script.setting}"
        puts "Characters: #{movie_script.characters.join(", ")}"
        puts "Storyline: #{movie_script.storyline}"
        puts "Ending: #{movie_script.ending}"
      end
    end
  end
end

# You can run: ruby cookbook/getting_started/03_structured_output.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::GettingStarted::StructuredOutput.run_example
end
