$: << File.expand_path(File.dirname(__FILE__) + "/../../lib")
require 'statemachine'
require 'statemachine/generate/dot_graph'
@output = File.expand_path(File.dirname(__FILE__) + "/turnstile")

def clean
  class_files = Dir.glob("#{@output}/*.dot")
  class_files.each { |file| system "rm #{file}" }
end

def generate
  @sm = Statemachine.build do
    trans :locked, :coin, :unlocked, :unlock
    trans :unlocked, :pass, :locked, :lock
    trans :locked, :pass, :locked, :alarm
    trans :unlocked, :coin, :locked, :thanks
  end
  @sm.to_dot(:output => @output)
end

def open
  `open #{@output}/main.dot`
end

clean
generate
open


