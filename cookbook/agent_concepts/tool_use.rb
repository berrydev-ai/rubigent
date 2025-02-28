# frozen_string_literal: true

require "rubigent"

module Cookbook
  module AgentConcepts
    class ToolUse
      def self.run_example
        console = Rubigent::Console

        console.info("Setting up DuckDuckGo tool")
        duckduckgo_tool = Rubigent::Tools::DuckDuckGoTool.new

        # Print a nice box showing the agent configuration
        console.print_box(
          "Model: gpt-4\n" +
          "Tools: DuckDuckGoTool\n" +
          "Show tool calls: true\n" +
          "Markdown: true",
          title: "Agent Configuration",
          color: :blue
        )

        agent_with_tools = Rubigent::Agent.new(
          model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
          description: "You can answer user questions. If you need additional info, say 'Tool: duck_duck_go'.",
          tools: [duckduckgo_tool],
          show_tool_calls: true,
          markdown: true
        )

        prompt = "What's happening in the UK and in the USA?"
        console.info("Sending prompt: #{prompt}")

        # Use a spinner for the agent call
        response = console.spinner("Running initial agent query") do
          agent_with_tools.run(prompt)
        end

        console.print_box(response.content, title: "Agent Response", color: :green)

        # Check if the response contains a tool call
        if response.content.include?("Tool: duck_duck_go")
          console.warning("Detected tool call, executing DuckDuckGo search...")

          # Extract the search query (this is a simplified approach)
          search_query = "UK USA news"

          # Execute the tool with a spinner
          tool_result = console.spinner("Executing DuckDuckGo search") do
            duckduckgo_tool.run(search_query)
          end

          # Feed the tool result back to the agent
          follow_up_prompt = "#{prompt}\n\nSearch result: #{tool_result}"

          final_response = console.spinner("Running final agent query") do
            agent_with_tools.run(follow_up_prompt)
          end

          console.success("Tool execution complete!")
          console.print_box(final_response.content, title: "Final Response with Tool Results", color: :cyan)
        else
          console.info("No tool calls detected in response")
        end
      end
    end
  end
end

# You can run: ruby cookbook/agent_concepts/tool_use.rb
if $PROGRAM_NAME == __FILE__
  Cookbook::AgentConcepts::ToolUse.run_example
end
