module StateMachine
  module VERSION
    unless defined? MAJOR
      MAJOR  = 0
      MINOR  = 0
      TINY   = 2

      STRING = [MAJOR, MINOR, TINY].join('.')
      TAG    = "REL_" + [MAJOR, MINOR, TINY].join('_')

      NAME   = "StateMachine"
      URL    = "http://statemachine.rubyforge.org/"  
    
      DESCRIPTION = "#{NAME}-#{STRING} - State Machine Library for Ruby\n#{URL}"
    end
  end
end