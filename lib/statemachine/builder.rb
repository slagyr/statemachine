module StateMachine
  
  def self.build(statemachine = nil)
    builder = statemachine ? StatemachineBuilder.new(statemachine) : StatemachineBuilder.new
    yield builder
    builder.statemachine.reset
    return builder.statemachine
  end
  
  class Builder
    attr_reader :statemachine
    
    def initialize(statemachine)
      @statemachine = statemachine
    end
    
    protected
    def acquire_state_in(state_id, context)
      return nil if state_id == nil
      return state_id if state_id.is_a? State
      state = nil
      if @statemachine.has_state(state_id)
        state = @statemachine.get_state(state_id)
      else
        state = State.new(state_id, @statemachine)
        state.superstate = context
        @statemachine.add_state(state)
      end
      return state
    end
  end
  
  module StateBuilding
    attr_reader :subject
  
    def event(event, destination_id, action = nil)
      @subject.add(Transition.new(@subject.id, destination_id, event, action))
    end
    
    def on_entry(&entry_action)
      @subject.entry_action = entry_action
    end
    
    def on_exit(&exit_action)
      @subject.exit_action = exit_action
    end
  end
  
  module SuperstateBuilding
    attr_reader :subject
    
    def state(id)
      builder = StateBuilder.new(id, @subject, @statemachine)
      yield builder
    end

    def superstate(id)
      builder = SuperstateBuilder.new(id, @subject, @statemachine)
      yield builder
    end

    def trans(origin_id, event, destination_id, action = nil)
      origin = acquire_state_in(origin_id, @subject)
      origin.add(Transition.new(origin_id, destination_id, event, action))
    end
    
    def start_state(start_state_id)
      @subject.start_state = @statemachine.get_state(start_state_id)
      raise "Start state #{start_state_id} not found" if not @subject.start_state
    end
  end
  
  class StateBuilder < Builder
    include StateBuilding
    
    def initialize(id, superstate, statemachine)
      super statemachine
      @subject = acquire_state_in(id, superstate)
    end
  end

  class SuperstateBuilder < Builder
    include StateBuilding
    include SuperstateBuilding
    
    def initialize(id, superstate, statemachine)
      super statemachine
      @subject = Superstate.new(id, statemachine)
      statemachine.add_state(@subject)
      @subject.superstate = superstate
    end
  end
  
  class StatemachineBuilder < Builder
    include SuperstateBuilding
    
    def initialize(statemachine = StateMachine.new)
      super statemachine
      @subject = @statemachine.root
    end
  end
  
end