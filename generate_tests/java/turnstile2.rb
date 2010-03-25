$: << File.expand_path(File.dirname(__FILE__) + "/../../lib")
require 'statemachine'
require 'statemachine/generate/java'
@output = File.expand_path(File.dirname(__FILE__) + "/turnstile2")

def clean
  system "rm -rf #{@output}/java"
  class_files = Dir.glob("#{@output}/*.class")
  class_files.each { |file| system "rm #{file}" }
  system "rm #{@output}/output.txt"
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
  
  @sm.to_java(:output => @output, :name => "JavaTurnstile", :package => "thejava.turnstile")
end

def compile
  java_files = Dir.glob("#{@output}/**/*.java")
  command = "javac #{java_files.join(' ')}"
  system command
end

def run
  system "java -cp #{@output} Turnstile2Main > #{@output}/output.txt"
end

def check
  actual = IO.read("#{@output}/output.txt").strip.split("\n")
  expected = %w{operate lock alarm unlock thanks lock beep disable beep operate lock unlock lock}

  if actual == expected
    puts "PASSED"
  else
    puts "FAILED"
    puts "--------------- expected:"
    puts expected
    puts "--------------- actual:"
    puts actual
  end
end

clean
generate
compile
run
check


