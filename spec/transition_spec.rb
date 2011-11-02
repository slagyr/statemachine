require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Transition Calculating Exits and Entries" do

  before(:each) do
    @transition = Statemachine::Transition.new(nil, nil, nil, nil)
  end
  
  it "to nil" do
    @a = Statemachine::State.new("a", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, nil)
    exits.to_s.should eql([@a].to_s)
    entries.to_s.should eql([].to_s)
    entries.length.should equal(0)
  end
  
  it "to itself" do
    @a = Statemachine::State.new("a", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @a)
    exits.should == []
    entries.should == []
  end

  it "to friend" do
    @a = Statemachine::State.new("a", nil, nil)
    @b = Statemachine::State.new("b", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should eql([@a].to_s)
    entries.to_s.should eql([@b].to_s)
  end

  it "to parent" do
    @b = Statemachine::State.new("b", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should eql([@a, @b].to_s)
    entries.to_s.should eql([@b].to_s)
  end

  it "to uncle" do
    @b = Statemachine::State.new("b", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    @c = Statemachine::State.new("c", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should eql([@a, @b].to_s)
    entries.to_s.should eql([@c].to_s)
  end

  it "to cousin" do
    @b = Statemachine::State.new("b", nil, nil)
    @d = Statemachine::State.new("d", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    @c = Statemachine::State.new("c", @d, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should eql([@a, @b].to_s)
    entries.to_s.should eql([@d, @c].to_s)
  end
  
  it "to nephew" do
    @b = Statemachine::State.new("b", nil, nil)
    @c = Statemachine::State.new("c", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@c, @a)
    exits.to_s.should eql([@c].to_s)
    entries.to_s.should eql([@b,@a].to_s)
  end

  it "to sister" do
    @c = Statemachine::State.new("c", nil, nil)
    @a = Statemachine::State.new("a", @c, nil)
    @b = Statemachine::State.new("b", @c, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should eql([@a].to_s)
    entries.to_s.should eql([@b].to_s)
  end
  
  it "to second cousin" do
    @c = Statemachine::State.new("c", nil, nil)
    @b = Statemachine::State.new("b", @c, nil)
    @a = Statemachine::State.new("a", @b, nil)
    @e = Statemachine::State.new("e", @c, nil)
    @d = Statemachine::State.new("d", @e, nil)
    exits, entries = @transition.exits_and_entries(@a, @d)
    exits.to_s.should eql([@a, @b].to_s)
    entries.to_s.should eql([@e, @d].to_s)
  end

  it "to grandparent" do
    @c = Statemachine::State.new("c", nil, nil)
    @b = Statemachine::State.new("b", @c, nil)
    @a = Statemachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should eql([@a, @b, @c].to_s)
    entries.to_s.should eql([@c].to_s)
  end

  it "to parent's grandchild" do
    @c = Statemachine::State.new("c", nil, nil)
    @b = Statemachine::State.new("b", @c, nil)
    @a = Statemachine::State.new("a", @b, nil) 
    @d = Statemachine::State.new("d", @c, nil)
    exits, entries = @transition.exits_and_entries(@d, @a)
    exits.to_s.should eql([@d].to_s)
    entries.to_s.should eql([@b, @a].to_s)
  end
  
end
