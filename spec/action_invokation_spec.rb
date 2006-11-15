require File.dirname(__FILE__) + '/spec_helper'

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

context "Action Invokation" do

  setup do
    @noodle = Noodle.new
  end
  
  specify "Proc actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, Proc.new { @cooked = true } 
    end
    
    sm.context = @noodle
    sm.fire
    
    @noodle.cooked.should_be true
  end
  
  specify "Symbol actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, :cook
      smb.trans :hot, :mold, :changed, :transform
    end
  
    sm.context = @noodle
    sm.fire
  
    @noodle.cooked.should_be true
    
    sm.mold "capellini"
    
    @noodle.shape.should_eql "capellini"
  end

  specify "String actions" do
    sm = Statemachine.build do |smb|
      smb.trans :cold, :fire, :hot, "@shape = 'fettucini'; @cooked = true"
    end
    sm.context = @noodle
    
    sm.fire
    @noodle.shape.should_eql "fettucini"
    @noodle.cooked.should_be true
  end

  
  
end
