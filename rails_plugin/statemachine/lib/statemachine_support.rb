require 'statemachine'

module StateMachine
  module ControllerSupport
    
    def self.included(base)
      base.extend SupportMacro
    end
    
    module SupportMacro
      
      def supported_by_statemachine(context_class)
        self.extend ClassMethods
        self.send(:include, InstanceMethods)
        
        self.context_class = context_class
      end
      
    end
    
    module ClassMethods
      
      attr_accessor :context_class
      
    end
    
    module InstanceMethods
      
      attr_reader :statemachine
    
      def new_context(*args)
        @context = self.class.context_class.new(*args)
        @statemachine = @context.create_state_machine
      end
      
    end
    
  end
end