# -*- coding:utf-8 -*-

require 'curses'
require_relative 'handler'
require_relative 'number-handler'
require_relative 'edit-handler'
require_relative 'command-handler'

class MainHandler < Handler
  def execute(wins, input_ch)
    # reset status message
    wins[:status].display("")

    case input_ch
    when Curses::Key::RESIZE then
      self.resize(wins)
    when /[0-9]/ then
      return NumberHandler.new(wins, input_ch)
    when ?a, ?i then # edit tweet buffer
      return EditHandler.new(wins)
    when ?G then
      # move top
      wins[:display].move_top
    when ?h, Curses::Key::LEFT then
      # move left
      # do nothing
    when ?j, Curses::Key::DOWN then
      # move down
      wins[:display].down_cursor
    when ?k, Curses::Key::UP then
      # move up
      wins[:display].up_cursor
    when ?l, Curses::Key::RIGHT then
      # move right
      # do nothing
    when ?u then
      # update timeline
      wins[:status].display(wins[:display].update())
    when ?: then
      # other command
      return CommandHandler.new(wins)
    end
    return self
  end
end
