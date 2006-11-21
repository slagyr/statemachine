require File.dirname(__FILE__) + '/../../spec_helper'

class Stub
  attr_reader :id
  
  def initialize(id)
    @id = id
  end
end

context "Event View" do

  setup do
    @display = mock("display")
    assigns[:display] = @display
    @display.stub!(:message).and_return("$123.45")
    @display.stub!(:affordable_items).and_return([Stub.new(1)])
    @display.stub!(:non_affordable_items).and_return([Stub.new(2)])
    @display.stub!(:sold_out_items).and_return([Stub.new(3)])
    
    render "/main/event"
  end
  
  specify "message" do
     response.should_have_rjs :replace_html, "quartz_screen", "$123.45"
  end
  
  specify "affordable items" do
    response.body.should_include "document.getElementById('product_1').class = 'affordable'"
  end

  specify "non affordable items" do
    response.body.should_include "document.getElementById('product_2').class = 'non_affordable'"
  end

  specify "sold_out" do
    response.should_have_rjs :replace_html, "product_3_price", "<span style=\"color: red;\">SOLD OUT</span>"
  end

  

end
