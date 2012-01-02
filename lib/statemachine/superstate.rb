module Statemachine

  class Superstate < State #:nodoc:
  
    attr_accessor :startstate_id
    attr_reader :history_id
  
    def initialize(id, superstate, statemachine)
      super(id, superstate, statemachine)
      @startstate = nil
      @history_id = nil
      @default_history_id = nil
    end
    
    def concrete?
      return false
    end

    def startstate
      return @statemachine.get_state(@startstate_id)
    end

    def resolve_startstate
      return startstate.resolve_startstate
    end

    def substate_exiting(substate)
      @history_id = substate.id
    end
  
    def add_substates(*substate_ids)
      do_substate_adding(substate_ids)
    end
    
    def default_history=(state_id)
      @history_id = @default_history_id = state_id
    end
    
    def reset
      @history_id = @default_history_id
    end

    def to_s
      return "'#{id}' superstate"
    end
  
  end

end