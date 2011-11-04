# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "statemachine/version"

Gem::Specification.new do |s|
  s.name        = "statemachine"
  s.version     = Statemachine::VERSION::STRING
  s.authors     = ["'Micah Micah'"]
  s.email       = ["'micah@8thlight.com'"]
  s.homepage    = "http://statemachine.rubyforge.org"
  s.summary     = Statemachine::VERSION::DESCRIPTION
  s.description = "Statemachine is a ruby library for building Finite State Machines (FSM), also known as Finite State Automata (FSA)."

  s.rubyforge_project = "statemachine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.autorequire = 'statemachine'
end
