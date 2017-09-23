# -*- coding:utf-8 -*-
#

require_relative 'core'

class DisplayWindow
  attr_reader :mode
  def maxx
    return @window.maxx
  end

  def maxy
    return @window.maxy
  end

  def initialize(win)
    @mode = :timeline
    @window = win.subwin(win.maxy - 2, win.maxx, 0, 0)
    @window.scrollok(true)

    self.display()
  end

  def resize(win)
    @window.resize(win.maxy - 2, win.maxx)
    self.display()
  end

  def split_screen_width(string)
    count = 0
    array = []
    string.each_char.with_index do |ch, idx|
      if ch == "\n"
        count = 0
      else
        count += ch.ascii_only? ? 1 : 2
      end

      if count >= @window.maxx
        string.insert(idx, "\n")
        count -= @window.maxx
      end
    end

    string.split(/\n/).each do |line|
      array.push(line)
    end
    return array
  end

  def display(array = Core.instance.get_str_array(@mode))
    @str_array = array
    @cursor_num = @str_array.length - 1 if @cursor_num == nil
    @window.clear

    # print header
    idx = 1
    if @cursor_num < @str_array.length - 1 then
      @window.addstr("Newer tweets are available.")
    else
      @window.addstr("")
    end

    # print tweets on window
    @str_array[0..@cursor_num].reverse_each do |str|
      self.split_screen_width(str).each do |line|
        @window.setpos(idx, 0)
        @window.addstr(line)
        break if (idx += 1) >= @window.maxy
      end
      break if idx >= @window.maxy
    end
    @window.setpos(1,0)
    @window.refresh
  end

  def mode_change(str)
    begin
      case str.to_sym
      when :timeline then
        Core.instance.fetch_timeline()
      when :mention then
        Core.instance.fetch_mention()
      when /^@.*/ then
        Core.instance.fetch_usertimeline(str)
      else
        str = "@" + str
        Core.instance.fetch_usertimeline(str)
      end
    rescue => e
      e.backtrace
      return "fetching #{str} failed."
    end

    @mode = str.to_sym
    @cursor_num = nil
    self.display
    return "fetched #{str}"
  end

  def up_cursor
    @cursor_num += 1 if @cursor_num < @str_array.length
    self.display()
  end

  def down_cursor
    @cursor_num -= 1 if @cursor_num > 0
    self.display()
  end

  def move_cursor(num)
    int_num = num.to_i

    if 0 > int_num then
      @cursor_num = 0
    elsif @str_array.length <= int_num then
      @cursor_num = @str_array.length - 1
    else
      @cursor_num = int_num
    end

    self.display()
  end

  def move_top
    @cursor_num = @str_array.length - 1
    self.display()
  end

end
