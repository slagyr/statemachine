require File.dirname(__FILE__) + '/../spec_helper'

class SampleContext
  include Statemachine::ContextSupport
end

class SampleStatemachine
  attr_accessor :context
end

class SampleController
  
  include Statemachine::ControllerSupport
  supported_by_statemachine SampleContext, lambda { SampleStatemachine.new }
  
  attr_accessor :session, :initialized, :before_event, :after_event, :params
  
  def initialize(statemachine, context)
    @statemachine = statemachine
    @context = context
    @session = {}
  end  
  
  def initialize_context(*args)
    @initialized = true
  end
  
  def before_event
    @before_event = true
  end
  
  def after_event
    @after_event = true
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
    @context.should_receive(:statemachine)
    
    @controller.send(:recall_state)
  end
  
  specify "new context" do
    @controller = SampleController.new(nil, nil)
    @controller.send(:new_context)
    
    @controller.context.should_not_be nil
    @controller.statemachine.should_not_be nil
    @controller.context.statemachine.should_be @controller.statemachine
    @controller.statemachine.context.should_be @controller.context
    @controller.initialized.should_be true
  end

  specify "event action" do
    @controller.params = {:event => "boo"}
    @controller.session[:samplecontroller_state] = @context
    @context.should_receive(:statemachine).and_return(@statemachine)
    @statemachine.should_receive(:process_event).with("boo", nil)
    
    @controller.event
    
    @controller.before_event.should_be true
    @controller.after_event.should_be true
  end
  
end
