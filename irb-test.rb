#!/usr/bin/env ruby

require 'command-monkey'

irb = CommandMonkey.new('irb', /irb.*>/)
def irb.filter_output(text)
  super(text).sub(/\A=> /m, '')
end

p irb.command('1+3')
p irb.command('"a".upcase')

