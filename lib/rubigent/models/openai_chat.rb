# frozen_string_literal: true

require "net/http"
require "json"

module Rubigent
  module Models
    class OpenAIChat
      attr_reader :engine

      # engine could be "gpt-3.5-turbo", "gpt-4", etc.
      def initialize(engine: "gpt-3.5-turbo")
        @engine = engine
      end

      def generate(prompt)
        uri = URI("https://api.openai.com/v1/chat/completions")
        body = {
          model: @engine,
          messages: [
            { role: "system", content: "You are a helpful assistant." },
            { role: "user", content: prompt }
          ]
        }
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}"
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
    end
  end
end
