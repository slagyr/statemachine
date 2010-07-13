$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'spec'
require 'statemachine'

def check_transition(transition, origin_id, destination_id, event, action)
  transition.should_not equal(nil)
  transition.event.should equal(event)
  transition.origin_id.should equal(origin_id)
  transition.destination_id.should equal(destination_id)
  transition.action.should eql(action)
end

module SwitchStatemachine

  def create_switch
    @status = "off"
    @sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @status = "on" }
      trans :on, :toggle, :off, Proc.new { @status = "off" }
    end
    @sm.context = self
  end

end

module TurnstileStatemachine

  def create_turnstile
    @locked = true
    @alarm_status = false
    @thankyou_status = false
    @lock = "@locked = true"
    @unlock = "@locked = false"
    @alarm = "@alarm_status = true"
    @thankyou = "@thankyou_status = true"

    @sm = Statemachine.build do
      trans :locked, :coin, :unlocked, "@locked = false"
      trans :unlocked, :pass, :locked, "@locked = true"
      trans :locked, :pass, :locked, "@alarm_status = true"
      trans :unlocked, :coin, :locked, "@thankyou_status = true"
    end
    @sm.context = self
  end

end

TEST_DIR = File.expand_path(File.dirname(__FILE__) + "/../test_dir/")

def test_dir(name = nil)
  Dir.mkdir(TEST_DIR) if !File.exist?(TEST_DIR)
  return TEST_DIR if name.nil?
  dir = File.join(TEST_DIR, name)
  Dir.mkdir(dir) if !File.exist?(dir)
  return dir
end

def remove_test_dir(name)
  system "rm -rf #{test_dir(name)}" if File.exist?(test_dir(name))
end

def load_lines(*segs)
  filename = File.join(*segs)
  File.should exist( filename)
  return IO.read(filename).split("\n")
end
