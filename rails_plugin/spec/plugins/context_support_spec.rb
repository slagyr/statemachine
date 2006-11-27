require File.dirname(__FILE__) + '/../spec_helper'

context "Context Support" do

  setup do
    @product = Product.new(:name => "Chicken")
    @product.save!
  end

  specify "Active Recrods Marshalled Compact" do
    io = StringIO.new("")
    Marshal.dump(@product, io)
    io.rewind
    
    dump = io.read
    dump.should_not_include "Chicken"
  end

  specify "Active Records Loaded properly" do 
    io = StringIO.new("")
    Marshal.dump(@product, io)
    io.rewind
    
    loaded = Marshal.load(io)
    loaded.name.should_eql "Chicken"
  end

end
