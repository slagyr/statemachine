require 'statemachine'

module Statemachine
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
      
      attr_reader :statemachine, :context
    
      #def new_context(*args)
      #  @context = self.class.context_class.new(*args)
      #  @statemachine = @context.create_state_machine
      #end  
      
      protected
      def save_state
        session[state_session_key] = @context
      end

      def recall_state
        @context = session[state_session_key]
      end
    
      def state_session_key
        return "#{self.class.name.downcase}_state".to_sym
      end
    end
  end
end
