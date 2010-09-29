$: << File.expand_path(File.dirname(__FILE__) + "/../../lib")
require 'statemachine'
require 'statemachine/generate/dot_graph'
@output = File.expand_path(File.dirname(__FILE__) + "/turnstile2")

def clean
  class_files = Dir.glob("#{@output}/*.dot")
  class_files.each { |file| system "rm #{file}" }
end

def generate
  @sm = Statemachine.build do
    superstate :operational do
      on_entry :operate
      on_exit  :beep
      state :locked do
        on_entry :lock
        event :coin, :unlocked
        event :pass, :locked, :alarm
      end
      state :unlocked do
        on_entry :unlock
        event :coin, :unlocked, :thanks
        event :pass, :locked
      end
      event :diagnose, :diagnostics
    end
    state :diagnostics do
      on_entry :disable
      on_exit  :beep
      event :operate, :operational
    end
    stub_context :verbose => false
  end

  @sm.to_dot(:output => @output)
end

def open
  `open #{@output}/main.dot`
end


clean
generate
open


