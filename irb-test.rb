#!/usr/bin/env ruby

require 'command-monkey'

irb = CommandMonkey.new('irb', /irb.*>/)
p irb.command('1+3')
p irb.command('"a".upcase')

