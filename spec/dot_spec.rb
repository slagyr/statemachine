require File.dirname(__FILE__) + '/spec_helper'
require 'statemachine/generate/dot_builder'

describe Statemachine::Statemachine, "(Turn Stile)" do
  include TurnstileStatemachine

  before(:each) do
    remove_test_dir("dot")
    @output = test_dir("dot")
    create_turnstile
  end

  it "should output to console when no output dir provided" do
    # Note - this test doesn't verify output to the console, but it does
    # ensure that the to_dot call does not fail if not output is provided.
    @sm.to_dot
  end

  it "should generate a basic graph declaration" do
    @sm.to_dot(:output => @output)

    dot = load_lines(@output, "main.dot")

    dot.should_not equal(nil)
    dot[0].include?("digraph").should == true
  end
end
