# Getting Started with Rubigent

This directory contains simple examples to help you get started with the Rubigent framework.

## Examples

1. **Basic Agent** (`01_basic_agent.rb`)

   - Creates a simple agent that can respond to prompts
   - Demonstrates the basic Agent and OpenAIChat model classes

2. **Agent with Tools** (`02_agent_with_tools.rb`)

   - Shows how to create and use tools with an agent
   - Demonstrates the DuckDuckGoTool for web searches

3. **Structured Output** (`03_structured_output.rb`)
   - Demonstrates how to get structured data from an agent
   - Uses the MovieScript response model to parse JSON responses

## Running the Examples

You can run each example directly:

```bash
ruby cookbook/getting_started/01_basic_agent.rb
```

Or use the cookbook runner:

```bash
ruby cookbook/scripts/cookbook_runner.rb --example basic_agent
```

## Environment Variables

Make sure to set the following environment variables:

```bash
export OPENAI_API_KEY=your_api_key_here
```
