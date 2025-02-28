# frozen_string_literal: true

require "json"

module Rubigent
  # Simple container for run-time output
  class RunResponse
    attr_accessor :content

    def initialize(content)
      @content = content
    end
  end

  class Agent
    attr_accessor :model,
                  :description,
                  :response_model,
                  :structured_outputs,
                  :tools,
                  :show_tool_calls,
                  :markdown

    def initialize(
      model:,
      description: "",
      response_model: nil,
      structured_outputs: false,
      tools: [],
      show_tool_calls: false,
      markdown: false
    )
      @model = model
      @description = description
      @response_model = response_model
      @structured_outputs = structured_outputs
      @tools = tools
      @show_tool_calls = show_tool_calls
      @markdown = markdown
    end

    ##
    # Synchronously run agent logic with a prompt
    #
    def run(user_prompt)
      # Build full prompt using the agent's description or system prompt
      prompt = build_prompt(user_prompt)

      # 1. Generate a completion from the model
      raw_response = @model.generate(prompt)

      # 2. Possibly parse or transform that response
      parsed_response = parse_response(raw_response)

      # 3. Return a RunResponse (or the parsed object) so you can further manipulate or display
      RunResponse.new(parsed_response)
    end

    ##
    # Print the response directly to the console
    #
    def print_response(user_prompt)
      response = run(user_prompt)
      puts response.content
    end

    private

    ##
    # Basic prompt builder to incorporate system or description text
    #
    def build_prompt(user_prompt)
      # You can enhance this to incorporate a "system" role message or
      # other instructions. For simplicity:
      # - Provide the agent's description as a system-style message
      # - Provide user prompt next
      <<~PROMPT
      System: #{@description}

      User: #{user_prompt}
      PROMPT
    end

    ##
    # If structured_outputs is true, we'll attempt to parse JSON
    # and map to your response_model (if provided). Otherwise, return raw text.
    #
    def parse_response(response_text)
      return response_text unless @structured_outputs

      begin
        data = JSON.parse(response_text)
      rescue JSON::ParserError
        # In real usage, you'd handle this gracefully.
        return response_text
      end

      if @response_model
        # Convert parsed JSON to a domain object
        @response_model.new(**symbolize_keys(data))
      else
        data
      end
    end

    def symbolize_keys(hash)
      hash.transform_keys(&:to_sym)
    end
  end
end
