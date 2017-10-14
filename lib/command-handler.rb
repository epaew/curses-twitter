# -*- coding:utf-8 -*-

require 'curses'
require_relative 'handler'
require_relative 'main-handler'

class CommandHandler < Handler
  def initialize(wins)
    super()
    @cmd_buf = ":"
    wins[:tweet].display(@cmd_buf)
  end

  def execute(wins, input_ch)
    case input_ch
    when Curses::Key::RESIZE then
      self.resize(wins)
    when 10, Curses::Key::ENTER then
      # enter
      self.execute_command(wins)
      wins[:tweet].display("")
      return MainHandler.new
    when 27 then
      # escape
      wins[:tweet].display("")
      return MainHandler.new
    when 127, Curses::Key::BACKSPACE then
      # backspace
      @cmd_buf.chop!
    when Fixnum then
      # nothing to do
    else
      self.buffer_command(input_ch)
    end

    wins[:tweet].display(@cmd_buf)
    return self
  end

  def buffer_command(input_ch)
    @cmd_buf += input_ch.chr
  end

  def execute_command(wins)
    mode = nil
    case @cmd_buf.delete(":").to_sym
    when :tl, :timeline then
      mode = :timeline
      wins[:display].mode_change(mode)
    when :reply, :mention then
      mode = :mention
      wins[:display].mode_change(mode)
    when /^user .*$/ then
      mode = @cmd_buf.split(" ", 2)[1]
      mode = "@" + mode unless mode =~ /^@/
      wins[:display].mode_change(mode)
    when :w then
      wins[:tweet].send_buffer()
    when :q then # quit program
      raise "exit program"
    else
      wins[:status].display("No Executable Command!!")
    end

      wins[:display].display()
      wins[:status].display("", mode)
  end
end
