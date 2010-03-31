require 'pty'
require 'expect'

# This library runs an interactive program, such as pacmd or irb, and provides
# a method to execute commands in the program and return the replies.
class CommandMonkey

  # program: the interactive program to execute
  # prompt: regex detecting the interactive program's prompt
  def initialize(program, prompt)

    # the main thread pushes command requests to @command_queue
    @command_queue = Queue.new

    # the interactive program thread pushes command replies to @reply_queue
    @reply_queue = Queue.new
    
    # run the program in a separate thread so that this library does not block
    # the client program
    @program_thread = Thread.new do
      PTY.spawn program do |output, input, pid|

        output.expect prompt do |text|
          puts "Launched #{program}, PID #{pid}"
          puts text
        end

        loop do
          # wait for a command request
          command = @command_queue.pop

          # enter the command
          input.put "#{command}\n"
          puts "Sent #{command}"

          # wait for the next prompt, which should mark the end of the reply
          output.expect PROMPT do |text|
            puts "Received #{text}"
            @reply_queue << text
          end
        end
      end
    end
  end

  # Send a command to the pacmd session, and return the output
  def command(text)
    @command_queue << text
    @reply_queue.pop
  end
end

