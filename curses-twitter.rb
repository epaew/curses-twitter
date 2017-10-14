#!/usr/bin/env ruby
# -*- coding:utf-8 -*-
#

## Require Libraries
require 'curses'
require_relative 'lib/display-window'
require_relative 'lib/status-window'
require_relative 'lib/tweet-window'
require_relative 'lib/main-handler'

## Create Curses Windows
Curses.init_screen
Curses.cbreak
Curses.noecho      # disable stdout, stderr
Curses.start_color # enable coloring
Curses.use_default_colors

# As an extension, ncurses allows you to set color pair 0
# via the assume_default_colors routine,
# or to specify the use of default colors (color number -1)
# if you first invoke the use_default_colors routine.
Curses.init_pair(Curses::COLOR_GREEN, Curses::COLOR_GREEN, -1)

wins = Hash.new
wins[:default] = Curses.stdscr # standard screen
wins[:display] = DisplayWindow.new(wins[:default])
wins[:status] = StatusWindow.new(wins[:default])
wins[:tweet] = TweetWindow.new(wins[:default])

wins[:default].keypad(true) # enable KEYPAD
wins[:default].setpos(1,0)

## start Streaming Thread
Core.instance.streaming_start(wins)

## handle input keys
handler = MainHandler.new
loop do
  ch = Curses.getch
  begin
    handler = handler.execute(wins, ch)
  rescue => e
    Curses.close_screen
    puts e.backtrace unless e.message == "exit program"
    break
  end
end
