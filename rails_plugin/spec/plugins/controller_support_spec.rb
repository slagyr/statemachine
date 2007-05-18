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
  
  attr_accessor :session, :initialized, :before, :after, :params, :can_continue
  
  def initialize(statemachine, context)
    @statemachine = statemachine
    @context = context
    @session = {}
    @can_continue = true
  end  
  
  def initialize_context(*args)
    @initialized = true
  end
  
  def before_event
    @before = true
    return @can_continue
  end
  
  def after_event
    @after = true
  end
  
end

describe "State Machine Support" do

  before(:each) do
    @statemachine = mock("statemachine")
    @context = mock("context")
    @controller = SampleController.new(@statemachine, @context)
  end
  
  it "save state" do
    @controller.send(:save_state)
    
    @controller.session[:samplecontroller_state].should equal @context
  end

  it "recall state" do
    @controller.session[:samplecontroller_state] = @context
    @context.should_receive(:statemachine)
    
    @controller.send(:recall_state)
  end
  
  it "new context" do
    @controller = SampleController.new(nil, nil)
    @controller.send(:new_context)
    
    @controller.context.should_not equal nil
    @controller.statemachine.should_not equal nil
    @controller.context.statemachine.should equal @controller.statemachine
    @controller.statemachine.context.should equal @controller.context
    @controller.initialized.should equal true
  end

  it "event action" do
    @controller.params = {:event => "boo"}
    @controller.session[:samplecontroller_state] = @context
    @context.should_receive(:statemachine).and_return(@statemachine)
    @statemachine.should_receive(:process_event).with("boo", nil)
    
    @controller.event
    
    @controller.before.should equal true
    @controller.after.should equal true
  end
  
  it "the event is not invoked is before_event return false" do
    @controller.params = {:event => "boo"}
    @controller.session[:samplecontroller_state] = @context
    @context.should_not_receive(:statemachine)
    @statemachine.should_not_receive(:process_event)
    @controller.can_continue = false
    
    @controller.event
    
    @controller.before.should equal true
    @controller.after.should_not equal true
  end

  
end
