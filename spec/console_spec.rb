# frozen_string_literal: true

require "spec_helper"
require "stringio"

RSpec.describe Rubigent::Console do
  let(:console) { described_class }

  # Helper method to capture stdout
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  describe ".terminal_width" do
    it "delegates to CLI::UI::Terminal.width" do
      expect(CLI::UI::Terminal).to receive(:width).and_return(80)
      expect(console.terminal_width).to eq(80)
    end
  end

  describe ".colorize" do
    it "formats text with the specified color" do
      expect(CLI::UI).to receive(:fmt).with("{{red:test}}").and_return("\e[31mtest\e[0m")
      expect(console.colorize("test", :red)).to eq("\e[31mtest\e[0m")
    end

    it "returns unmodified text when no color is specified" do
      expect(console.colorize("test", nil)).to eq("test")
    end

    it "handles color mapping" do
      expect(CLI::UI).to receive(:fmt).with("{{red:test}}").and_return("\e[31mtest\e[0m")
      expect(console.colorize("test", :red)).to eq("\e[31mtest\e[0m")
    end
  end

  describe ".create_box" do
    it "captures output from print_box" do
      expect(console).to receive(:print_box).with("content", title: "title", color: :blue, width: 80)
      console.create_box("content", title: "title", color: :blue, width: 80)
    end

    it "returns the captured output" do
      allow(console).to receive(:print_box)
      expect(console.create_box("test")).to be_a(String)
    end
  end

  describe ".print_box" do
    it "opens a frame with the specified parameters" do
      expect(CLI::UI::Frame).to receive(:open).with("title", color: :blue, width: 80)
      console.print_box("content", title: "title", color: :blue, width: 80)
    end

    it "prints the content inside the frame" do
      output = capture_stdout do
        allow(CLI::UI::Frame).to receive(:open).and_yield
        console.print_box("test content")
      end
      expect(output).to include("test content")
    end
  end

  describe ".process_content" do
    it "wraps text to the specified width" do
      expect(CLI::UI::Wrap).to receive(:wrap_paragraph).with("test", max_width: 10).and_return(["test"])
      expect(console.process_content("test", 10)).to eq(["test"])
    end

    it "splits content by newlines" do
      expect(CLI::UI::Wrap).to receive(:wrap_paragraph).with("line1", max_width: 80).and_return(["line1"])
      expect(CLI::UI::Wrap).to receive(:wrap_paragraph).with("line2", max_width: 80).and_return(["line2"])
      expect(console.process_content("line1\nline2", 80)).to eq(["line1", "line2"])
    end
  end

  describe ".stream_box" do
    it "returns a callable proc" do
      expect(console.stream_box).to be_a(Proc)
    end

    context "when calling the returned proc" do
      let(:streamer) { console.stream_box(title: "title", color: :blue, width: 80) }

      it "opens a frame when called first time" do
        expect(CLI::UI::Frame).to receive(:open).with("title", color: :blue, width: 80)
        streamer.call("chunk")
      end

      it "appends content to buffer" do
        allow(CLI::UI::Frame).to receive(:open)
        allow(CLI::UI::Frame).to receive(:close)

        expect {
          streamer.call("chunk1")
          streamer.call("chunk2")
          streamer.call(finished: true)
        }.not_to raise_error
      end

      it "closes the frame when finished is true" do
        allow(CLI::UI::Frame).to receive(:open)
        expect(CLI::UI::Frame).to receive(:close).with("title")

        streamer.call("chunk")
        streamer.call(finished: true)
      end
    end
  end

  describe ".prompt" do
    it "delegates to CLI::UI::Prompt.ask" do
      options = ["option1", "option2"]
      expect(CLI::UI::Prompt).to receive(:ask).with("question", options: options).and_return("option1")
      expect(console.prompt("question", options)).to eq("option1")
    end
  end

  describe ".confirm" do
    it "delegates to CLI::UI::Prompt.confirm" do
      expect(CLI::UI::Prompt).to receive(:confirm).with("question").and_return(true)
      expect(console.confirm("question")).to be true
    end
  end

  describe ".spinner" do
    it "delegates to CLI::UI::Spinner.spin" do
      block = proc { "result" }
      expect(CLI::UI::Spinner).to receive(:spin).with("title").and_yield
      expect(console.spinner("title", &block)).to eq("result")
    end
  end

  describe ".spin_group" do
    it "returns a new CLI::UI::SpinGroup" do
      group = double("SpinGroup")
      expect(CLI::UI::SpinGroup).to receive(:new).and_return(group)
      expect(console.spin_group).to eq(group)
    end
  end

  describe "status message methods" do
    let(:formatted) { "formatted output" }

    before do
      allow(CLI::UI).to receive(:fmt).and_return(formatted)
    end

    describe ".success" do
      it "formats and prints a success message" do
        expect(CLI::UI).to receive(:fmt).with("{{v}} {{green:message}}")
        output = capture_stdout { console.success("message") }
        expect(output).to include(formatted)
      end
    end

    describe ".error" do
      it "formats and prints an error message" do
        expect(CLI::UI).to receive(:fmt).with("{{x}} {{red:message}}")
        output = capture_stdout { console.error("message") }
        expect(output).to include(formatted)
      end
    end

    describe ".info" do
      it "formats and prints an info message" do
        expect(CLI::UI).to receive(:fmt).with("{{i}} message")
        output = capture_stdout { console.info("message") }
        expect(output).to include(formatted)
      end
    end

    describe ".warning" do
      it "formats and prints a warning message" do
        expect(CLI::UI).to receive(:fmt).with("{{!}} {{yellow:message}}")
        output = capture_stdout { console.warning("message") }
        expect(output).to include(formatted)
      end
    end
  end

  describe ".format" do
    it "delegates to CLI::UI.fmt" do
      expect(CLI::UI).to receive(:fmt).with("{{red:text}}").and_return("\e[31mtext\e[0m")
      expect(console.format("{{red:text}}")).to eq("\e[31mtext\e[0m")
    end
  end

  describe ".table" do
    let(:table_instance) { instance_double(CLI::UI::Table) }
    let(:rows) { [["header1", "header2"], ["val1", "val2"]] }
    let(:header) { ["col1", "col2"] }

    it "creates and renders a table" do
      expect(CLI::UI::Table).to receive(:new).with(rows: rows, header: header).and_return(table_instance)
      expect(table_instance).to receive(:render)

      console.table(rows, header_row: header)
    end
  end
end
