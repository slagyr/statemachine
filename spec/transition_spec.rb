require File.dirname(__FILE__) + '/spec_helper'

context "Transition Calculating Exits and Entries" do

  setup do
    @a = StateMachine::State.new("a", nil)
    @b = StateMachine::State.new("b", nil)
    @c = StateMachine::State.new("c", nil)
    @d = StateMachine::State.new("d", nil)
    @e = StateMachine::State.new("e", nil)
  end
  
  specify "to nil" do
    transition = StateMachine::Transition.new(@a, nil, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a].to_s
    entries.to_s.should_equal [].to_s
    entries.length.should_be 0
  end
  
  specify "to itself" do
    transition = StateMachine::Transition.new(@a, @a, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a].to_s
    entries.to_s.should_equal [@a].to_s
  end

  specify "to friend" do
    transition = StateMachine::Transition.new(@a, @b, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a].to_s
    entries.to_s.should_equal [@b].to_s
  end

  specify "to parent" do
    @a.superstate = @b
    transition = StateMachine::Transition.new(@a, @b, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a, @b].to_s
    entries.to_s.should_equal [@b].to_s
  end

  specify "to uncle" do
    @a.superstate = @b
    transition = StateMachine::Transition.new(@a, @c, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a, @b].to_s
    entries.to_s.should_equal [@c].to_s
  end

  specify "to cousin" do
    @a.superstate = @b
    @c.superstate = @d
    transition = StateMachine::Transition.new(@a, @c, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a, @b].to_s
    entries.to_s.should_equal [@d, @c].to_s
  end
  
  specify "to nephew" do
    @a.superstate = @b
    transition = StateMachine::Transition.new(@c, @a, nil, nil)
    exits, entries = transition.exits_and_entries(@c)
    exits.to_s.should_equal [@c].to_s
    entries.to_s.should_equal [@b,@a].to_s
  end

  specify "to sister" do
    @a.superstate = @c
    @b.superstate = @c
    transition = StateMachine::Transition.new(@a, @b, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a].to_s
    entries.to_s.should_equal [@b].to_s
  end
  
  specify "to second cousin" do
    @a.superstate = @b
    @b.superstate = @c
    @d.superstate = @e
    @e.superstate = @c
    transition = StateMachine::Transition.new(@a, @d, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a, @b].to_s
    entries.to_s.should_equal [@e, @d].to_s
  end

  specify "to grandparent" do
    @a.superstate = @b
    @b.superstate = @c
    transition = StateMachine::Transition.new(@a, @c, nil, nil)
    exits, entries = transition.exits_and_entries(@a)
    exits.to_s.should_equal [@a, @b, @c].to_s
    entries.to_s.should_equal [@c].to_s
  end
  
end
