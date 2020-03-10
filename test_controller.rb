require 'unimidi'
require 'pry'
require 'pp'
require './controller.rb'
require 'diffy'

def expect_equal(fixture, result)
  if fixture == result
    puts 'Hooray'
    puts '----------------------------'
  else
    puts 'oh no..'
    puts '----------------------------'
    puts Diffy::Diff.new(fixture, result).to_s(:color)
    raise 'OH no'
  end
end

def test_chrome_panel
  controller = Controller.new(testing: true)
  @chrome_outputs = []
  @chrome_fixtures =
    [:tabs,
     :pages,
     'xdotool key Control_L+Alt_L+r',
     :started_thread,
     'result:  xdotool key Page_Up',
     :started_thread,
     'result:  xdotool key Page_Down',
     :tabs,
     'xdotool key Control_L+Shift_L+Tab',
     'xdotool key Control_L+Tab',
     'xdotool key Control_L+F4',
     :pages,
     :started_thread,
     'result:  xdotool key Up xdotool key Up',
     :started_thread,
     'result:  xdotool key Down xdotool key Down']

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

def test_emailreader_panel
  controller = Controller.new(testing: true)
  @emailreader_outputs = []
  @emailreader_fixtures =
    ['xdotool key Left',
     'xdotool key Return',
     :started_thread,
     'result:  xdotool key Down',
     :started_thread,
     'result:  xdotool key Up',
     :started_thread,
     'result:  xdotool key Page_Down',
     :started_thread,
     'result:  xdotool key Page_Up']

  @emailreader_outputs << controller.process(20)
  @emailreader_outputs << controller.process(21)
  @emailreader_outputs << controller.process(22)
  sleep 0.1
  @emailreader_outputs << controller.process(23) # short press
  @emailreader_outputs << controller.process(24)
  sleep 0.1
  @emailreader_outputs << controller.process(25) # short press
  @emailreader_outputs << controller.process(22)
  sleep 1.1
  @emailreader_outputs << controller.process(23) # long press
  @emailreader_outputs << controller.process(24)
  sleep 1.1
  @emailreader_outputs << controller.process(25) # long press
  puts '----------------------------'
end

def test_gnome_panel
  controller = Controller.new(testing: true)
  @gnome_outputs = []
  @gnome_fixtures =
    [:started_thread,
     'result:  xdotool key Return',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name chromium windowactivate',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name Firefox windowactivate',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name sublime windowactivate',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name VirtualBox windowactivate',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name terminal windowactivate',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name thunderbird windowactivate',
     :started_thread,
     'result:  xdotool search --onlyvisible --class --classname --name slack windowactivate']

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
  sleep 1.1
  @gnome_outputs << controller.process(8)
  @gnome_outputs << controller.process(9)
  sleep 1.1
  @gnome_outputs << controller.process(10)
  @gnome_outputs << controller.process(11)
  sleep 1.1
  @gnome_outputs << controller.process(12)
  @gnome_outputs << controller.process(13)
  sleep 1.1
  @gnome_outputs << controller.process(14) # long presses
  puts '----------------------------'
end

def test_pluralsight_panel
  controller = Controller.new(testing: true)
  @pluralsight_outputs = []
  @pluralsight_fixtures =
    ['xdotool key Left',
     'xdotool key KP_Space',
     'xdotool key Right',
     :alt_state,
     'xdotool key f',
     'xdotool key Return',
     :navigate]

  @pluralsight_outputs << controller.process(17)
  @pluralsight_outputs << controller.process(18)
  @pluralsight_outputs << controller.process(19)
  @pluralsight_outputs << controller.process(16) # switch modes
  @pluralsight_outputs << controller.process(17)
  @pluralsight_outputs << controller.process(18)
  @pluralsight_outputs << controller.process(15) # switch modes
  puts '----------------------------'
end

puts '----------------------------'
test_chrome_panel

expect_equal(@chrome_fixtures, @chrome_outputs)

test_emailreader_panel

expect_equal(@emailreader_fixtures, @emailreader_outputs)

test_gnome_panel

expect_equal(@gnome_fixtures, @gnome_outputs)

test_pluralsight_panel

expect_equal(@pluralsight_fixtures, @pluralsight_outputs)
