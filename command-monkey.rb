require 'pty'
require 'expect'
require 'revactor'

# This library runs an interactive program, such as pacmd or irb, and provides
# a method to execute commands in the program and return the replies.
class CommandMonkey

  # program: the interactive program to execute
  # prompt: regex detecting the interactive program's prompt
  def initialize(program, prompt)
    @library = Actor.current

    # run the program in a separate thread so that this library does not block
    # the client program
    @operator = Actor.spawn do
      PTY.spawn program do |output, input, pid|

        output.expect prompt do |text|
          puts "Launched #{program}, PID #{pid}"
          puts text
        end

        loop do
          # wait for a command request
          Actor.receive do |filter|
            filter.when Case[:command, String] do |_, text|
              # enter the command
              input.print "#{text}\n"
              puts "Sent #{text}"

              # wait for the next prompt, which should mark the end of the reply
              output.expect prompt do |reply|
                puts "Received #{reply}"
                @library << [:reply, text]
              end
            end
          end
        end
      end
    end
  end

  # Send a command to the pacmd session, and return the output
  def command(text)
    @operator << [:command, text]
    puts "Requested #{text}"
    Actor.receive do |filter| 
      filter.when Case[:reply, String] do |_, reply|
        puts "Received reply"
        reply
      end
    end
  end
end

