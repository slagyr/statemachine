require File.dirname(__FILE__) + '/../spec_helper'

context "Product class with fixtures loaded" do
  fixtures :products

  specify "Saved with name and price" do
    saved = Product.new(:name => "Water", :price => 150)
    saved.save!
    
    loaded = Product.find(saved.id)
    loaded.name.should_eql "Water"
    loaded.price.should_be 150
  end

  
end
