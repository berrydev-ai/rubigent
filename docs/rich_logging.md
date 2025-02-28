# Rich Logging in Rubigent

Rubigent provides rich logging capabilities that enhance the display of agent responses in the console. This feature is inspired by the agno library and provides a more visually appealing and informative output.

## Features

- **Boxed Output**: Agent responses are displayed in a box with a border and title
- **Streaming Support**: When streaming is enabled, the output is updated in real-time within the box
- **Color Support**: Different parts of the output can be colored for better readability
- **Customizable**: Box width, colors, and titles can be customized

## Usage

### Basic Usage

```ruby
# Create a rich agent with streaming enabled
agent = Rubigent::RichAgent.new(
  model: Rubigent::Models::OpenAIChat.new(engine: "gpt-3.5-turbo"),
  description: "You are a helpful assistant.",
  stream: true
)

# Run the agent with a prompt
prompt = "What are the benefits of using Ruby for AI development?"
agent.print_response(prompt)
```

### Disabling Streaming

You can disable streaming for a specific call:

```ruby
agent.print_response(prompt, stream: false)
```

### Using the Console Utility Directly

You can also use the Console utility directly for custom rich output:

```ruby
# Print a message in a box
Rubigent::Console.print_box("Hello, world!", title: "Greeting", color: :green)

# Create a streaming box
updater = Rubigent::Console.stream_box(title: "Progress", color: :blue)

# Update the box content
updater.call("25% complete")
updater.call("50% complete")
updater.call("75% complete")
updater.call("100% complete", finished: true)
```

## Examples

Check out the following examples to see rich logging in action:

- `cookbook/getting_started/04_rich_agent.rb`: Basic example of using RichAgent
- `cookbook/examples/rich_logging.rb`: More advanced example with longer responses

You can run these examples using the cookbook runner:

```bash
ruby cookbook/scripts/cookbook_runner.rb --example rich_agent
ruby cookbook/scripts/cookbook_runner.rb --example rich_logging
```

## Implementation Details

The rich logging functionality is implemented through the following components:

1. **Console Class**: Provides utilities for creating and updating rich text boxes
2. **RichAgent Class**: Extends the base Agent class with rich logging capabilities
3. **OpenAI Chat Model**: Updated to support streaming responses

The implementation uses ANSI escape codes for terminal colors and box drawing characters for borders, making it compatible with most modern terminals.
