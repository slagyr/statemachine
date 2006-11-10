module StateMachine

  class Superstate < State
  
    attr_writer :start_state
    attr_reader :history
  
    def initialize(id, superstate, statemachine)
      super(id, superstate, statemachine)
      @start_state = nil
      @history = nil
    end
    
    def is_concrete?
      return false
    end
    
    def start_state
      return @start_state
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