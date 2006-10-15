module StateMachine

  class Superstate < State
  
    attr_accessor :start_state
  
    def initialize(state, transitions, substate_ids)
      @id = state.id
      @statemachine = state.statemachine
      @transitions = transitions
      @entry_action = state.entry_action
      @exit_action = state.exit_action
      @superstate = state.superstate
      do_substate_adding(substate_ids)
    end
    
    def enter(args, event)
      super(args, event)
      return @start_state.enter(args, event)
    end
  
    def add_substates(*substate_ids)
      do_substate_adding(substate_ids)
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