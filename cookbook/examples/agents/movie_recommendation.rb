# frozen_string_literal: true

require "rubigent"

module Cookbook
  module Examples
    module Agents
      class MovieRecommendation
        def self.run_example
          # Create a movie recommendation agent
          agent = Rubigent::Agent.new(
            model: Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo"),
            description: "You are a movie recommendation expert. You suggest movies based on user preferences and explain why they might enjoy them.",
            markdown: true
          )

          # Example prompts
          prompts = [
            "I like sci-fi movies with philosophical themes like Blade Runner and The Matrix.",
            "I enjoy light-hearted comedies from the 90s.",
            "Recommend me a thriller that will keep me on the edge of my seat."
          ]

          # Run the agent with each prompt
          prompts.each do |prompt|
            puts "\n" + "=" * 50
            puts "PROMPT: #{prompt}"
            puts "=" * 50

            response = agent.run(prompt)
            puts response.content
          end
        end
      end
    end
  end
end

# You can run: ruby cookbook/examples/agents/movie_recommendation.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::Examples::Agents::MovieRecommendation.run_example
end
