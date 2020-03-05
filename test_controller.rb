require 'unimidi'
require 'pry'
require 'pp'
require './controller.rb'

def expect_equal (fixture, result)
  if fixture == result
    puts "Hooray"
  else
    puts "oh no.."
    pp result
    raise "OH no"
  end
end

controller = Controller.new(testing: true)
outputs = []
fixtures = [:tabs,
            :pages,
            "xdotool key Control_L+Alt_L+r",
            :started_thread,
            "result: , xdotool key Page_Up",
            "xdotool key Page_Down",
            :tabs,
            "xdotool key Control_L+Shift_L+Tab",
            "xdotool key Control_L+Tab",
            "xdotool key Control_L+F4",
            :pages,
            :started_thread,
            "result: , xdotool key Up, xdotool key Up"]

outputs << controller.process(1)
outputs << controller.process(0)
outputs << controller.process(2)
outputs << controller.process(3)
sleep 0.1
outputs << controller.process(4)
outputs << controller.process(5)
outputs << controller.process(1)
outputs << controller.process(2)
outputs << controller.process(3)
outputs << controller.process(5)
outputs << controller.process(0)
outputs << controller.process(3)
sleep 1.6
outputs << controller.process(4)

puts "----------------------------"
expect_equal(fixtures, outputs)
