# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Rubigent
  module Models
    class OpenAIChat
      attr_reader :engine

      # engine could be "gpt-3.5-turbo", "gpt-4", etc.
      def initialize(engine: "gpt-3.5-turbo")
        @engine = engine
      end

      def generate(prompt, stream: false, &block)
        if stream && block_given?
          generate_stream(prompt, &block)
        else
          generate_sync(prompt)
        end
      end

      private

      def generate_sync(prompt)
        uri = URI("https://api.openai.com/v1/chat/completions")
        body = {
          model: @engine,
          messages: [
            {role: "system", content: "You are a helpful assistant."},
            {role: "user", content: prompt}
          ]
        }
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV["OPENAI_API_KEY"]}"
        }

        http_response = Net::HTTP.post(uri, body.to_json, headers)
        parsed = JSON.parse(http_response.body)

        if parsed["choices"] && parsed["choices"][0]
          parsed["choices"][0]["message"]["content"]
        else
          # handle error or fallback
          "Sorry, I couldn't generate a response."
        end
      end

      def generate_stream(prompt)
        uri = URI("https://api.openai.com/v1/chat/completions")

        # Setup HTTP connection
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        # Create request
        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{ENV["OPENAI_API_KEY"]}"

        # Set up streaming request
        request.body = {
          model: @engine,
          messages: [
            {role: "system", content: "You are a helpful assistant."},
            {role: "user", content: prompt}
          ],
          stream: true
        }.to_json

        # Send request and process streaming response
        full_response = ""

        http.request(request) do |response|
          response.read_body do |chunk|
            # Each chunk may contain multiple SSE events
            chunk.split("\n\n").each do |event|
              next if event.strip.empty? || event.start_with?("data: [DONE]")

              if event.start_with?("data: ")
                json_str = event.sub(/^data: /, "").strip
                begin
                  parsed = JSON.parse(json_str)
                  if parsed["choices"] && parsed["choices"][0] && parsed["choices"][0]["delta"] && parsed["choices"][0]["delta"]["content"]
                    content = parsed["choices"][0]["delta"]["content"]
                    full_response += content
                    yield content if block_given?
                  end
                rescue JSON::ParserError
                  # Skip invalid JSON
                end
              end
            end
          end
        end

        full_response
      end
    end
  end
end
