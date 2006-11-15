module Statemachine
  
  def self.build(statemachine = nil, &block)
    builder = statemachine ? StatemachineBuilder.new(statemachine) : StatemachineBuilder.new
    builder.instance_eval(&block)
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
        state = State.new(state_id, context, @statemachine)
        @statemachine.add_state(state)
      end
      context.startstate_id = state_id if context.startstate_id == nil
      return state
    end
  end
  
  module StateBuilding
    attr_reader :subject
  
    def event(event, destination_id, action = nil)
      @subject.add(Transition.new(@subject.id, destination_id, event, action))
    end
    
    def on_entry(entry_action)
      @subject.entry_action = entry_action
    end
    
    def on_exit(exit_action)
      @subject.exit_action = exit_action
    end
  end
  
  module SuperstateBuilding
    attr_reader :subject
    
    def state(id, &block)
      builder = StateBuilder.new(id, @subject, @statemachine)
      builder.instance_eval(&block) if block
    end

    def superstate(id, &block)
      builder = SuperstateBuilder.new(id, @subject, @statemachine)
      builder.instance_eval(&block)
    end

    def trans(origin_id, event, destination_id, action = nil)
      origin = acquire_state_in(origin_id, @subject)
      origin.add(Transition.new(origin_id, destination_id, event, action))
    end
    
    def startstate(startstate_id)
      @subject.startstate_id = startstate_id
    end
    
    def on_entry_of(id, action)
      @statemachine.get_state(id).entry_action = action
    end
    
    def on_exit_of(id, action)
      @statemachine.get_state(id).exit_action = action
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
      @subject = Superstate.new(id, superstate, statemachine)
      superstate.startstate_id = id if superstate.startstate_id == nil
      statemachine.add_state(@subject)
    end
  end
  
  class StatemachineBuilder < Builder
    include SuperstateBuilding
    
    def initialize(statemachine = Statemachine.new)
      super statemachine
      @subject = @statemachine.root
    end
  end
  
end