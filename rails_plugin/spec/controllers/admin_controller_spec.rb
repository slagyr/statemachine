require File.dirname(__FILE__) + '/../spec_helper'

context "The AdminController" do
  # fixtures :admins
  controller_name :admin

  specify "should be a AdminController" do
    controller.should_be_an_instance_of AdminController
  end


  specify "should have more specifications" do
    violated "not enough specs"
  end
end
