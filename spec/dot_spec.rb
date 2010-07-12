require File.dirname(__FILE__) + '/spec_helper'
require 'statemachine/generate/dot_builder'

describe Statemachine::Statemachine, "(Turn Stile)" do
  include TurnstileStatemachine

  before(:each) do
    create_turnstile
  end

  it "should generate a basic graph declaration" do
    dot = @sm.to_dot

    puts dot

    dot.should_not equal(nil)
    dot.include?("digraph").should == true
  end
end
