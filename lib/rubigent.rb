# frozen_string_literal: true

require_relative "rubigent/version"
require_relative "rubigent/agent"
require_relative "rubigent/tool"
require_relative "rubigent/models/openai_chat"
require_relative "rubigent/tools/duck_duck_go_tool"
require_relative "rubigent/examples/movie_script"

module Rubigent
  class Error < StandardError; end
  # Configuration can be added here if needed
end
