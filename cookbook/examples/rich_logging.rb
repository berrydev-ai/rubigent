# frozen_string_literal: true

require "rubigent"

module Cookbook
  module Examples
    class RichLogging
      def self.run_example
        puts "Rubigent Rich Logging Example"
        puts "=" * 50
        puts "This example demonstrates how to use rich logging with streaming output."
        puts

        # Create a rich agent with streaming enabled
        agent = Rubigent::RichAgent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
          description: "You are a helpful assistant that provides detailed explanations.",
          stream: true
        )

        # Define a complex prompt that will generate a longer response
        prompt = <<~PROMPT
          I'm learning about Ruby metaprogramming. Can you explain:
          1. What is metaprogramming in Ruby?
          2. What are the key techniques used in Ruby metaprogramming?
          3. Can you provide a practical example of metaprogramming in Ruby?
        PROMPT

        # Run the agent with streaming output
        puts "Running agent with streaming output..."
        agent.print_response(prompt)
      end
    end
  end
end

# You can run: ruby cookbook/examples/rich_logging.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::Examples::RichLogging.run_example
end
