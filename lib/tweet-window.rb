# -*- coding:utf-8 -*-
#

require 'curses'
require_relative 'core'

class TweetWindow
  def initialize(win)
    @cursor_x = 0
    @buf_pos = 0
    @win_pos = win.maxy - 1
    @buf = []
    @in_reply_to = nil
    @window = win.subwin(1, win.maxx, @win_pos, 0)
    @window.refresh
  end

  def resize(win)
    @win_pos = win.maxy - 1
    @window = win.subwin(1, win.maxx, @win_pos, 0)
    self.display()
  end

  def display(str = @buf.join)
    @window.clear
    @window.setpos(0, 0)
    @window.addstr(str)
    @window.setpos(0, @cursor_x)
    @window.refresh
  end

  def buffer_add(input_ch)
    input_ch.each_char do |ch|
      @buf.insert(@buf_pos, ch)
      @buf_pos += 1
      @cursor_x += ch.ascii_only? ? 1 : 2
    end
    self.display
  end

  def buffer_delete
    if @cursor_x > 0
      @buf_pos -= 1
      @cursor_x -= @buf.delete_at(@buf_pos).ascii_only? ? 1 : 2
    end
    self.display
  end

  def send_buffer
    Core.instance.send_tweet(@buf.join, @in_reply_to)
    self.clear_buffer
    self.display
  end

  def clear_buffer
    @buf = []
    @buf_pos = 0
    @cursor_x = 0
    @in_reply_to = nil
    self.display
  end

  def init_reply(mode, tweet_number)
    @in_reply_to, user = Core.instance.get_in_reply_to(mode, tweet_number)
    self.buffer_add("@" + user + " ")
    self.display
  end

  def check_in_reply_to
    @in_reply_to = nil if @buf.length == 0
    return @in_reply_to
  end
end
