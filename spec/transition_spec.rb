require File.dirname(__FILE__) + '/spec_helper'

context "Transition Calculating Exits and Entries" do

  setup do
    @a = StateMachine::State.new("a", nil)
    @b = StateMachine::State.new("b", nil)
    @c = StateMachine::State.new("c", nil)
    @d = StateMachine::State.new("d", nil)
    @e = StateMachine::State.new("e", nil)
    @transition = StateMachine::Transition.new(nil, nil, nil, nil)
  end
  
  specify "to nil" do
    exits, entries = @transition.exits_and_entries(@a, nil)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [].to_s
    entries.length.should_be 0
  end
  
  specify "to itself" do
    exits, entries = @transition.exits_and_entries(@a, @a)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@a].to_s
  end

  specify "to friend" do
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@b].to_s
  end

  specify "to parent" do
    @a.superstate = @b
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@b].to_s
  end

  specify "to uncle" do
    @a.superstate = @b
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@c].to_s
  end

  specify "to cousin" do
    @a.superstate = @b
    @c.superstate = @d
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@d, @c].to_s
  end
  
  specify "to nephew" do
    @a.superstate = @b
    exits, entries = @transition.exits_and_entries(@c, @a)
    exits.to_s.should_eql [@c].to_s
    entries.to_s.should_eql [@b,@a].to_s
  end

  specify "to sister" do
    @a.superstate = @c
    @b.superstate = @c
    exits, entries = @transition.exits_and_entries(@a, @b)
    exits.to_s.should_eql [@a].to_s
    entries.to_s.should_eql [@b].to_s
  end
  
  specify "to second cousin" do
    @a.superstate = @b
    @b.superstate = @c
    @d.superstate = @e
    @e.superstate = @c
    exits, entries = @transition.exits_and_entries(@a, @d)
    exits.to_s.should_eql [@a, @b].to_s
    entries.to_s.should_eql [@e, @d].to_s
  end

  specify "to grandparent" do
    @a.superstate = @b
    @b.superstate = @c
    exits, entries = @transition.exits_and_entries(@a, @c)
    exits.to_s.should_eql [@a, @b, @c].to_s
    entries.to_s.should_eql [@c].to_s
  end

  specify "to parent's grandchild" do
    @a.superstate = @b
    @b.superstate = @c
    @d.superstate = @c
    exits, entries = @transition.exits_and_entries(@d, @a)
    exits.to_s.should_eql [@d].to_s
    entries.to_s.should_eql [@b, @a].to_s
  end
  
end
