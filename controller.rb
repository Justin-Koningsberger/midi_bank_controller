class Controller
  attr_reader :chrome_state, :testing

  PANEL = %w[chrome].freeze

  def initialize(testing:)
    @lock = Mutex.new
    @testing = testing
    @chrome_state = :pages
    @pluralsight_state = :navigate
    @vimium_state = :browse
    @number_string = ''
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
    end
  end

  def chrome_panel(value)
    if value == 0 # button 1
      puts 'Pages'
      @chrome_state = :pages
    elsif value == 1 # button 1
      puts 'Tabs'
      @chrome_state = :tabs
    elsif @chrome_state == :pages
      case value
      when 2 # button 2
        xdo_key 'Control_L+Alt_L+r'
      when 3 # button 3
        setup_lp_thread('xdo_key', 'Page_Up', 'xdo_key', 'Up', 0.5)
        :started_thread
      when 4 # button 3
        @lock.unlock
        @thr.value
      when 5 # button 4
        setup_lp_thread('xdo_key', 'Page_Down', 'xdo_key', 'Down', 0.5)
        :started_thread
      when 6 # button 4
        @lock.unlock
        @thr.value
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
      setup_lp_thread('xdo_key', 'Down', 'xdo_key', 'Page_Down', 0.5)
      :started_thread
    when 3 # button 3
      @lock.unlock
      @thr.value
    when 4 # button 4
      setup_lp_thread('xdo_key', 'Up', 'xdo_key', 'Page_Up', 0.5)
      :started_thread
    when 5 # button 4
      @lock.unlock
      @thr.value
    end
  end

  GNOME_WINDOWS = [nil, :VirtualBox, :chromium, :terminal, :Firefox, :thunderbird, :sublime, :slack].freeze

  def gnome_panel(value)
    value -= 7 # align value with GNOME_WINDOWS

    case value
    when 0 # button 1
      setup_lp_thread('xdo_key', 'Return', 'activate_window', GNOME_WINDOWS[value + 1], 0.9)
      :started_thread
    when 1 # button 1
      @lock.unlock
      @thr.value
    when 2 # button 2
      setup_lp_thread('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.9)
      :started_thread
    when 3 # button 2
      @lock.unlock
      @thr.value
    when 4 # button 3
      setup_lp_thread('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.9)
      :started_thread
    when 5 # button 3
      @lock.unlock
      @thr.value
    when 6 # button 4
      setup_lp_thread('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.9)
      :started_thread
    when 7 # button 4
      @lock.unlock
      @thr.value
    end
  end

  def pluralsight_panel(value)
    value -= 15

    if value == 0 # button 1
      puts 'Navigate'
      @pluralsight_state = :navigate
    elsif value == 1 # button 1
      puts 'Alt state'
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

  def vimium_panel(value)
    value -= 26

    if @vimium_state == :browse
      @number_string = ''
      case value
      when 1
        puts 'Enter numbers now'
        @vimium_state = :get_four_numbers
        xdo_key 'f'
      when 3
        puts 'Enter numbers now'
        @vimium_state = :get_four_numbers
        xdo_key 'F'
      when 5
        puts 'Enter numbers now'
        @vimium_state = :get_four_numbers
        xdo_key 'H'
      end

    elsif @vimium_state == :get_four_numbers
      case value
      when 0 # button 1
        setup_elp_thread('1', '2', '3', 1.0)
        :started_thread
      when 1 # button 1
        @lock.unlock
        @number_string += @thr.value
        puts @thr.value
      when 2 # button 2
        setup_elp_thread('4', '5', '6', 1.0)
        :started_thread
      when 3 # button 2
        @lock.unlock
        @number_string += @thr.value
        puts @thr.value
      when 4 # button 3
        setup_elp_thread('7', '8', '9', 1.0)
        :started_thread
      when 5 # button 3
        @lock.unlock
        @number_string += @thr.value
        puts @thr.value
      when 6 # button 4
        @number_string += '0'
        puts '0'
      end

      if @number_string.size == 4
        process_numbers(@number_string)
      end
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

  def extra_long_press(short, long, extra_long, switch_interval)
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
    if (Time.now.to_f - started_at) <= repeat_threshold
      result = short
    end
    result
  end

  def setup_lp_thread(command_s, short, command_l, long, interval)
    return 'Waiting for key up' if @lock.locked?
    @lock.lock
    Thread.abort_on_exception = true
    @thr = Thread.new do |_thread|
      long_press(command_s, short, command_l, long, interval)
    end
  end

  def setup_elp_thread(short, long, extra_long, interval)
    return 'Waiting for key up' if @lock.locked?
    @lock.lock
    Thread.abort_on_exception = true
    @thr = Thread.new do |_thread|
      extra_long_press(short, long, extra_long, interval)
    end
  end

  def process_numbers(string)
    puts "*********  #{string}  ********"
    if string[0,2] == '00'
      letter = convert(string[2,4].to_i)
      xdo_key(letter)
    else
      letter_one = convert(string[0,2].to_i)
      letter_two = convert(string[2,4].to_i)
      xdo_key(letter_one)
      sleep 0.1
      xdo_key(letter_two)
    end
    @vimium_state = :browse
  end

  def convert(integer)
    raise 'This number lies outside the alphabet' unless (01..26).cover? integer

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
