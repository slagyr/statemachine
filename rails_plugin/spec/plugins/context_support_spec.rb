require File.dirname(__FILE__) + '/../spec_helper'

describe "Context Support" do

  before(:each) do
    @product = Product.new(:name => "Chicken")
    @product.save!
  end

  it "Active Recrods Marshalled Compact" do
    io = StringIO.new("")
    Marshal.dump(@product, io)
    io.rewind
    
    dump = io.read
    dump.should_not include("Chicken")
  end

  it "Active Records Loaded properly" do 
    io = StringIO.new("")
    Marshal.dump(@product, io)
    io.rewind
    
    loaded = Marshal.load(io)
    loaded.name.should eql("Chicken")
  end

end
