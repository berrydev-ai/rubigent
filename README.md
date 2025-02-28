# Rubigent

Rubigent is a lightweight Ruby library for building agentic AI systems. It provides a simple framework for creating and managing AI agents with multi-modal capabilities.

## Features

- Create agents that can use LLM models
- Run agents with user prompts
- Capture and process agent responses
- Enable agents to utilize tools (if model permits)
- Support for structured outputs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubigent'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rubigent
```

## Usage

### Basic Agent

```ruby
require "rubigent"

# Create a simple agent
agent = Rubigent::Agent.new(
  model: Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo"),
  description: "You are a helpful assistant."
)

# Run the agent with a prompt
response = agent.run("Hello, how are you?")
puts response.content
```

### Structured Output

```ruby
require "rubigent"

# Define a response model
class MovieScript
  attr_accessor :setting, :ending, :genre, :name, :characters, :storyline

  def initialize(setting:, ending:, genre:, name:, characters:, storyline:)
    @setting = setting
    @ending = ending
    @genre = genre
    @name = name
    @characters = characters
    @storyline = storyline
  end
end

# Create an agent with structured output
agent = Rubigent::Agent.new(
  model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
  description: "You write movie scripts. Provide output as JSON.",
  response_model: MovieScript,
  structured_outputs: true
)

# Run the agent
response = agent.run("New York")
movie_script = response.content

puts "Setting: #{movie_script.setting}"
puts "Characters: #{movie_script.characters.join(', ')}"
```

### Using Tools

```ruby
require "rubigent"

# Create a tool
duckduckgo_tool = Rubigent::Tools::DuckDuckGoTool.new

# Create an agent with tools
agent = Rubigent::Agent.new(
  model: Rubigent::Models::OpenAIChat.new(engine: "gpt-4"),
  description: "You can use tools to find information.",
  tools: [duckduckgo_tool]
)

# Run the agent
response = agent.run("What's the capital of France?")
puts response.content
```

## Cookbook

The Rubigent gem includes a cookbook with example recipes for using the framework. To explore the cookbook:

```bash
# List available examples
ruby cookbook/scripts/cookbook_runner.rb --list

# Run a specific example
ruby cookbook/scripts/cookbook_runner.rb --example movie_recommendation
```

Available examples include:

- `async_basic` - Demonstrates asynchronous agent usage
- `structured_output` - Shows how to use structured outputs
- `tool_use` - Illustrates tool integration
- `movie_recommendation` - A complete movie recommendation agent

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubigent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rubigent/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubigent project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rubigent/blob/main/CODE_OF_CONDUCT.md).
