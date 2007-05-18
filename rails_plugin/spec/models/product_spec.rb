require File.dirname(__FILE__) + '/../spec_helper'

describe "Product class with fixtures loaded" do
  fixtures :products

  it "Saved with name and price" do
    saved = Product.new(:name => "Water", :price => 150)
    saved.save!
    
    loaded = Product.find(saved.id)
    loaded.name.should eql("Water")
    loaded.price.should equal 150
  end

  
end
