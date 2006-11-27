require File.dirname(__FILE__) + '/../spec_helper'

class SampleController
  
  include Statemachine::ControllerSupport
  supported_by_statemachine String
  
  attr_accessor :session
  
  def initialize(statemachine, context)
    @statemachine = statemachine
    @context = context
    @session = {}
  end
  
end

context "State Machine Support" do

  setup do
    @statemachine = mock("statemachine")
    @context = mock("context")
    @controller = SampleController.new(@statemachine, @context)
  end
  
  specify "save state" do
    @controller.send(:save_state)
    
    @controller.session[:samplecontroller_state].should_be @context
  end

  specify "recall state" do
    @controller.session[:samplecontroller_state] = @context
    
    @controller.send(:recall_state)
  end
  
end
