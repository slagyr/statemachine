require 'statemachine_support'

ActionController::Base.class_eval do
  include StateMachine::ControllerSupport
end