module StateMachine

  class Superstate < State
  
    attr_writer :start_state
  
    def initialize(state, transitions, substate_ids)
      @id = state.id
      @statemachine = state.statemachine
      @transitions = transitions
      @entry_action = state.entry_action
      @exit_action = state.exit_action
      @superstate = state.superstate
      do_substate_adding(substate_ids)
    end
    
    def is_superstate?
      return true
    end
    
    def start_state
      if @use_history and @history_state
        return @history_state
      else
        return @start_state
      end
    end
    
    def existing(substate)
      @history_state = substate
    end
  
    def add_substates(*substate_ids)
      do_substate_adding(substate_ids)
    end
    
    def use_history
      @use_history = true;
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