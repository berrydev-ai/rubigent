# frozen_string_literal: true

require "json"
require "time"
require_relative "run_event"

module Rubigent
  # Extra data that can be included in a RunResponse
  class RunResponseExtraData
    attr_accessor :references, :add_messages, :history, :reasoning_steps, :reasoning_messages

    def initialize(
      references: nil,
      add_messages: nil,
      history: nil,
      reasoning_steps: nil,
      reasoning_messages: nil
    )
      @references = references
      @add_messages = add_messages
      @history = history
      @reasoning_steps = reasoning_steps
      @reasoning_messages = reasoning_messages
    end

    def to_dict
      dict = {}
      dict["add_messages"] = @add_messages.map(&:to_dict) if @add_messages
      dict["history"] = @history.map(&:to_dict) if @history
      dict["reasoning_messages"] = @reasoning_messages.map(&:to_dict) if @reasoning_messages
      dict["reasoning_steps"] = @reasoning_steps.map(&:to_dict) if @reasoning_steps
      dict["references"] = @references.map(&:to_dict) if @references
      dict
    end
  end

  # Response returned by Agent.run() or Workflow.run() functions
  class RunResponse
    attr_accessor :content,
      :content_type,
      :thinking,
      :event,
      :messages,
      :metrics,
      :model,
      :run_id,
      :agent_id,
      :session_id,
      :workflow_id,
      :tools,
      :images,
      :videos,
      :audio,
      :response_audio,
      :extra_data,
      :created_at

    def initialize(
      content: nil,
      content_type: "str",
      thinking: nil,
      event: RunEvent::RUN_RESPONSE,
      messages: nil,
      metrics: nil,
      model: nil,
      run_id: nil,
      agent_id: nil,
      session_id: nil,
      workflow_id: nil,
      tools: nil,
      images: nil,
      videos: nil,
      audio: nil,
      response_audio: nil,
      extra_data: nil,
      created_at: Time.now.to_i
    )
      @content = content
      @content_type = content_type
      @thinking = thinking
      @event = event
      @messages = messages
      @metrics = metrics
      @model = model
      @run_id = run_id
      @agent_id = agent_id
      @session_id = session_id
      @workflow_id = workflow_id
      @tools = tools
      @images = images
      @videos = videos
      @audio = audio
      @response_audio = response_audio
      @extra_data = extra_data
      @created_at = created_at
    end

    def to_dict
      dict = {}

      # Add all non-nil attributes except special cases
      instance_variables.each do |var|
        key = var.to_s.delete("@")
        value = instance_variable_get(var)

        next if value.nil?
        next if ["messages", "extra_data", "images", "videos", "audio", "response_audio"].include?(key)

        dict[key] = value
      end

      # Handle special cases
      dict["messages"] = @messages.map(&:to_dict) if @messages
      dict["extra_data"] = @extra_data.to_dict if @extra_data
      dict["images"] = @images.map(&:to_dict) if @images
      dict["videos"] = @videos.map(&:to_dict) if @videos
      dict["audio"] = @audio.map(&:to_dict) if @audio
      dict["response_audio"] = @response_audio.to_dict if @response_audio

      # Handle content if it's a special object
      if @content.respond_to?(:to_dict)
        dict["content"] = @content.to_dict
      end

      dict
    end

    def to_json
      JSON.pretty_generate(to_dict)
    end

    def get_content_as_string(**kwargs)
      if @content.is_a?(String)
        @content
      elsif @content.respond_to?(:to_json)
        @content.to_json(**kwargs)
      else
        JSON.generate(@content, **kwargs)
      end
    end
  end
end
