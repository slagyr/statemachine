require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

class Noodle
  
  attr_accessor :shape, :cooked
  
  def initialize
    @shape = "farfalla"
    @cooked = false
  end
  
  def cook
    @cooked = true
  end
  
  def transform(shape)
    @shape = shape
  end
  
end

describe "Action Invokation" do

  before(:each) do
    @noodle = Noodle.new
  end
  
  it "Proc actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, Proc.new { @cooked = true } 
    end
    
    sm.context = @noodle
    sm.fire
    
    @noodle.cooked.should equal(true)
  end
  
  it "Symbol actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, :cook
      smb.trans :hot, :mold, :changed, :transform
    end
  
    sm.context = @noodle
    sm.fire
  
    @noodle.cooked.should equal(true)
    
    sm.mold "capellini"
    
    @noodle.shape.should eql("capellini")
  end

  it "String actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, "@shape = 'fettucini'; @cooked = true"
    end
    sm.context = @noodle
    
    sm.fire
    @noodle.shape.should eql("fettucini")
    @noodle.cooked.should equal(true)
  end

end
