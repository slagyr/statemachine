module Statemachine
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR  = 0
      MINOR  = 5
      TINY   = 1

      STRING = [MAJOR, MINOR, TINY].join('.')
      TAG    = "REL_" + [MAJOR, MINOR, TINY].join('_')

      NAME   = "Statemachine"
      URL    = "http://slagyr.github.com/statemachine"  
    
      DESCRIPTION = "#{NAME}-#{STRING} - Statemachine Library for Ruby\n#{URL}"
    end
  end
end