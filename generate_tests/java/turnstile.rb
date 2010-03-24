$: << File.expand_path(File.dirname(__FILE__) + "/../../lib")
require 'statemachine'
require 'statemachine/generate/java'
@output = File.expand_path(File.dirname(__FILE__) + "/turnstile")

def clean
  system "rm -rf #{@output}/java"
  class_files = Dir.glob("#{@output}/*.class")
  class_files.each { |file| system "rm #{file}" }
  system "rm #{@output}/output.txt"
end

def generate
  @sm = Statemachine.build do
    trans :locked, :coin, :unlocked, :unlock
    trans :unlocked, :pass, :locked, :lock
    trans :locked, :pass, :locked, :alarm
    trans :unlocked, :coin, :locked, :thanks
  end
  @sm.to_java(:output => @output, :name => "JavaTurnstile", :package => "thejava.turnstile")
end

def compile
  java_files = Dir.glob("#{@output}/**/*.java")
  command = "javac #{java_files.join(' ')}"
  system command
end

def run
  system "java -cp #{@output} TurnstileMain > #{@output}/output.txt"
end

def check
  actual = IO.read("#{@output}/output.txt").strip
  expected = "BUZZ BUZZ\nunlocked\nWhy thank you!\nunlocked\nlocked!"

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


