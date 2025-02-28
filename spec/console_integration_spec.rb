# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Console Integration", :integration do
  let(:console) { Rubigent::Console }

  it "demonstrates all console features" do
    puts "\n\n=== Console Integration Demo ==="

    puts "\n== Text Formatting =="
    puts console.colorize("This text is blue", :blue)
    puts console.format("{{bold:Bold text}} with {{green:colors}}")

    puts "\n== Status Messages =="
    console.success("Operation completed successfully")
    console.error("Something went wrong")
    console.info("Just some information")
    console.warning("This is a warning")

    puts "\n== Boxes =="
    puts console.create_box("Content in a box", title: "Box Example", color: :cyan)

    puts "\n== Tables =="
    data = [
      ["Name", "Role", "Age"],
      ["Alice", "Developer", "28"],
      ["Bob", "Designer", "34"]
    ]
    console.table(data)

    puts "\n=== End Demo ==="
  end
end
