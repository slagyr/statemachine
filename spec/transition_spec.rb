require File.dirname(__FILE__) + '/spec_helper'

context "Transition Calculating Exits and Entries" do

  setup do
    @transition = Statemachine::Transition.new(nil, nil, nil, nil)
  end
  
  specify "to nil" do
    @a = Statemachine::State.new("a", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, nil)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [].to_s
    entries.length.should_be 0
  end
  
  specify "to itself" do
    @a = Statemachine::State.new("a", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @a)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@a].to_s
  end

  specify "to friend" do
    @a = Statemachine::State.new("a", nil, nil)
    @b = Statemachine::State.new("b", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@b].to_s
  end

  specify "to parent" do
    @b = Statemachine::State.new("b", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@b].to_s
  end

  specify "to uncle" do
    @b = Statemachine::State.new("b", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    @c = Statemachine::State.new("c", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@c].to_s
  end

  specify "to cousin" do
    @b = Statemachine::State.new("b", nil, nil)
    @d = Statemachine::State.new("d", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    @c = Statemachine::State.new("c", @d, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@d, @c].to_s
  end
  
  specify "to nephew" do
    @b = Statemachine::State.new("b", nil, nil)
    @c = Statemachine::State.new("c", nil, nil)
    @a = Statemachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@c, @a)
    exits.to_s.should_eql [@c].to_s
    entries.to_s.should_eql [@b,@a].to_s
  end

  specify "to sister" do
    @c = Statemachine::State.new("c", nil, nil)
    @a = Statemachine::State.new("a", @c, nil)
    @b = Statemachine::State.new("b", @c, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@b].to_s
  end
  
  specify "to second cousin" do
    @c = Statemachine::State.new("c", nil, nil)
    @b = Statemachine::State.new("b", @c, nil)
    @a = Statemachine::State.new("a", @b, nil)
    @e = Statemachine::State.new("e", @c, nil)
    @d = Statemachine::State.new("d", @e, nil)
    exits, entries = @transition.exits_and_entries(@a, @d)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@e, @d].to_s
  end

  specify "to grandparent" do
    @c = Statemachine::State.new("c", nil, nil)
    @b = Statemachine::State.new("b", @c, nil)
    @a = Statemachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b, @c].to_s
    entries.to_s.should_eql [@c].to_s
  end

  specify "to parent's grandchild" do
    @c = Statemachine::State.new("c", nil, nil)
    @b = Statemachine::State.new("b", @c, nil)
    @a = Statemachine::State.new("a", @b, nil) 
    @d = Statemachine::State.new("d", @c, nil)
    exits, entries = @transition.exits_and_entries(@d, @a)
    exits.to_s.should_eql [@d].to_s
    entries.to_s.should_eql [@b, @a].to_s
  end
  
end
