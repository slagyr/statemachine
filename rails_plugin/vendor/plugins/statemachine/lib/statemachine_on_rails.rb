dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/controller_support")
require File.expand_path("#{dir}/context_support")

ActionController::Base.class_eval do
  include Statemachine::ControllerSupport
end

ActiveRecord::Base.class_eval do
  include Statemachine::ActiveRecordMarshalling
end