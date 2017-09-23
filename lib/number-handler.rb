# -*- coding:utf-8 -*-

require 'curses'
require_relative 'handler'
require_relative 'main-handler'

class NumberHandler < Handler
  def initialize(wins, input_ch)
    @buf = input_ch
    wins[:tweet].display(@buf)
  end

  def execute(wins, input_ch)
    case input_ch
    when Curses::Key::RESIZE then
      self.resize(wins)
    when 27 then
      return MainHandler.new
    when 127, Curses::Key::BACKSPACE then
      @buf.chop!
      wins[:tweet].display(@buf)
    when /[0-9]/ then
      @buf += input_ch
      wins[:tweet].display(@buf)
      return self
    when ?f then
      # favorites the tweet of entered number
      wins[:status].display(Core.instance.favorite(wins[:display].mode,
                                                   @buf.to_i))
    when ?F then
      # unfavorites the tweet of entered number
      wins[:status].display(Core.instance.unfavorite(wins[:display].mode,
                                                     @buf.to_i))
    when ?G then
      # jump cursor to the entered number
      wins[:display].move_cursor(@buf.to_i)
    when ?r then
      # edit tweet buffer with reply
      return EditHandler.new(wins, @buf.to_i)
    when ?R then
      # retweet the tweet of entered number
      wins[:status].display("Retweet? y(es), N(o)")
      if Curses.getch == ?y
        wins[:status].display(Core.instance.retweet(wins[:display].mode,
                                                    @buf.to_i))
      end
    else
      wins[:status].display("No Executable Command!!")
      return MainHandler.new
    end

    wins[:display].display()
    wins[:tweet].display("")
    return MainHandler.new
  end
end
