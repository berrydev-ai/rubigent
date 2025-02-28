# frozen_string_literal: true

RSpec.describe Rubigent do
  it "has a version number" do
    expect(Rubigent::VERSION).not_to be nil
  end
end

RSpec.describe Rubigent::Agent do
  let(:model) { instance_double(Rubigent::Models::OpenAIChat) }
  let(:description) { "Test agent description" }
  let(:agent) { Rubigent::Agent.new(model: model, description: description) }
  let(:prompt) { "Hello, world!" }
  let(:model_response) { "Hello from the model!" }

  before do
    allow(model).to receive(:generate).with(anything).and_return(model_response)
  end

  describe "#run" do
    it "returns a RunResponse object" do
      response = agent.run(prompt)
      expect(response).to be_a(Rubigent::RunResponse)
    end

    it "calls the model's generate method" do
      agent.run(prompt)
      expect(model).to have_received(:generate)
    end

    it "includes the description in the prompt" do
      agent.run(prompt)
      expect(model).to have_received(:generate).with(a_string_including(description))
      expect(model).to have_received(:generate).with(a_string_including(prompt))
    end

    it "returns the model's response" do
      response = agent.run(prompt)
      expect(response.content).to eq(model_response)
    end
  end

  context "with structured outputs" do
    let(:agent) {
      Rubigent::Agent.new(
        model: model,
        description: description,
        structured_outputs: true,
        response_model: Rubigent::Examples::MovieScript
      )
    }
    let(:json_response) {
      '{"setting":"New York","ending":"Happy","genre":"Action","name":"City Lights","characters":["John","Mary"],"storyline":"An exciting story."}'
    }

    before do
      allow(model).to receive(:generate).with(anything).and_return(json_response)
    end

    it "parses JSON responses" do
      response = agent.run(prompt)
      expect(response.content).to be_a(Rubigent::Examples::MovieScript)
      expect(response.content.setting).to eq("New York")
      expect(response.content.characters).to eq(["John", "Mary"])
    end
  end
end

RSpec.describe Rubigent::Tool do
  it "requires subclasses to implement #run" do
    tool = Rubigent::Tool.new(name: "test_tool", description: "A test tool")
    expect { tool.run("test input") }.to raise_error(NotImplementedError)
  end
end

RSpec.describe Rubigent::Tools::DuckDuckGoTool do
  let(:tool) { Rubigent::Tools::DuckDuckGoTool.new }
  let(:query) { "Ruby programming" }
  let(:mock_response) { '{"AbstractText": "Ruby is a programming language"}' }

  before do
    # Mock the HTTP request
    allow(Net::HTTP).to receive(:get).and_return(mock_response)
  end

  it "inherits from Tool" do
    expect(tool).to be_a(Rubigent::Tool)
  end

  it "has the correct name and description" do
    expect(tool.name).to eq("duck_duck_go")
    expect(tool.description).to include("Search")
  end

  it "makes a request to DuckDuckGo API" do
    tool.run(query)
    expect(Net::HTTP).to have_received(:get)
  end

  it "returns the abstract text from the response" do
    result = tool.run(query)
    expect(result).to eq("Ruby is a programming language")
  end
end

RSpec.describe Rubigent::Models::OpenAIChat do
  let(:engine) { "gpt-3.5-turbo" }
  let(:model) { Rubigent::Models::OpenAIChat.new(engine: engine) }
  let(:prompt) { "Hello, world!" }
  let(:mock_response) {
    {
      "choices" => [
        {
          "message" => {
            "content" => "Hello from OpenAI!"
          }
        }
      ]
    }.to_json
  }

  before do
    # Mock the HTTP request
    allow(Net::HTTP).to receive(:post).and_return(
      instance_double(Net::HTTPResponse, body: mock_response)
    )
  end

  it "has the correct engine" do
    expect(model.engine).to eq(engine)
  end

  it "makes a request to OpenAI API" do
    model.generate(prompt)
    expect(Net::HTTP).to have_received(:post)
  end

  it "returns the content from the response" do
    result = model.generate(prompt)
    expect(result).to eq("Hello from OpenAI!")
  end
end
