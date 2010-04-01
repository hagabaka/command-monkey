#!/usr/bin/env ruby

require 'command-monkey'

pacmd = CommandMonkey.new('pacmd', />>>\s+/)
puts pacmd.send('list-sinks')

