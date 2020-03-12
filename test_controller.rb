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

def test_conversion
  controller = Controller.new(testing: true)
  @conversion_outputs = []
  @conversion_fixtures = ['L', 'E', 'E', 'T', 'Z']

  @conversion_outputs << controller.convert(12)
  @conversion_outputs << controller.convert(5)
  @conversion_outputs << controller.convert(5)
  @conversion_outputs << controller.convert(20)
  @conversion_outputs << controller.convert(26)
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
  @emailreader_outputs << controller.process(24)
  sleep 0.1
  @emailreader_outputs << controller.process(25) # short press
  @emailreader_outputs << controller.process(22)
  sleep 0.1
  @emailreader_outputs << controller.process(23) # short press
  @emailreader_outputs << controller.process(24)
  sleep 1.1
  @emailreader_outputs << controller.process(25) # long press
  @emailreader_outputs << controller.process(22)
  sleep 1.1
  @emailreader_outputs << controller.process(23) # long press
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

def test_trello_panel
  controller = Controller.new(testing: true)
  @trello_outputs = []
  @trello_fixtures =
    [:started_thread,
     'xdotool key Left',
     :started_thread,
     'xdotool key Return',
     :started_thread,
     'xdotool key l',
     :started_thread,
     'xdotool key Down',
     :started_thread,
     'xdotool key Page_Down',
     :started_thread,
     'xdotool key 7',
     :started_thread,
     'result:  xdotool key Up',
     :started_thread,
     'result:  xdotool key Page_Up',
     :started_thread,
     'result:  xdotool key Right',
     :started_thread,
     'result:  xdotool key Escape']

  @trello_outputs << controller.process(33)
  sleep 0.3
  @trello_outputs << controller.process(34) # short press, button 1
  @trello_outputs << controller.process(33)
  sleep 1.3
  @trello_outputs << controller.process(34) # long press, button 1
  @trello_outputs << controller.process(33)
  sleep 2.3
  @trello_outputs << controller.process(34) # extra long press, button 1
  @trello_outputs << controller.process(35)
  sleep 0.3
  @trello_outputs << controller.process(36) # short press, button 2
  @trello_outputs << controller.process(35)
  sleep 1.3
  @trello_outputs << controller.process(36) # long press, button 2
  @trello_outputs << controller.process(35)
  sleep 2.3
  @trello_outputs << controller.process(36) # extra long press, button 2
  @trello_outputs << controller.process(37)
  sleep 0.3
  @trello_outputs << controller.process(38) # short press, button 3
  @trello_outputs << controller.process(37)
  sleep 1.3
  @trello_outputs << controller.process(38) # long press, button 3
  @trello_outputs << controller.process(39)
  sleep 0.3
  @trello_outputs << controller.process(40) # short press, button 4
  @trello_outputs << controller.process(39)
  sleep 1.3
  @trello_outputs << controller.process(40) # long press, button 4
end

def test_vimium_panel
  controller = Controller.new(testing: true)
  @vimium_outputs = []
  @vimium_fixtures =
    ["xdotool key f",
     :started_thread,
     "1",
     :started_thread,
     "2",
     "0",
     :started_thread,
     "5",
     "xdotool key f",
     "0",
     :started_thread,
     "5",
     :started_thread,
     "2",
     "0",
     "xdotool key H"]

  @vimium_outputs << controller.process(27) # f pressed, wating for 4 numbers
  @vimium_outputs << controller.process(26)
  sleep 0.3
  @vimium_outputs << controller.process(27) # 1
  @vimium_outputs << controller.process(26)
  sleep 1.5
  @vimium_outputs << controller.process(27) # 2
  @vimium_outputs << controller.process(32) # 0
  @vimium_outputs << controller.process(28)
  sleep 1.5
  @vimium_outputs << controller.process(29) # 5
  @vimium_outputs << controller.process(27) # f pressed, wating for 4 numbers
  @vimium_outputs << controller.process(32) # 0
  @vimium_outputs << controller.process(28)
  sleep 1.5
  @vimium_outputs << controller.process(29) # 5
  @vimium_outputs << controller.process(26)
  sleep 1.5
  @vimium_outputs << controller.process(27) # 2
  @vimium_outputs << controller.process(32) # 0
  @vimium_outputs << controller.process(31) # H

  puts '----------------------------'
end

puts '***Conversion test'
test_conversion
expect_equal(@conversion_fixtures, @conversion_outputs)

puts '***Chrome panel test***'
test_chrome_panel
expect_equal(@chrome_fixtures, @chrome_outputs)

puts '***Emailreader panel test'
test_emailreader_panel
expect_equal(@emailreader_fixtures, @emailreader_outputs)

puts '***Gnome panel test'
test_gnome_panel
expect_equal(@gnome_fixtures, @gnome_outputs)

puts '***Pluralsight panel test'
test_pluralsight_panel
expect_equal(@pluralsight_fixtures, @pluralsight_outputs)

puts '***Trello panel test'
test_trello_panel
expect_equal(@trello_fixtures, @trello_outputs)

puts '***Vimium panel test'
test_vimium_panel
expect_equal(@vimium_fixtures, @vimium_outputs)
