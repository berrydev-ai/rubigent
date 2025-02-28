# frozen_string_literal: true

require "rubigent"
require "concurrent"

module Cookbook
  module AgentConcepts
    module Async
      class Basic
        def self.run_example
          agent = Rubigent::Agent.new(
            model: Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo"),
            description: "I'm an async agent example",
            structured_outputs: false
          )

          # Naive concurrency example using concurrent-ruby
          pool = Concurrent::FixedThreadPool.new(2)

          prompts = ["Hello from Prompt 1", "Hello from Prompt 2"]

          prompts.each do |prompt|
            pool.post do
              result = agent.run(prompt)
              puts "Prompt: #{prompt}"
              puts "Agent response: #{result.content}"
            end
          end

          pool.shutdown
          pool.wait_for_termination
        end
      end
    end
  end
end

# You can run: ruby cookbook/agent_concepts/async/basic.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::AgentConcepts::Async::Basic.run_example
end
