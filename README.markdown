# Command Monkey

## Overview

Command Monkey is a Ruby library to work with interactive command-reply
programs. Such programs display a prompt to the user, expect command input, and
display a reply, followed by the prompt again. For example, irb and pacmd.

Command Monkey provides an interface to such programs, so you can call a Ruby
method to send a command and get its reply as the return value. It keeps the
program running in the background, so your own program can do what it needs,
and call commands at any time.


## Synopsis

    require 'command-monkey'

    # Run the program 'irb', whose prompts match /irb.*>/
    irb = CommandMonkey.new('irb', /irb.*>/)

    # Strip '=> ' from irb's output before returning them
    def irb.filter_output(text)
      super(text).sub(/\A=> /m, '')
    end

    irb.command('1+3') #=> "4"
    irb.command('"a".upcase') #=> "A"

## Requirement

Command Monkey currently uses Revactor, which is available through RubyGems,
but only for Ruby 1.9+. I was originally using Thread, but I was unable to
debug the library that way.

## Status

Currently Command Monkey works, as tested with irb and pacmd. The output
strings are unstripped; it may change in the future and may add a mechanism to
control stripping and other filtering.

