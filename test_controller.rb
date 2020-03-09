require 'unimidi'
require 'pry'
require 'pp'
require './controller.rb'

def expect_equal(fixture, result)
  if fixture == result
    puts 'Hooray'
    puts '----------------------------'
  else
    puts 'oh no..'
    puts '----------------------------'
    pp result
    raise 'OH no'
  end
end

def test_chrome_panel
  controller = Controller.new(testing: true)
  @chrome_outputs = []
  @chrome_fixtures = [:tabs,
                      :pages,
                      'xdotool key Control_L+Alt_L+r',
                      :started_thread,
                      'result: , xdotool key Page_Up',
                      :started_thread,
                      'result: , xdotool key Page_Down',
                      :tabs,
                      'xdotool key Control_L+Shift_L+Tab',
                      'xdotool key Control_L+Tab',
                      'xdotool key Control_L+F4',
                      :pages,
                      :started_thread,
                      'result: , xdotool key Up, xdotool key Up',
                      :started_thread,
                      'result: , xdotool key Down, xdotool key Down']

  @chrome_outputs << controller.process(1)
  @chrome_outputs << controller.process(0) # to pages
  @chrome_outputs << controller.process(2)
  @chrome_outputs << controller.process(3)
  sleep 0.1
  @chrome_outputs << controller.process(4)
  @chrome_outputs << controller.process(5)
  sleep 0.1
  @chrome_outputs << controller.process(6)
  @chrome_outputs << controller.process(1) # to tabs
  @chrome_outputs << controller.process(2)
  @chrome_outputs << controller.process(3)
  @chrome_outputs << controller.process(5)
  @chrome_outputs << controller.process(0) # to pages
  @chrome_outputs << controller.process(3)
  sleep 1.6
  @chrome_outputs << controller.process(4)
  @chrome_outputs << controller.process(5)
  sleep 1.6
  @chrome_outputs << controller.process(6)
  puts '----------------------------'
end

def test_gnome_panel
  controller = Controller.new(testing: true)
  @gnome_outputs = []
  @gnome_fixtures =
    [:started_thread,
     'xdotool key Return',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name chromium windowactivate',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name Firefox windowactivate',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name sublime windowactivate',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name VirtualBox windowactivate',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name terminal windowactivate',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name thunderbird windowactivate',
     :started_thread,
     'xdotool search --onlyvisible --class --classname --name slack windowactivate']

  @gnome_outputs << controller.process(7)
  sleep 0.1
  @gnome_outputs << controller.process(8)
  @gnome_outputs << controller.process(9)
  sleep 0.1
  @gnome_outputs << controller.process(10)
  @gnome_outputs << controller.process(11)
  sleep 0.1
  @gnome_outputs << controller.process(12)
  @gnome_outputs << controller.process(13)
  sleep 0.1
  @gnome_outputs << controller.process(14) # Short presses

  @gnome_outputs << controller.process(7)
  sleep 1.0
  @gnome_outputs << controller.process(8)
  @gnome_outputs << controller.process(9)
  sleep 1.0
  @gnome_outputs << controller.process(10)
  @gnome_outputs << controller.process(11)
  sleep 1.0
  @gnome_outputs << controller.process(12)
  @gnome_outputs << controller.process(13)
  sleep 1.0
  @gnome_outputs << controller.process(14) # long presses

  puts '----------------------------'
end

puts '----------------------------'
test_chrome_panel

expect_equal(@chrome_fixtures, @chrome_outputs)

test_gnome_panel

expect_equal(@gnome_fixtures, @gnome_outputs)
