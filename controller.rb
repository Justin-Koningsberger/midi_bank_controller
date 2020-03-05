class Controller
  attr_reader :chrome_state, :testing

  PANEL = %w{chrome}

  def initialize(testing:)
    @lock = Mutex.new
    @testing = testing
    @chrome_state = :pages
  end

  def process value
    begin
      #binding.pry
      chrome_panel(value)
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def chrome_panel value
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
          started_at = Time.now.to_f
          result = 'result: '
          while @lock.locked?
            repeat_interval = 0.5
            repeat_threshold = 0.99
            long_press = (Time.now.to_f - started_at) > repeat_threshold
            sleep long_press ? repeat_interval : 0.1
            if long_press
              result += ", #{xdo_key 'Up'}"
            end
          end
          if (Time.now.to_f - started_at) <= repeat_threshold
            result += ", #{xdo_key 'Page_Up'}"
          end
          result
        end
        :started_thread
      when 4
        @lock.unlock
        @thr.value
      when 5
        xdo_key "Page_Down"
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
    `DISPLAY=':0.0' xdotool #{str}`
    "xdotool #{str}"
  end
end
