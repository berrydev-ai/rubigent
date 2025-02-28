# frozen_string_literal: true

require "rubigent"

module Cookbook
  module AgentConcepts
    class ToolUse
      def self.run_example
        duckduckgo_tool = Rubigent::Tools::DuckDuckGoTool.new

        agent_with_tools = Rubigent::Agent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
          description: "You can answer user questions. If you need additional info, say 'Tool: duck_duck_go'.",
          tools: [duckduckgo_tool],
          show_tool_calls: true,
          markdown: true
        )

        prompt = "What's happening in the UK and in the USA?"

        # In a real implementation, we would parse the model's response for tool calls
        # and execute them. This is a simplified example.
        response = agent_with_tools.run(prompt)
        puts "Agent response: #{response.content}"

        # Check if the response contains a tool call
        if response.content.include?("Tool: duck_duck_go")
          puts "\nDetected tool call, executing DuckDuckGo search..."

          # Extract the search query (this is a simplified approach)
          search_query = "UK USA news"

          # Execute the tool
          tool_result = duckduckgo_tool.run(search_query)

          # Feed the tool result back to the agent
          follow_up_prompt = "#{prompt}\n\nSearch result: #{tool_result}"
          final_response = agent_with_tools.run(follow_up_prompt)

          puts "\nFinal response with tool results:"
          puts final_response.content
        end
      end
    end
  end
end

# You can run: ruby cookbook/agent_concepts/tool_use.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::AgentConcepts::ToolUse.run_example
end
