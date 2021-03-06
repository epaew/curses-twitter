# -*- coding:utf-8 -*-
#

require_relative 'core'

class DisplayWindow

  LEFT_OFFSET = 6

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
    max_width = @window.maxx - LEFT_OFFSET

    string.each_char.with_index do |ch, idx|
      if ch == "\n"
        count = 0
      else
        count += ch.ascii_only? ? 1 : 2
      end

      if count >= max_width
        string.insert(idx, "\n")
        count = 0
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

    has_profile = @mode.to_s =~ /^@.*/ &&
      @cursor_num == @str_array.length - 1

    # print header
    line_idx = 1
    if @cursor_num < @str_array.length - 1 then
      @window.addstr("Newer tweets are available.")
    else
      @window.addstr("")
    end

    # print tweets on window
    @str_array[0..@cursor_num].reverse_each do |tw_str|
      self.split_screen_width(tw_str).each_with_index do |line, idx_in_tw|

        if idx_in_tw == 0 && !has_profile then
          @window.setpos(line_idx, 0)
          @window.attron(Curses.color_pair(Curses::COLOR_GREEN))
        elsif has_profile then
          @window.setpos(line_idx, 0)
        else
          @window.setpos(line_idx, LEFT_OFFSET)
        end

        @window.addstr(line)

        if idx_in_tw == 0 then
          @window.attroff(Curses.color_pair(Curses::COLOR_GREEN))
        end

        break if (line_idx += 1) >= @window.maxy
      end

      has_profile = false
      break if line_idx >= @window.maxy
    end
    @window.setpos(1,0)
    @window.refresh
  end

  def update()
    msg = Core.instance.update(@mode)
    display()
    return msg
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

  def up_cursor(num = nil)
    if num then
      num.to_i.times do
        up_cursor()
      end
    else
      @cursor_num += 1 if @cursor_num < @str_array.length - 1
      self.display()
    end
  end

  def down_cursor(num = nil)
    if num then
      num.to_i.times do
        down_cursor()
      end
    else
      @cursor_num -= 1 if @cursor_num > 0
      self.display()
    end
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
