#!/usr/bin/env ruby

require 'command-monkey'

irb = CommandMonkey.new('irb', /irb.*>/)
puts irb.command('1+3')

