require File.dirname(__FILE__) + '/../../spec_helper'

context "Index spec" do

  setup do
    @vm = mock("vending machine")
    @product = mock("product")
    @product.stub!(:name).and_return("Glue")
    @product.stub!(:id).and_return(123)
    @vm.stub!(:products).and_return([@product])
    assigns[:vending_machine] = @vm
    
    render "/main/index"
  end

  specify "Has required divs" do
    response.should_have_tag :img, :attributes => { :id => "vending_machine_body" }
    response.should_have_tag :img, :attributes => { :id => "money_panel" }
    response.should_have_tag :a, :attributes => { :id => "cash_release_button" }
    response.should_have_tag :div, :attributes => { :id => "product_list" }
    response.should_have_tag :img, :attributes => { :id => "change" }
    response.should_have_tag :div, :attributes => { :id => "change_amount" }
    response.should_have_tag :div, :attributes => { :id => "cash" }
    response.should_have_tag :div, :attributes => { :id => "quartz_screen" }
    response.should_have_tag :div, :attributes => { :id => "dispenser" }
    response.should_have_tag :div, :attributes => { :id => "info" }
  end

  specify "products" do
    response.should_have_tag :a, :attributes => { :id => "product_123" }
    response.should_have_tag :span, :attributes => { :id => "product_123_price" }
  end

  
  
end
