# frozen_string_literal: true

require 'cli/ui'

CLI::UI::StdoutRouter.enable

module Rubigent
  # Console utility class for rich output
  class Console
    # Color mapping from legacy colors to CLI::UI colors
    COLOR_MAP = {
      black: :black,
      red: :red,
      green: :green,
      yellow: :yellow,
      blue: :blue,
      magenta: :magenta,
      cyan: :cyan,
      white: :white,
      # Add mappings for other colors as needed
    }.freeze

    class << self
      def terminal_width
        CLI::UI::Terminal.width
      end

      def colorize(text, color)
        return text unless color
        color_sym = COLOR_MAP[color.to_sym] || color.to_sym
        CLI::UI.fmt("{{#{color_sym}:#{text}}}")
      end

      def create_box(content, title: nil, color: :blue, width: nil)
        capture_output do
          print_box(content, title: title, color: color, width: width)
        end
      end

      def print_box(content, title: nil, color: :blue, width: nil)
        color_sym = COLOR_MAP[color.to_sym] || color.to_sym

        CLI::UI::Frame.open(title || "", color: color_sym, width: width) do
          puts content.to_s
        end
      end

      def process_content(content, width)
        content.to_s.split("\n").map do |line|
          CLI::UI::Wrap.wrap_paragraph(line, max_width: width)
        end.flatten
      end

      def stream_box(title: nil, color: :blue, width: nil)
        color_sym = COLOR_MAP[color.to_sym] || color.to_sym
        frame_open = false
        buffer = StringIO.new

        proc do |chunk = nil, finished: false|
          if chunk
            buffer.write(chunk)
          end

          if !frame_open
            CLI::UI::Frame.open(title || "", color: color_sym, width: width)
            frame_open = true
          end

          if finished
            puts buffer.string
            CLI::UI::Frame.close(title || "")
          end
        end
      end

      # Add new CLI::UI convenience methods

      def prompt(question, options)
        CLI::UI::Prompt.ask(question, options: options)
      end

      def confirm(question)
        CLI::UI::Prompt.confirm(question)
      end

      def spinner(title, &block)
        CLI::UI::Spinner.spin(title, &block)
      end

      def spin_group
        CLI::UI::SpinGroup.new
      end

      def success(message)
        puts CLI::UI.fmt("{{v}} {{green:#{message}}}")
      end

      def error(message)
        puts CLI::UI.fmt("{{x}} {{red:#{message}}}")
      end

      def info(message)
        puts CLI::UI.fmt("{{i}} #{message}")
      end

      def warning(message)
        puts CLI::UI.fmt("{{!}} {{yellow:#{message}}}")
      end

      def format(text)
        CLI::UI.fmt(text)
      end

      def table(rows, header_row: nil)
        CLI::UI::Table.new(
          rows: rows,
          header: header_row
        ).render
      end

      private

      def capture_output
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        yield
        $stdout = original_stdout
        output.string
      end
    end
  end
end
