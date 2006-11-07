module StateMachine
  
  def self.build
    builder = StatemachineBuilder.new
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
      state = @statemachine.states[state_id]
      if not state
        state = State.new(state_id, @statemachine)
        @statemachine.states[state_id] = state
      end
      context.start_state = state if context.start_state == nil
      return state
    end
  end
  
  module StateBuilding
    attr_reader :subject
  
    def event(event, destination_id, action)
      @subject.add(Transition.new(@subject.id, destination_id, event, action))
    end
  end
  
  module SuperstateBuilding
    attr_reader :subject
    
    def state(id)
      builder = StateBuilder.new(id, @subject, @statemachine)
      @statemachine.states[id] = builder.subject
      builder.subject.superstate = @subject
      yield builder
    end

    def superstate(id)
      builder = SuperstateBuilder.new(id, @subject, @statemachine)
      @statemachine.states[id] = builder.subject
      builder.subject.superstate = @subject
      yield builder
    end

    def trans(origin_id, event, destination_id, action = nil)
      origin = acquire_state_in(origin_id, @subject)
      origin.superstate = @subject
      origin.add(Transition.new(origin_id, destination_id, event, action))
    end
    
    def start_state(start_state_id)
      @subject.start_state = @statemachine.states[start_state_id]
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
    end
  end
  
  class StatemachineBuilder < Builder
    include SuperstateBuilding
    
    def initialize
      @subject = Superstate.new(:root, @statemachine)
      super StateMachine.new(@subject)
    end
  end
  
end