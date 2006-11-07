module StateMachine

  class Superstate < State
  
    attr_writer :start_state
    attr_reader :history
    
    def self.from_state(state, transitions, substate_ids)
      superstate = Superstate.new(state.id, state.statemachine)
      superstate.instance_exec do
        @transitions = transitions
        @entry_action = state.entry_action
        @exit_action = state.exit_action
        @superstate = state.superstate
        do_substate_adding(substate_ids)
        @history = HistoryState.new(self)
      end
      return superstate
    end
  
    def initialize(id, statemachine)
      super(id, statemachine)
      @start_state = nil
      @history = HistoryState.new(self)
    end
    
    def is_concrete?
      return false
    end
    
    def start_state
      return @start_state
    end
    
    def substate_exiting(substate)
      @history.last_exited = substate
    end
  
    def add_substates(*substate_ids)
      do_substate_adding(substate_ids)
    end

    def to_s
      return "'#{id}' superstate"
    end

    private
  
    def do_substate_adding(substate_ids)
      substate_ids.each do |substate_id|
        substate = @statemachine.acquire_state(substate_id)
        @start_state = substate if not @start_state
        substate.superstate = self
        check_for_substate_recursion
      end
    end
  
    def check_for_substate_recursion
      tmp_state = @superstate
      while tmp_state
        if tmp_state == self
          raise StateMachineException.new("Cyclic substates not allowed. (#{id})")
        end 
        tmp_state = tmp_state.superstate
      end
    end
  
  end

end