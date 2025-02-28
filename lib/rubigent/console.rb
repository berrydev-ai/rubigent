# frozen_string_literal: true

require "io/console"
require "stringio"

module Rubigent
  # Console utility class for rich output
  class Console
    COLORS = {
      reset: "\e[0m",
      bold: "\e[1m",
      dim: "\e[2m",
      italic: "\e[3m",
      underline: "\e[4m",
      blink: "\e[5m",
      reverse: "\e[7m",
      hidden: "\e[8m",

      black: "\e[30m",
      red: "\e[31m",
      green: "\e[32m",
      yellow: "\e[33m",
      blue: "\e[34m",
      magenta: "\e[35m",
      cyan: "\e[36m",
      white: "\e[37m",

      bg_black: "\e[40m",
      bg_red: "\e[41m",
      bg_green: "\e[42m",
      bg_yellow: "\e[43m",
      bg_blue: "\e[44m",
      bg_magenta: "\e[45m",
      bg_cyan: "\e[46m",
      bg_white: "\e[47m"
    }.freeze

    BOX_CHARS = {
      top_left: "┏",
      top_right: "┓",
      bottom_left: "┗",
      bottom_right: "┛",
      horizontal: "━",
      vertical: "┃",
      title_left: "┣",
      title_right: "┫"
    }.freeze

    class << self
      def terminal_width
        IO.console.winsize[1] rescue 80
      end

      def colorize(text, color)
        return text unless color && COLORS[color]
        "#{COLORS[color]}#{text}#{COLORS[:reset]}"
      end

      def create_box(content, title: nil, color: :blue, width: nil)
        width ||= [terminal_width - 4, 40].max
        content_width = width - 4

        # Process content to fit within box
        processed_content = process_content(content, content_width)

        # Create box
        box = []

        # Top border with title if provided
        if title
          title = " #{title} "
          title_space = [width - 2 - title.length, 0].max
          left_space = title_space / 2
          right_space = title_space - left_space

          box << colorize("#{BOX_CHARS[:top_left]}#{BOX_CHARS[:horizontal] * left_space}#{title}#{BOX_CHARS[:horizontal] * right_space}#{BOX_CHARS[:top_right]}", color)
        else
          box << colorize("#{BOX_CHARS[:top_left]}#{BOX_CHARS[:horizontal] * (width - 2)}#{BOX_CHARS[:top_right]}", color)
        end

        # Content lines
        processed_content.each do |line|
          padding = " " * (content_width - line.length)
          box << colorize("#{BOX_CHARS[:vertical]} ", color) + line + padding + colorize(" #{BOX_CHARS[:vertical]}", color)
        end

        # Bottom border
        box << colorize("#{BOX_CHARS[:bottom_left]}#{BOX_CHARS[:horizontal] * (width - 2)}#{BOX_CHARS[:bottom_right]}", color)

        box.join("\n")
      end

      def process_content(content, width)
        return [""] if content.nil? || content.empty?

        lines = []
        content.to_s.split("\n").each do |line|
          # If line is shorter than width, add it directly
          if line.length <= width
            lines << line
          else
            # Otherwise, wrap the line
            current_line = ""
            line.split.each do |word|
              if current_line.empty?
                current_line = word
              elsif current_line.length + word.length + 1 <= width
                current_line += " " + word
              else
                lines << current_line
                current_line = word
              end
            end
            lines << current_line unless current_line.empty?
          end
        end

        lines
      end

      def print_box(content, title: nil, color: :blue, width: nil)
        puts create_box(content, title: title, color: color, width: width)
      end

      # Stream content into a box, updating it as new content arrives
      def stream_box(title: nil, color: :blue, width: nil)
        width ||= [terminal_width - 4, 40].max
        content_width = width - 4

        # Create initial empty box
        box_top = if title
          title = " #{title} "
          title_space = [width - 2 - title.length, 0].max
          left_space = title_space / 2
          right_space = title_space - left_space

          colorize("#{BOX_CHARS[:top_left]}#{BOX_CHARS[:horizontal] * left_space}#{title}#{BOX_CHARS[:horizontal] * right_space}#{BOX_CHARS[:top_right]}", color)
        else
          colorize("#{BOX_CHARS[:top_left]}#{BOX_CHARS[:horizontal] * (width - 2)}#{BOX_CHARS[:top_right]}", color)
        end

        box_bottom = colorize("#{BOX_CHARS[:bottom_left]}#{BOX_CHARS[:horizontal] * (width - 2)}#{BOX_CHARS[:bottom_right]}", color)

        puts box_top

        # Create a buffer to hold content
        buffer = StringIO.new

        # Return a proc that can be called to update the box
        proc do |chunk = nil, finished: false|
          if chunk
            buffer.write(chunk)
            buffer.rewind

            # Process buffer content to fit within box
            content_lines = process_content(buffer.read, content_width)
            buffer.seek(0, IO::SEEK_END) # Move back to end for next write

            # Clear previous content (move up and clear lines)
            print "\e[1A" * (content_lines.length + 1) if content_lines.any?

            # Print content lines
            content_lines.each do |line|
              padding = " " * (content_width - line.length)
              puts colorize("#{BOX_CHARS[:vertical]} ", color) + line + padding + colorize(" #{BOX_CHARS[:vertical]}", color)
            end

            # Print bottom border
            puts box_bottom
          end

          if finished
            # Final rendering
            buffer.rewind
            content_lines = process_content(buffer.read, content_width)

            # Clear previous content
            print "\e[1A" * (content_lines.length + 1) if content_lines.any?

            # Print content lines
            content_lines.each do |line|
              padding = " " * (content_width - line.length)
              puts colorize("#{BOX_CHARS[:vertical]} ", color) + line + padding + colorize(" #{BOX_CHARS[:vertical]}", color)
            end

            # Print bottom border
            puts box_bottom
          end
        end
      end
    end
  end
end
