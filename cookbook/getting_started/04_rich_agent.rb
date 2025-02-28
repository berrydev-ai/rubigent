# frozen_string_literal: true

require "rubigent"

module Cookbook
  module GettingStarted
    class RichAgent
      def self.run_example
        # Create a rich agent with streaming enabled
        agent = Rubigent::RichAgent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo"),
          description: "You are a helpful assistant.",
          stream: true
        )

        # Run the agent with a prompt
        puts "Running rich agent example with streaming..."
        puts "=" * 50

        prompt = "What are the top 3 benefits of using Ruby for AI development? Explain each benefit in detail."

        # This will display the response in a rich box with streaming updates
        agent.print_response(prompt)

        # You can also run without streaming
        puts "\n\nRunning rich agent example without streaming..."
        puts "=" * 50

        prompt = "What are 3 challenges of AI development in Ruby and how to overcome them?"

        # Disable streaming for this call
        agent.print_response(prompt, stream: false)
      end
    end
  end
end

# You can run: ruby cookbook/getting_started/04_rich_agent.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::GettingStarted::RichAgent.run_example
end
