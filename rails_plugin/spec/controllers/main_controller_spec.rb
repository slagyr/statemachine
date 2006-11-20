require File.dirname(__FILE__) + '/../spec_helper'

context "The MainController" do
  # fixtures :mains
  controller_name :main

  specify "should be a MainController" do
    controller.should_be_an_instance_of MainController
  end


  specify "should have more specifications" do
    violated "not enough specs"
  end
end
