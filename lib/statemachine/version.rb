module Statemachine
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR  = 0
      MINOR  = 4
      TINY   = 1

      STRING = [MAJOR, MINOR, TINY].join('.')
      TAG    = "REL_" + [MAJOR, MINOR, TINY].join('_')

      NAME   = "Statemachine"
      URL    = "http://statemachine.rubyforge.org/"  
    
      DESCRIPTION = "#{NAME}-#{STRING} - Statemachine Library for Ruby\n#{URL}"
    end
  end
end