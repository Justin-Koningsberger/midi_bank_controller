class Controller
  attr_reader :chrome_state, :testing

  PANEL = %w[chrome].freeze

  def initialize(testing:)
    @lock = Mutex.new
    @testing = testing
    @chrome_state = :pages
  end

  def process(value)
    if (0..6).cover?(value)
      chrome_panel(value)
    elsif (7..14).cover?(value)
      gnome_panel(value)
    end
  end

  def chrome_panel(value)
    if value == 0
      puts 'Pages'
      @chrome_state = :pages
    elsif value == 1
      puts 'Tabs'
      @chrome_state = :tabs
    elsif @chrome_state == :pages
      case value
      when 2
        xdo_key 'Control_L+Alt_L+r'
      when 3
        return 'Waiting for key up' if @lock.locked?
        @lock.lock
        Thread.abort_on_exception = true
        @thr = Thread.new do |_thread|
          long_press('xdo_key', 'Up', 'xdo_key', 'Page_Up', 0.5)
        end
        :started_thread
      when 4
        @lock.unlock
        @thr.value
      when 5
        return 'Waiting for key up' if @lock.locked?
        @lock.lock
        Thread.abort_on_exception = true
        @thr = Thread.new do |_thread|
          long_press('xdo_key', 'Down', 'xdo_key', 'Page_Down', 0.5)
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

  GNOME_WINDOWS = [nil, :VirtualBox, :chromium, :terminal, :Firefox, :thunderbird, :sublime, :slack].freeze

  def gnome_panel(value)
    value -= 7 # align value with GNOME_WINDOWS

    case value
    when 0
      return 'Waiting for key up' if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |_thread|
        long_press('xdo_key', 'Return', 'activate_window', GNOME_WINDOWS[value + 1], 0.3)
      end
      :started_thread
    when 1
      @lock.unlock
      @thr.value
    when 2
      return 'Waiting for key up' if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |_thread|
        long_press('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.3)
      end
      :started_thread
    when 3
      @lock.unlock
      @thr.value
    when 4
      return 'Waiting for key up' if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |_thread|
        long_press('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.3)
      end
      :started_thread
    when 5
      @lock.unlock
      @thr.value
    when 6
      return 'Waiting for key up' if @lock.locked?
      @lock.lock
      Thread.abort_on_exception = true
      @thr = Thread.new do |_thread|
        long_press('activate_window', GNOME_WINDOWS[value], 'activate_window', GNOME_WINDOWS[value + 1], 0.3)
      end
      :started_thread
    when 7
      @lock.unlock
      @thr.value
    end
  end

  def long_press(command_s, short, command_l, long, interval)
    started_at = Time.now.to_f
    result = 'result: '
    repeat_interval = interval
    repeat_threshold = 0.99
    while @lock.locked?
      long_press = (Time.now.to_f - started_at) > repeat_threshold
      sleep long_press ? repeat_interval : 0.1
      result += " #{send command_s, short}" if long_press
    end
    if (Time.now.to_f - started_at) <= repeat_threshold
      result += " #{send command_l, long}"
    end
    result
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
