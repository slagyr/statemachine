require File.dirname(__FILE__) + '/spec_helper'

context "Transition Calculating Exits and Entries" do

  setup do
    @transition = StateMachine::Transition.new(nil, nil, nil, nil)
  end
  
  specify "to nil" do
    @a = StateMachine::State.new("a", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, nil)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [].to_s
    entries.length.should_be 0
  end
  
  specify "to itself" do
    @a = StateMachine::State.new("a", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @a)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@a].to_s
  end

  specify "to friend" do
    @a = StateMachine::State.new("a", nil, nil)
    @b = StateMachine::State.new("b", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@b].to_s
  end

  specify "to parent" do
    @b = StateMachine::State.new("b", nil, nil)
    @a = StateMachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@b].to_s
  end

  specify "to uncle" do
    @b = StateMachine::State.new("b", nil, nil)
    @a = StateMachine::State.new("a", @b, nil)
    @c = StateMachine::State.new("c", nil, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@c].to_s
  end

  specify "to cousin" do
    @b = StateMachine::State.new("b", nil, nil)
    @d = StateMachine::State.new("d", nil, nil)
    @a = StateMachine::State.new("a", @b, nil)
    @c = StateMachine::State.new("c", @d, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@d, @c].to_s
  end
  
  specify "to nephew" do
    @b = StateMachine::State.new("b", nil, nil)
    @c = StateMachine::State.new("c", nil, nil)
    @a = StateMachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@c, @a)
    exits.to_s.should_eql [@c].to_s
    entries.to_s.should_eql [@b,@a].to_s
  end

  specify "to sister" do
    @c = StateMachine::State.new("c", nil, nil)
    @a = StateMachine::State.new("a", @c, nil)
    @b = StateMachine::State.new("b", @c, nil)
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@b].to_s
  end
  
  specify "to second cousin" do
    @c = StateMachine::State.new("c", nil, nil)
    @b = StateMachine::State.new("b", @c, nil)
    @a = StateMachine::State.new("a", @b, nil)
    @e = StateMachine::State.new("e", @c, nil)
    @d = StateMachine::State.new("d", @e, nil)
    exits, entries = @transition.exits_and_entries(@a, @d)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@e, @d].to_s
  end

  specify "to grandparent" do
    @c = StateMachine::State.new("c", nil, nil)
    @b = StateMachine::State.new("b", @c, nil)
    @a = StateMachine::State.new("a", @b, nil)
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b, @c].to_s
    entries.to_s.should_eql [@c].to_s
  end

  specify "to parent's grandchild" do
    @c = StateMachine::State.new("c", nil, nil)
    @b = StateMachine::State.new("b", @c, nil)
    @a = StateMachine::State.new("a", @b, nil) 
    @d = StateMachine::State.new("d", @c, nil)
    exits, entries = @transition.exits_and_entries(@d, @a)
    exits.to_s.should_eql [@d].to_s
    entries.to_s.should_eql [@b, @a].to_s
  end
  
end
