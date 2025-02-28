#!/usr/bin/env ruby
# frozen_string_literal: true

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

# Manually load environment variables from .env file
env_file = File.expand_path("../../.env", __dir__)
if File.exist?(env_file)
  File.foreach(env_file) do |line|
    next if line.strip.empty? || line.strip.start_with?("#")
    key, value = line.strip.split("=", 2)
    ENV[key] = value if key && value
  end
end

require "rubigent"

# This example demonstrates the use of the RunResponse, RunResponseExtraData, and RunEvent classes
# to track and report on the execution of an agent.

# Define a class for reasoning steps
class ReasoningStep
  attr_accessor :step, :thought

  def initialize(step:, thought:)
    @step = step
    @thought = thought
  end

  def to_dict
    { step: @step, thought: @thought }
  end
end

# Create a simple OpenAI chat model
model = Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo")

# Create an agent with the model
agent = Rubigent::Agent.new(
  model: model,
  description: "You are a helpful assistant that provides concise answers."
)

# Create a custom run method that tracks events
def run_with_events(agent, prompt)
  # Create a start event
  start_response = Rubigent::RunResponse.new(
    event: Rubigent::RunEvent::RUN_STARTED,
    content: "Starting agent run",
    model: agent.model.engine,
    run_id: "run-#{Time.now.to_i}",
    metrics: { start_time: Time.now.to_i }
  )

  puts "Event: #{start_response.event}"
  puts "Content: #{start_response.content}"
  puts "Model: #{start_response.model}"
  puts "Run ID: #{start_response.run_id}"
  puts "Metrics: #{start_response.metrics.inspect}"
  puts "---"

  # Run the agent
  begin
    # Track reasoning steps
    reasoning_steps = []
    reasoning_steps << ReasoningStep.new(step: 1, thought: "Analyzing the user prompt")
    reasoning_steps << ReasoningStep.new(step: 2, thought: "Generating a response")

    # Run the agent
    response = agent.run(prompt)

    # Add additional information to the response
    response.event = Rubigent::RunEvent::RUN_COMPLETED
    response.run_id = start_response.run_id
    response.model = agent.model.engine
    response.metrics = {
      start_time: start_response.metrics[:start_time],
      end_time: Time.now.to_i,
      duration: Time.now.to_i - start_response.metrics[:start_time]
    }

    # Add extra data
    response.extra_data = Rubigent::RunResponseExtraData.new(
      reasoning_steps: reasoning_steps
    )

    puts "Event: #{response.event}"
    puts "Content: #{response.content}"
    puts "Model: #{response.model}"
    puts "Run ID: #{response.run_id}"
    puts "Metrics: #{response.metrics.inspect}"
    puts "Extra Data: #{response.extra_data.to_dict.inspect}"
    puts "---"

    # Return the response
    response
  rescue => e
    # Create an error event
    error_response = Rubigent::RunResponse.new(
      event: Rubigent::RunEvent::RUN_ERROR,
      content: "Error: #{e.message}",
      run_id: start_response.run_id,
      metrics: {
        start_time: start_response.metrics[:start_time],
        end_time: Time.now.to_i,
        duration: Time.now.to_i - start_response.metrics[:start_time],
        error: e.message
      }
    )

    puts "Event: #{error_response.event}"
    puts "Content: #{error_response.content}"
    puts "Run ID: #{error_response.run_id}"
    puts "Metrics: #{error_response.metrics.inspect}"
    puts "---"

    # Return the error response
    error_response
  end
end

# Run the agent with event tracking
puts "Running agent with event tracking..."
puts

response = run_with_events(agent, "What is the capital of France?")

puts "Final response content:"
puts response.content
puts

puts "Response as JSON:"
puts response.to_json
