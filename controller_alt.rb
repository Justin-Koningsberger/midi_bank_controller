class Choice
  attr_writer :controller
  def initialize controller
    @controller = controller
    @last_keys = nil
    @actions = [:root,[
      [:f_curr_tab, :f_curr_tab],
      [:f_new_tab, :f_new_tab],
      [:big_hotel, 'H'],
      [:return, Proc.new{@controller.xdo_key('Return')}],
      [:page_down, Proc.new{@controller.xdo_key('Page_Down')}],

      [:prevtab, Proc.new{@controller.xdo_key('Control_L+Shift_L+Tab')}],
      [:nexttab, Proc.new{@controller.xdo_key('Control_L+Tab')}],
      [:closetab, Proc.new{@controller.xdo_key('Control_L+F4')}],

      # [:shell, [
      #   [:cd,[
      #     [:cd, 'cd '],
      #     [:infrastructure, 'cd ~/code/infrastructure'],
      #     [:rd, 'cd ~/code/redistributor']
      #   ]],
      #   [:entr,'find | entr ruby '],
      #   [:ansible, [
      #     [:ap_diff, 'ansible-playbook site.yml -i hosts --check --diff '],
      #     [:ap_diff_tag, 'ansible-playbook site.yml -i hosts --check --diff -t  '],
      #     [:ap_diff_tag_tmp, 'ansible-playbook site.yml -i hosts --check --diff -t tmp '],
      #     [:ap, 'ansible-playbook site.yml -i hosts '],
      #     [:ap_tag, 'ansible-playbook site.yml -i hosts -t  '],
      #     [:ap_tag_tmp, 'ansible-playbook site.yml -i hosts -t tmp ']
      #   ]]
      # ]],
      # [:vim, [
      #   [:vnew, ':vnew .'],
      #   [:silk, 'V'],
      #   [:sulk, Proc.new {@controller.xdo_key 'Control_L+v'}],
      #   [:w, ':w'],
      #   [:shift_right, '>'],
      #   [:shift_left, '<'],
      #   [:repeat, '.'],
      #   [:yank, 'y'],
      #   [:x, 'x'],
      #   [:p, 'p']
      # ]],
      # [:conversate, [
      #   [:hi, 'hi'],
      #   [:ok, 'ok'],
      #   [:cool, 'cool'],
      #   [:exclaim, '!']
      # ]],
      [:escape, Proc.new{@controller.xdo_key('Escape')}],
      [:page_up, Proc.new{@controller.xdo_key('Page_Up')}]
    ]]
    @current_path = []
    display_choices
  end

  def f_curr_tab value, new_tab=false
    characters = [[nil], ('a'..'z')].map(&:to_a).flatten
    if @last_keys == nil
      File.open('choices','w') do |f|
        (1..26).each {|i| f.puts "#{i.to_s.rjust(2,'0')}) #{characters[i]}"}
      end
      @last_keys = []
      @controller.xdo_key new_tab ? 'F' : 'f'
    elsif @last_keys.size < 3
      @last_keys << value % 10
      puts @last_keys.inspect
    else
      @last_keys << value % 10
      puts @last_keys.inspect
      keys = ["#{@last_keys[0]}#{@last_keys[1]}","#{@last_keys[2]}#{@last_keys[3]}"].map(&:to_i)
      @controller.xdo_type keys.map {|n| characters[n] }.join
      @last_keys = nil
      @current_path = []
      display_choices
    end
  end

  def f_new_tab value
    f_curr_tab(value, true)
  end

  def choose value
    pp current_action
    @current_path = [] unless current_action
    if current_action.last.is_a?(Array)
      @current_path << value - 1
      @current_path = [] unless current_action
      return display_choices if current_action.last.is_a?(Array)
    end
    if current_action.last.is_a?(Symbol)
      send current_action.last, value
      return
    elsif current_action.last.is_a?(String)
      @controller.xdo_type current_action.last
    elsif current_action.last.is_a?(Proc)
      instance_eval &current_action.last
    end
    @current_path = []
    display_choices
  end

  def current_action 
    tmp = @actions
    @current_path.each do |i|
      tmp = tmp.last[i]
      break unless tmp
    end
    tmp
  end

  def display_choices str=nil
    File.open('choices','w') do |f|
      f.puts str if str
      current_action.last.each_with_index do |n,i|
        f.puts "#{i+1}) #{n.first.to_s}"
      end
    end
  end

  def test
    @controller.xdo_type 'test'
    @current_path = []
  end


    
