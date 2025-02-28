# frozen_string_literal: true

require "rubigent"

module Cookbook
  module GettingStarted
    class AgentWithTools
      def self.run_example
        # Create a DuckDuckGo tool
        duckduckgo_tool = Rubigent::Tools::DuckDuckGoTool.new

        # Create an agent with tools
        agent = Rubigent::Agent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
          description: "You are a helpful assistant with access to tools. If you need to search for information, say 'Tool: duck_duck_go' followed by the search query.",
          tools: [duckduckgo_tool],
          show_tool_calls: true
        )

        # Run the agent with a prompt
        puts "Running agent with tools example..."
        puts "=" * 50

        prompt = "Who created the Ruby programming language and when?"
        puts "PROMPT: #{prompt}"
        puts "-" * 50

        # First response might indicate a tool call
        response = agent.run(prompt)
        puts "INITIAL RESPONSE:"
        puts response.content
        puts "-" * 50

        # Check if the response contains a tool call
        if response.content.include?("Tool: duck_duck_go")
          puts "Detected tool call, executing search..."

          # Extract the search query (this is a simplified approach)
          search_query = "Ruby programming language creator"

          # Execute the tool
          tool_result = duckduckgo_tool.run(search_query)
          puts "SEARCH RESULT:"
          puts tool_result
          puts "-" * 50

          # Feed the tool result back to the agent
          follow_up_prompt = "#{prompt}\n\nSearch result: #{tool_result}"
          final_response = agent.run(follow_up_prompt)

          puts "FINAL RESPONSE:"
          puts final_response.content
        end
      end
    end
  end
end

# You can run: ruby cookbook/getting_started/02_agent_with_tools.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::GettingStarted::AgentWithTools.run_example
end
