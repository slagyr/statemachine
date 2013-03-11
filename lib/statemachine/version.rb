module Statemachine
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR  = 2
      MINOR  = 2
      TINY   = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
      TAG    = "REL_" + [MAJOR, MINOR, TINY].join('_')

      NAME   = "Statemachine"
      URL    = "http://slagyr.github.com/statemachine"  
    
      DESCRIPTION = "#{NAME}-#{STRING} - Statemachine Library for Ruby\n#{URL}"
    end
  end
end
