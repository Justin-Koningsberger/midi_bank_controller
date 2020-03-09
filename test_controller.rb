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
chrome_outputs = []
chrome_fixtures = [:tabs,
            :pages,
            "xdotool key Control_L+Alt_L+r",
            :started_thread,
            "result: , xdotool key Page_Up",
            :started_thread,
            "result: , xdotool key Page_Down",
            :tabs,
            "xdotool key Control_L+Shift_L+Tab",
            "xdotool key Control_L+Tab",
            "xdotool key Control_L+F4",
            :pages,
            :started_thread,
            "result: , xdotool key Up, xdotool key Up",
            :started_thread,
            "result: , xdotool key Down, xdotool key Down"]

chrome_outputs << controller.process(1)
chrome_outputs << controller.process(0) # to pages
chrome_outputs << controller.process(2)
chrome_outputs << controller.process(3)
sleep 0.1
chrome_outputs << controller.process(4)
chrome_outputs << controller.process(5)
sleep 0.1
chrome_outputs << controller.process(6)
chrome_outputs << controller.process(1) #to tabs
chrome_outputs << controller.process(2)
chrome_outputs << controller.process(3)
chrome_outputs << controller.process(5)
chrome_outputs << controller.process(0) # to pages
chrome_outputs << controller.process(3)
sleep 1.6
chrome_outputs << controller.process(4)
chrome_outputs << controller.process(5)
sleep 1.6
chrome_outputs << controller.process(6)

puts "----------------------------"
expect_equal(chrome_fixtures, chrome_outputs)
