require File.dirname(__FILE__) + '/../spec_helper'

describe "The MainController" do
  controller_name :main

end

describe "Index View spec" do
  controller_name :main
  integrate_views
  
  before(:each) do
    @vm = VendingMachine.new
    @product = @vm.add_product(10, "Glue", 100)
    @vm.save!
    
    post :index, :id => @vm.id
  end

  it "Has required divs" do
    response.should have_tag(:img, :attributes)=> { :id => "vending_machine_body" }
    response.should have_tag(:img, :attributes)=> { :id => "money_panel" }
    response.should have_tag(:a, :attributes)=> { :id => "cash_release_button" }
    response.should have_tag(:div, :attributes)=> { :id => "product_list" }
    response.should have_tag(:img, :attributes)=> { :id => "change" }
    response.should have_tag(:div, :attributes)=> { :id => "change_amount" }
    response.should have_tag(:div, :attributes)=> { :id => "cash" }
    response.should have_tag(:div, :attributes)=> { :id => "quartz_screen" }
    response.should have_tag(:div, :attributes)=> { :id => "dispenser" }
    response.should have_tag(:div, :attributes)=> { :id => "info" }
  end

  it "products" do
    response.should have_tag(:a, :attributes)=> { :id => "product_#{@product.id}" }
    response.should have_tag(:span, :attributes)=> { :id => "product_#{@product.id}_price" }
  end
  
end
