# frozen_string_literal: true

require "optparse"

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

# Require all cookbook examples
require_relative "../agent_concepts/async/basic"
require_relative "../agent_concepts/structured_output"
require_relative "../agent_concepts/tool_use"
require_relative "../examples/agents/movie_recommendation"
require_relative "../getting_started/01_basic_agent"
require_relative "../getting_started/02_agent_with_tools"
require_relative "../getting_started/03_structured_output"

module Cookbook
  module Scripts
    class CookbookRunner
      EXAMPLES = {
        # Agent concepts
        "async_basic" => Cookbook::AgentConcepts::Async::Basic,
        "structured_output" => Cookbook::AgentConcepts::StructuredOutput,
        "tool_use" => Cookbook::AgentConcepts::ToolUse,

        # Example agents
        "movie_recommendation" => Cookbook::Examples::Agents::MovieRecommendation,

        # Getting started
        "basic_agent" => Cookbook::GettingStarted::BasicAgent,
        "agent_with_tools" => Cookbook::GettingStarted::AgentWithTools,
        "structured_output_example" => Cookbook::GettingStarted::StructuredOutput
      }.freeze

      def self.run
        options = {}
        OptionParser.new do |parser|
          parser.banner = "Usage: cookbook_runner.rb [options]"
          parser.on("-e", "--example EXAMPLE", "Which example to run") do |e|
            options[:example] = e
          end
          parser.on("-l", "--list", "List available examples") do
            options[:list] = true
          end
          parser.on("-h", "--help", "Show this help message") do
            puts parser
            exit
          end
        end.parse!

        if options[:list]
          list_examples
          return
        end

        if options[:example]
          run_example(options[:example])
        else
          puts "No example specified. Use --example EXAMPLE or --list to see available examples."
        end
      end

      def self.list_examples
        puts "Available examples:"
        EXAMPLES.keys.sort.each do |key|
          puts "  #{key}"
        end
      end

      def self.run_example(example_name)
        if EXAMPLES.key?(example_name)
          puts "Running example: #{example_name}"
          EXAMPLES[example_name].run_example
        else
          puts "Unknown example: #{example_name}"
          list_examples
        end
      end
    end
  end
end

# You can run: ruby cookbook/scripts/cookbook_runner.rb --example async_basic
if $PROGRAM_NAME == __FILE__
  Cookbook::Scripts::CookbookRunner.run
end
