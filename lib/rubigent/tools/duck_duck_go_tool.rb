# frozen_string_literal: true

require "net/http"
require "json"

module Rubigent
  module Tools
    class DuckDuckGoTool < Rubigent::Tool
      def initialize
        super(name: "duck_duck_go", description: "Search using DuckDuckGo")
      end

      def run(query)
        # You can call DuckDuckGo's Instant Answer API or any custom endpoint
        # This is a minimal example.

        url = URI("https://api.duckduckgo.com/?q=#{URI.encode_www_form_component(query)}&format=json")
        resp = Net::HTTP.get(url)
        data = JSON.parse(resp)
        # data["RelatedTopics"] or data["AbstractText"]
        data["AbstractText"] || "No info available."
      end
    end
  end
end
