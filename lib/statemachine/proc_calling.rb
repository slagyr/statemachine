module StateMachine

  module ProcCalling
    
    private
      
    def call_proc(proc, args, message)
      arity = proc.arity
      required_params = arity < 0 ? arity.abs - 1 : arity
      
      raise StateMachineException.new("Insufficient parameters. (#{message})") if required_params > args.length
      
      parameters = arity < 0 ? args : args[0...arity]
      proc.call(*parameters)
    end
    
  end

end