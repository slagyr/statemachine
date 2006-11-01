module StateMachine

  class HistoryState < State
    
    attr_writer :last_exited
    
    def initialize(super_state)
      super(super_state.id.to_s + ".history", super_state.statemachine)
      @super_state = super_state
    end
    
    def is_concrete?
      return false
    end
    
    def start_state
      return @last_exited
    end
  end

end