#!/usr/bin/env ruby

require 'command-monkey'

irb = CommandMonkey.new('irb', /irb.*>/)
def irb.filter_output(text)
  super(text).sub(/\A=> /m, '')
end

p irb.enter('1+3')
p irb.enter('"a".upcase')

