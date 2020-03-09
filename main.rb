require 'unimidi'
require 'pp'
require 'pry'

# patch
module AlsaRawMIDI
  class Input
    def gets
      sleep 0.01 until enqueued_messages?
      msgs = enqueued_messages
      @pointer = @buffer.length
      msgs
    end
  end
end

class Reader
  def initialize
    reload_controller
    @input = UniMIDI::Input.use(:first)
    start_loop
  end

  def reload_controller
    @mtime = File.mtime('controller.rb')
    load('./controller.rb')
    @controller = Controller.new(testing: false)
  end

  def start_loop
    File.open('log', 'w') do |f|
      f.sync = true
      loop do
        begin
          reload_controller unless File.mtime('controller.rb') == @mtime
        rescue SyntaxError => e
          puts e.inspect
          puts e.backtrace
        end
        data = @input.gets_data
        puts '---------------------'
        puts "\n" + data.inspect
        puts '---------------------'
        # data[0] == 192: button. data[0] == 176: wah pedal
        next unless data[0] == 176
        raw =  data[1] || 0
        f.puts raw
        puts "data: #{data}"
        @controller.process(raw)
      end
    end
  end
end

Reader.new
