# frozen_string_literal: true

class Controller
  attr_reader :chrome_state, :testing

  def initialize(testing:)
    @lock = Mutex.new
    @testing = testing
    @chrome_state = :pages
    @pluralsight_state = :navigate
    @vimium_state = :browse
    @number_string = ''
    @kill_scroller = false
    @pause_scroller = true
    @intervals = [-0.1, -0.25, -0.5, -1, -2, -3, 0, 3, 2, 1, 0.5, 0.25, 0.1]
    @scroll_speed = 6
    Thread.abort_on_exception = true
  end

  def process(value)
    if (0..6).cover?(value)
      @vimium_state = :browse
      chrome_panel(value)
    elsif (7..14).cover?(value)
      @vimium_state = :browse
      gnome_panel(value)
    elsif (15..19).cover?(value)
      @vimium_state = :browse
      pluralsight_panel(value)
    elsif (20..25).cover?(value)
      @vimium_state = :browse
      emailreader_panel(value)
    elsif (26..32).cover?(value)
      vimium_panel(value)
    elsif (33..40).cover?(value)
      @vimium_state = :browse
      trello_panel(value)
    elsif (41..44).cover?(value)
      @vimium_state = :browse
      scrolling_panel(value)
    end
  end

  def chrome_panel(value)
    if value == 0 # button 1
      puts 'Pages' if @testing
      @chrome_state = :pages
    elsif value == 1 # button 1
      puts 'Tabs' if @testing
      @chrome_state = :tabs
    elsif @chrome_state == :pages
      case value
      when 2 # button 2
        xdo_key 'Control_L+Alt_L+r'
      when 3 # button 3
        setup_thread { long_press('xdo_key', 'Page_Up', 'xdo_key', 'Up', 0.5) }
      when 4 # button 3
        finish_thread
      when 5 # button 4
        setup_thread { long_press('xdo_key', 'Page_Down', 'xdo_key', 'Down', 0.5) }
      when 6 # button 4
        finish_thread
      end
    elsif @chrome_state == :tabs
      case value
      when 2
        xdo_key 'Control_L+Shift_L+Tab'
      when 3
        xdo_key 'Control_L+Tab'
      when 5
        xdo_key 'Control_L+F4'
      end
    end
  end

  def emailreader_panel(value)
    value -= 20

    case value
    when 0 # button 1
      xdo_key 'Left'
    when 1 # button 2
      xdo_key 'Return'
    when 2 # button 3
      setup_thread { long_press('xdo_key', 'Up', 'xdo_key', 'Page_Up', 0.5) }
    when 3 # button 3
      finish_thread
    when 4 # button 4
      setup_thread { long_press('xdo_key', 'Down', 'xdo_key', 'Page_Down', 0.5) }
    when 5 # button 4
      finish_thread
    end
  end

  GNOME_WINDOWS = [nil, :VirtualBox, :chromium, :terminal, :Firefox, :thunderbird, :sublime, :slack].freeze

  def gnome_panel(value)
    value -= 7 # align value with GNOME_WINDOWS

    case value
    when 0 # button 1
      setup_thread { long_press('xdo_key', 'Return', 'activate_window', GNOME_WINDOWS[value + 1], 0.9) }
    when 1 # button 1
      finish_thread
    when 2 # button 2
      setup_thread { long_press('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.9) }
    when 3 # button 2
      finish_thread
    when 4 # button 3
      setup_thread { long_press('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.9) }
    when 5 # button 3
      finish_thread
    when 6 # button 4
      setup_thread { long_press('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.9) }
    when 7 # button 4
      finish_thread
    end
  end

  def pluralsight_panel(value)
    value -= 15

    if value == 0 # button 1
      puts 'Navigate' if @testing
      @pluralsight_state = :navigate
    elsif value == 1 # button 1
      puts 'Alt state' if @testing
      @pluralsight_state = :alt_state
    elsif @pluralsight_state == :navigate
      case value
      when 2 # button 2
        xdo_key 'Left'
      when 3 # button 3
        xdo_key 'KP_Space'
      when 4 # button 4
        xdo_key 'Right'
      end
    elsif @pluralsight_state == :alt_state
      case value
      when 2 # button 2
        xdo_key 'f'
      when 3 # button 3
        xdo_key 'Return'
      when 4 # button 4
        puts 'This button is not used in alt state'
      end
    end
  end

  def scrolling_panel(value)
    setup_thread { scrolling } unless @lock.locked?

    value -= 41

    case value
    when 0 # button 1, down, increase scrolling
      @pause_scroller = false
      @scroll_speed -= 1 unless @scroll_speed == 0
      "scroll vec: #{@intervals[@scroll_speed]}"
    when 1 # button 2, up, decrease scrolling
      @pause_scroller = false
      @scroll_speed += 1 unless @scroll_speed == @intervals.size - 1
      "scroll vec: #{@intervals[@scroll_speed]}"
    when 2 # button 3, pause
      @pause_scroller = !@pause_scroller
      "pause_scroller is #{@pause_scroller}"
    when 3 # button 4, reset
      @scroll_speed = 6
      @kill_scroller = true
      @pause_scroller = true
      finish_thread
      @kill_scroller = false
      'scroll thread reset'
    end
  end

  def trello_panel(value)
    value -= 33

    case value
    when 0 # button 1
      setup_thread { extra_long_press('xdo_key', 'Left', 'Return', 'l', 1.0) }
    when 1 # button 1
      finish_thread
    when 2 # button 2
      setup_thread { extra_long_press('xdo_key', 'Down', 'Page_Down', '7', 1.0) }
    when 3 # button 2
      finish_thread
    when 4 # button 3
      setup_thread { long_press('xdo_key', 'Up', 'xdo_key', 'Page_Up', 1.0) }
    when 5 # button 3
      finish_thread
    when 6 # button 4
      setup_thread { long_press('xdo_key', 'Right', 'xdo_key', 'Escape', 1.0) }
    when 7 # button 4
      finish_thread
    end
  end

  def vimium_panel(value)
    value -= 26
    result = ''

    if @vimium_state == :browse
      @number_string = ''
      case value
      when 1 # button 1
        puts 'Enter numbers now' if @testing
        @vimium_state = :get_four_numbers
        xdo_key 'f'
      when 3 # button 2
        puts 'Enter numbers now' if @testing
        @vimium_state = :get_four_numbers
        xdo_key 'F'
      when 5 # button 3
        xdo_key 'H'
      end

    elsif @vimium_state == :get_four_numbers
      case value
      when 0 # button 1
        result = setup_thread { extra_long_press(nil, '1', '2', '3', 1.0) }
      when 1 # button 1
        result = finish_thread
        @number_string += result
      when 2 # button 2
        result = setup_thread { extra_long_press(nil, '4', '5', '6', 1.0) }
      when 3 # button 2
        result = finish_thread
        @number_string += result
      when 4 # button 3
        result = setup_thread { extra_long_press(nil, '7', '7', '9', 1.0) }
      when 5 # button 3
        result = finish_thread
        @number_string += result
      when 6 # button 4
        result = '0'
        @number_string += result
      end

      process_numbers(@number_string) if @number_string.size == 4
      result
    end
  end

  def long_press(command_s, short, command_l, long, repeat_interval)
    started_at = Time.now.to_f
    result = 'result: '
    repeat_threshold = 0.99
    while @lock.locked?
      long_press = (Time.now.to_f - started_at) > repeat_threshold
      sleep long_press ? repeat_interval : 0.1
      result += " #{send command_l, long}" if long_press
    end
    if (Time.now.to_f - started_at) <= repeat_threshold
      result += " #{send command_s, short}"
    end
    result
  end

  def extra_long_press(command, short, long, extra_long, switch_interval)
    started_at = Time.now.to_f
    result = ''
    repeat_threshold = 0.99
    while @lock.locked?
      long_press = (Time.now.to_f - started_at) >= switch_interval
      extra_long_press = (Time.now.to_f - started_at) >= (switch_interval * 2)
      sleep long_press ? switch_interval : 0.1
      result = long if long_press
      result = extra_long if extra_long_press
    end
    result = short if (Time.now.to_f - started_at) <= repeat_threshold
    result = send command, result unless command.nil?
    result
  end

  def scrolling
    last_scroll = Time.now.to_f
    until @kill_scroller
      next if @pause_scroller

      sleep 0.05

      since_last_scroll = Time.now.to_f - last_scroll
      vec = @intervals[@scroll_speed] # scroll speed and direction
      puts vec
      if since_last_scroll > vec.abs
        xdotool("click #{vec.positive? ? 4 : 5}")
        last_scroll = Time.now.to_f
      end
    end
  end

  def setup_thread
    @lock.lock
    @thr = Thread.new do |_thread|
      yield
    end
    :started_thread
  end

  def finish_thread
    @lock.unlock
    @thr.value
  end

  def process_numbers(string)
    puts "*********  #{string}  ********" if @testing
    if string[0, 2] == '00'
      letter = convert(string[2, 4].to_i)
      xdo_key(letter)
    else
      one = convert(string[0, 2].to_i)
      two = convert(string[2, 4].to_i)
      xdo_key(one + two)
    end
    @vimium_state = :browse
  end

  def convert(integer)
    unless (0o1..26).cover? integer
      raise 'This number lies outside the alphabet'
    end

    integer += 64 # get in capital range, 65 == 'A'
    integer.chr
  end

  def activate_window(program)
    xdotool("search --onlyvisible --class --classname --name #{program} windowactivate")
  end

  def xdo_key(key)
    case @testing
    when false
      `DISPLAY=':0.0' xdotool key #{key}`
      "xdotool key #{key}"
    when true
      puts "xdotool key #{key}"
      "xdotool key #{key}"
    end
  end

  def xdotool(str)
    case @testing
    when false
      `DISPLAY=':0.0' xdotool #{str}`
      "xdotool #{str}"
    when true
      puts "xdotool #{str}"
      "xdotool #{str}"
    end
  end
end
