module Statemachine

  class Superstate < State
  
    attr_accessor :startstate_id
    attr_reader :history
  
    def initialize(id, superstate, statemachine)
      super(id, superstate, statemachine)
      @startstate = nil
      @history = nil
    end
    
    def is_concrete?
      return false
    end
    
    def substate_exiting(substate)
      @history = substate
    end
  
    def add_substates(*substate_ids)
      do_substate_adding(substate_ids)
    end

    def to_s
      return "'#{id}' superstate"
    end
  
  end

end