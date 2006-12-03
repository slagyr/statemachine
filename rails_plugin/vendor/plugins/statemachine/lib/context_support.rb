module Statemachine
  
  module ContextSupport
    
    attr_accessor :statemachine, :context
    
  end
  
  module ActiveRecordMarshalling
    def marshal_dump
      return self.id
    end
    
    def marshal_load(id)
      @attributes = {}
      @new_record = false
      self.id = id
      self.reload
    end
  end
  
end
