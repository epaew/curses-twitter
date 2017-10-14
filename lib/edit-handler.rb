# -*- coding:utf-8 -*-

require 'curses'
require_relative 'handler'
require_relative 'main-handler'

class EditHandler < Handler
  def initialize(wins, tweet_number = nil)
    @buf = ""
    wins[:tweet].init_reply(wins[:display].mode,
                            tweet_number) if tweet_number
    wins[:tweet].display()

    message = "Edit Buffer."
    if id = wins[:tweet].check_in_reply_to()
      message += "(in_reply_to #{id})"
    end
    wins[:status].display(message)
  end

  def execute(wins, input_ch)
    case input_ch
    when Curses::Key::RESIZE then
      self.resize(wins)
    when 27 then
      # escape
      wins[:status].display()
      wins[:tweet].check_in_reply_to()
      return MainHandler.new
    when 127, Curses::Key::BACKSPACE then
      # backspace
      wins[:tweet].buffer_delete()
    when Fixnum then
      # nothing to do
    else
      if input_ch.class == String
        wins[:tweet].buffer_add(input_ch)
      else
        @buf += input_ch.chr
        if @buf.length == 3
          wins[:tweet].buffer_add(@buf.unpack("U*")[0].chr("UTF-8"))
          @buf = ""
        end
      end
    end
    return self
  end
end
