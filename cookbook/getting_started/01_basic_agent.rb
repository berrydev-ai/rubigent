# frozen_string_literal: true

require "rubigent"

module Cookbook
  module GettingStarted
    class BasicAgent
      def self.run_example
        # Create a simple agent
        agent = Rubigent::Agent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo"),
          description: "You are a helpful assistant."
        )

        # Run the agent with a prompt
        puts "Running basic agent example..."
        puts "=" * 50

        prompt = "What are the top 3 benefits of using Ruby for AI development?"
        puts "PROMPT: #{prompt}"
        puts "-" * 50

        response = agent.run(prompt)
        puts "RESPONSE:"
        puts response.content
      end
    end
  end
end

# You can run: ruby cookbook/getting_started/01_basic_agent.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::GettingStarted::BasicAgent.run_example
end
