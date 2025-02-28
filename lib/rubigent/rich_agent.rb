# frozen_string_literal: true

require_relative "agent"
require_relative "console"

module Rubigent
  # RichAgent extends Agent with rich logging capabilities
  class RichAgent < Agent
    attr_accessor :stream

    def initialize(
      model:,
      description: "",
      response_model: nil,
      structured_outputs: false,
      tools: [],
      show_tool_calls: false,
      markdown: false,
      stream: false
    )
      super(
        model: model,
        description: description,
        response_model: response_model,
        structured_outputs: structured_outputs,
        tools: tools,
        show_tool_calls: show_tool_calls,
        markdown: markdown
      )
      @stream = stream
    end

    ##
    # Run the agent with streaming support
    #
    def run(user_prompt, stream: nil)
      # Use instance stream setting if not specified
      stream_mode = stream.nil? ? @stream : stream

      # Build full prompt using the agent's description or system prompt
      prompt = build_prompt(user_prompt)

      # Generate a completion from the model
      if stream_mode
        # For streaming, we need to collect the full response
        full_response = ""
        thinking = ""

        # Create a proc to handle streaming updates
        @model.generate(prompt, stream: true) do |chunk|
          full_response += chunk
          yield chunk if block_given?
        end

        # Parse the full response
        parsed_response = parse_response(full_response)

        # Return a RunResponse with the parsed content
        RunResponse.new(parsed_response)
      else
        # For non-streaming, just use the parent class implementation
        super(user_prompt)
      end
    end

    ##
    # Print the response directly to the console with rich formatting
    #
    def print_response(user_prompt, stream: nil)
      # Use instance stream setting if not specified
      stream_mode = stream.nil? ? @stream : stream

      # Print the user prompt in a box
      Console.print_box(user_prompt, title: "User Prompt", color: :cyan)

      if stream_mode
        # Create a streaming box for the response
        puts "\nGenerating response..."
        updater = Console.stream_box(title: "Response", color: :blue)

        # Run the agent with streaming
        response = run(user_prompt, stream: true) do |chunk|
          updater.call(chunk)
        end

        # Finalize the box
        updater.call(finished: true)
      else
        # Run the agent without streaming
        puts "\nGenerating response..."
        response = run(user_prompt, stream: false)

        # Print the response in a box
        Console.print_box(response.content, title: "Response", color: :blue)
      end

      response
    end
  end
end
