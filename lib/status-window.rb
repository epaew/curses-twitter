# -*- coding:utf-8 -*-
#

require 'curses'

class StatusWindow
  def initialize(win)
    @position = win.maxy - 2
    @r_string = "timeline"
    @window = win.subwin(1, win.maxx, @position, 0)

    self.display()
  end

  def resize(win)
    @position = win.maxy - 2
    @window = win.subwin(1, win.maxx, @position, 0)
    self.display()
  end

  def display(str = "", r_str = nil)
    @window.setpos(0,0)
    @window.standout
    @window.addstr(" " * @window.maxx)
    @window.standend

    if str.length > 0
      @window.setpos(0,0)
      @window.addstr(str)
      @window.refresh
    end
    if r_str
      display_right(r_str.to_s)
    else
      display_right()
    end
  end

  private
  def display_right(str = @r_string)
    @r_string = str

    @window.setpos(0, @window.maxx - str.length - 1)
    @window.addstr(str)
    @window.refresh
  end
end
