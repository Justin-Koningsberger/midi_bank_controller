class Controller
  attr_reader :chrome_state, :testing

  PANEL = %w{chrome}

  def initialize(testing:)
    @lock = Mutex.new
    @testing = testing
    @chrome_state = :pages
  end

  def process value
    if (0..6) === value
      chrome_bank(value)
    elsif (7..14) === value
      gnome_bank(value)
    end
  end

  def chrome_bank value
    if value == 0
      puts 'Pages'
      @chrome_state = :pages
    elsif value == 1
      puts 'Tabs'
      @chrome_state = :tabs
    elsif @chrome_state == :pages
      case value
      when 2
        xdo_key "Control_L+Alt_L+r"
      when 3
        return "Waiting for key up" if @lock.locked?
        @lock.lock
        Thread.abort_on_exception = true
        @thr = Thread.new do |thread|
          long_press('Up', 'Page_Up')
        end
        :started_thread
      when 4
        @lock.unlock
        @thr.value
      when 5
        return "Waiting for key up" if @lock.locked?
        @lock.lock
        Thread.abort_on_exception = true
        @thr = Thread.new do |thread|
          long_press('Down', 'Page_Down')
        end
        :started_thread
      when 6
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

  GNOME_WINDOWS = [nil, :VirtualBox, :chromium, :terminal, :Firefox, :thunderbird, :sublime, :slack]

  def gnome_bank value
    value -= 7 # align value with GNOME_WINDOWS

    case value
    when 0
      return "Waiting for key up" if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |thread|
        started_at = Time.now.to_f
        repeat_threshold = 0.99
        result = ''
        while @lock.locked?
          long_press = (Time.now.to_f - started_at) > repeat_threshold
          sleep 0.2 if long_press
          if long_press
            result = "#{activate_window("#{GNOME_WINDOWS[value + 1]}")}"
          end
        end
        if (Time.now.to_f - started_at) <= repeat_threshold
          result = "#{xdo_key 'Return'}"
        end
        result
      end
      :started_thread
    when 1
      @lock.unlock
      @thr.value
    when 2
      return "Waiting for key up" if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |thread|
        long_press_activate_window(GNOME_WINDOWS[value], GNOME_WINDOWS[value + 1])
      end
      :started_thread
    when 3
      @lock.unlock
      @thr.value
    when 4
      return "Waiting for key up" if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |thread|
        long_press_activate_window(GNOME_WINDOWS[value], GNOME_WINDOWS[value + 1])
      end
      :started_thread
    when 5
      @lock.unlock
      @thr.value
    when 6
      return "Waiting for key up" if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |thread|
        long_press_activate_window(GNOME_WINDOWS[value], GNOME_WINDOWS[value + 1])
      end
      :started_thread
    when 7
      @lock.unlock
      @thr.value
    end
  end

  def long_press_activate_window(window_x, window_y)
    started_at = Time.now.to_f
    result = ''
    repeat_threshold = 0.99
    while @lock.locked?
      long_press = (Time.now.to_f - started_at) > repeat_threshold
      sleep 0.2 if long_press
      if long_press
        result = "#{activate_window window_y}"
      end
    end
    if (Time.now.to_f - started_at) <= repeat_threshold
      result = "#{activate_window window_x}"
    end
    result
  end

  def long_press(short, long)
    started_at = Time.now.to_f
    result = 'result: '
    while @lock.locked?
      repeat_interval = 0.5
      repeat_threshold = 0.99
      long_press = (Time.now.to_f - started_at) > repeat_threshold
      sleep long_press ? repeat_interval : 0.1
      if long_press
        result += ", #{xdo_key short}"
      end
    end
    if (Time.now.to_f - started_at) <= repeat_threshold
      result += ", #{xdo_key long}"
    end
    result
  end

  def activate_window(program)
    xdotool("search --onlyvisible --class --classname --name #{program} windowactivate")
  end

  def _bank value
    'bank not found'
  end

  def wmiir str
    `DISPLAY=':0.0' wmiir xwrite #{str}`
    "wmiir xwrite #{str}"
  end

  def xdo_key key
    case @testing
    when false
      `DISPLAY=':0.0' xdotool key #{key}`
      "xdotool key #{key}"
    when true
      puts "xdotool key #{key}"
      "xdotool key #{key}"
    end
  end
  
  def xdo_type str
    `DISPLAY=':0.0' xdotool type '#{str}'`
    "xdotool type '#{str}'"
  end

  def xdotool str
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
