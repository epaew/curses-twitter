# -*- coding:utf-8 -*-

require 'curses'

class Handler
  def execute(wins, input_ch)
    return self
  end

  def resize(wins)
    wins[:default].refresh
    wins.each do |key, win|
      win.resize(wins[:default]) unless key == :default
    end
  end
end