end

class Controller
  attr_reader :last_input, :blacklist

  BANKS = %w{gnome vim thunderbird misc pluralsight nil eviacam trello thunderbird choice}
  DIRECTIONS = [nil, 'left', 'down', 'right', nil, nil, 'up']

  def initialize
    @last_input = Time.now.to_f
    #@blacklist = ['w', 'number mode on', 'b', 'k', 'j', 'Up', 'Down', 'Page_Down', 'Page_Up'].flatten.map {|n| "xdotool key #{n}"}
    @blacklist = ['w', 'number mode on', 'b', 'k', 'j', 'Up', 'Down'].flatten.map {|n| "xdotool key #{n}"}
    @choice = Choice.new(self)
  end

  def process bank_index, value
    bank = BANKS[bank_index]
    if bank != 'choice'''
      @choice.controller = nil
      @choice = Choice.new(self)
    end
    puts "bank #{bank || bank_index}, value #{value}"
    begin
      result = send(:"#{bank}_bank", value) || 'command not found'
      @last_input = Time.now.to_f unless blacklist.include?(result)
      puts result
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def choice_bank value
    @choice.choose value
  end

  # {Thunderbird: :thunderbird, virtual: :VirtualBox, slack: :slack, sublime: :sublime, terminal: :terminal, browser: :chromium}.each do |name, program|
  #     common << [
  #       "switch to #{name}",
  #       /^ ?(switch to|pick) #{name}$/,
  #       Proc.new { xdotool("search --onlyvisible #{program} windowactivate") }
  #     ]
  # end
  GNOME_WINDOWS = [nil, nil, :VirtualBox, :chromium, :terminal, :Firefox, :thunderbird, :sublime, :slack, :TeamViewer]

  def gnome_bank value
    if value == 1
      xdo_key "Return"
    else
      program = GNOME_WINDOWS[value]
      if program == :tjkbkjhjhkjerminal
        xdotool("search --onlyvisible #{program} | shuf | tail -n1 | xargs xdotool windowactivate ")
      else
        xdotool("search --onlyvisible #{program} windowactivate")
      end
    end
  end

  WMII_TAGS = [nil, nil,nil,nil,1,2,nil,3, 4,5]
  
  # This bank is removed at the moment, re-add it by replacing 'gnome' with 'wmii' in the BANKS constant
  def wmii_bank value
    if direction = DIRECTIONS[value]
      wmiir "/tag/sel/ctl select #{direction}"
    elsif tag = WMII_TAGS[value]
      wmiir("/ctl view \"#{tag}\"")
    else
      @wmii_toggle ||= false
      @wmii_toggle = !@wmii_toggle
      if @wmii_toggle
        wmiir('/tag/sel/ctl colmode sel default-max')
      else
        wmiir('/tag/sel/ctl colmode sel stack-max')
      end
    end
  end

  CHROMIUM_KEYS = [nil, nil, 'Return', 'Right', 'Down', 'Page_Down', 'Tab', 'Escape', 'H', 'Up', 'Page_Up']
  def chromium_bank value
    if @ascii_buffer
      @ascii_buffer << (value == 10 ? 0 : value)
      
      if @ascii_buffer.size == 2
        index = @ascii_buffer.map(&:to_s).join.to_i
        if @first_key_pressed
          @ascii_buffer = nil
        else
          @ascii_buffer = []
          @first_key_pressed = true
        end
        puts index

        character = ('a'..'z').to_a[index % 30]
        character.upcase! if index > 29
        xdo_key character unless index == 99
      else
        "#{@ascii_buffer.last} added to buffer"
      end
    else
      if value == 1
        xdo_key 'F' 
        @ascii_buffer = []
        @first_key_pressed = false
        'created buffer'
      else key = CHROMIUM_KEYS[value]
        xdo_key key
      end
    end
  end

  EVIACAM_KEYS = [
    nil, 
    nil,
    nil,
    nil,
    'Down',
    'space',
    nil, 
    'F10', 
    nil,
    'Up',
    'Page_Up'
  ]
  SCROLL_WAIT = {3 => 1, 4 => 0.4, 5 => 0.1, 6 => 0.05}
  def eviacam_bank value
    if key = EVIACAM_KEYS[value]
      xdo_key key
    elsif value == 1
      xdotool "click 1"
    elsif value == 2
      xdotool "click --repeat 2 1"
    elsif value == 3
      xdotool "click 3"
    elsif  value == 6
      if @scroller&.alive?
        @kill_scroller = true
      else
        @kill_scroller = false
        @scroller = Thread.new do
          res_y = `xdpyinfo`.scan(/(\d+)x(\d+) pixels/).flatten.map(&:to_i).last
          last_scroll = Time.now.to_f
          while !@kill_scroller
            sleep 0.05
            location = `xdotool getmouselocation`.scan(/ y:(\d+) /).flatten.first.to_f
            location = location / res_y
            location = location * 16 - 8

            if location.abs.to_i > 2 && location.abs.to_i < 7
              since_last_scroll = Time.now.to_f - last_scroll

              if since_last_scroll > SCROLL_WAIT[location.abs.to_i]
                xdotool "click #{location.abs != location ? 4 : 5}"
                last_scroll = Time.now.to_f
              end
            end
          end
        end
      end
    end
  end

  THUNDERBIRD_KEYS = [
    nil, 
    nil,
    'Menu+k+u',
    'Control_L+F6',
    'Down',
    'Page_Down',
    'Control_L+Shift_L+Tab', 
    'Control_L+Tab', 
    'Control_L+F4',
    'Up',
    'Page_Up'
  ]
  def thunderbird_bank value
 
    if value == 1
      curr = `DISPLAY=':0.0' xdotool getwindowfocus getwindowname`
      puts curr.inspect
      if !curr.include?(" - Mozilla Firefox\n")
        xdo_key "Return"
      else
        xdo_key "Control_L+Alt_L+r"
      end
    else
      xdo_key THUNDERBIRD_KEYS[value]
    end
  end

  TRELLO_KEYS = [
    nil, 
    'Left',
    'Down',
    'Right',
    'Return',
    'Page_Down',
    'l', 
    'Up', 
    '7',
    'Escape',
    'Page_Up'
  ]
  def trello_bank value
    xdo_key TRELLO_KEYS[value]
  end

  PLURALSIGHT_KEYS = [
    nil, 
    'Left',
    'Down',
    'Right',
    'space',
    'f',
    'l', 
    'Up', 
    '7',
    'Escape',
    'Page_Up'
  ]
  def pluralsight_bank value
    xdo_key PLURALSIGHT_KEYS[value]
  end

  MISC_KEYS = [ 
    nil,
    'Left',
    'j',
    'Right',
    'w',
    'Page_Down',
    'k',
    'b',
    'Return',
    nil,
    'Page_Up'
  ]
  def misc_bank value
    if MISC_KEYS[value] == 'b'
      xdo_type 'dd'
    else
      xdo_key MISC_KEYS[value]
    end
  end

  VIM_KEYS = [
    nil,
    'Control_L+h',
    'j',
    'Control_L+l',
    'w',
    'Page_Down',
    'k',
    'b',
    'Return',
    nil,
    'Page_Up'
  ]
  def vim_bank value
    if @number
      @number = false
      xdo_key value.to_s
    else
      if key = VIM_KEYS[value]
        xdo_key key
      #elsif [4, 7].include? value
      #  xdo_type(value == 4 ? ':vnew .' : ':q')
      #  xdo_key 'Return'
      else
        @number = true
        'number mode on'
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
    `DISPLAY=':0.0' xdotool key #{key}`
    "xdotool key #{key}"
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
