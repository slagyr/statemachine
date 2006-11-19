require 'statemachine_support'

ActionController::Base.class_eval do
  include Statemachine::ControllerSupport
end