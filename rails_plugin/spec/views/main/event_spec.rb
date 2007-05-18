require File.dirname(__FILE__) + '/../../spec_helper'

class Stub
  attr_reader :id
  
  def initialize(id)
    @id = id
  end
end

describe "Event View" do

  before(:each) do
    @display = mock("display")
    @display.stub!(:message).and_return("$123.45")
    @display.stub!(:affordable_items).and_return([Stub.new(1)])
    @display.stub!(:non_affordable_items).and_return([Stub.new(2)])
    @display.stub!(:sold_out_items).and_return([Stub.new(3)])
    @display.stub!(:dispensed_item).and_return(Product.new(:name => "Milk"))
    @display.stub!(:change).and_return("$0.25")
    
    @vending_machine = mock("vending machine")
    @vending_machine.stub!(:location).and_return("Downstairs")
    @vending_machine.stub!(:cash_str).and_return("$10.00")
    @vending_machine.stub!(:products).and_return([])
    
    assigns[:context] = @display
    assigns[:vending_machine] = @vending_machine
    
    render "/main/event"
  end
  
  it "message" do
     response.should have_rjs(:replace_html, "quartz_screen", ")$123.45"
  end
  
  it "affordable items" do
    response.body.should include("document.getElementById('product_1').className)= 'affordable'"
  end

  it "non affordable items" do
    response.body.should include("document.getElementById('product_2').className)= 'non_affordable'"
  end

  it "sold_out" do
    response.should have_rjs(:replace_html, "product_3_price", ")<span style=\"color: red;\">SOLD OUT</span>"
  end

  it "dispenser" do
    response.should have_rjs(:replace_html, "dispenser", ")<p>Milk</p>"
    response.should have_rjs(:show, "dispenser")
  end

  it "change" do
    response.should have_rjs(:replace_html, "change_amount", ")<p>$0.25</p>"
    response.should have_rjs(:show, "change_amount")
  end

  

end
