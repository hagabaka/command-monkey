require 'pty'
require 'expect'

# This library runs an interactive program, such as pacmd or irb, and provides
# a method to execute commands in the program and return the replies.
class CommandMonkey

  # program: the interactive program to execute
  # prompt: regex detecting the interactive program's prompt
  def initialize(program, prompt)
    @prompt = prompt

    # run the program in a separate thread so that this library does not block
    # the client program
    @operator = Fiber.new do |command|
      PTY.spawn program do |output, input, pid|
        @output = output

        get_reply

        loop do
          input.puts command
          command = Fiber.yield get_reply(command)
        end
      end
    end
  end

  # Send a command to the pacmd session, and return the output
  def enter(command)
    @operator.resume(command)
  end

  # Captured output from the program is filtered through this method before
  # being returned
  def filter_output(text)
    text.strip
  end

  # Return the pattern which needs to be removed, based on the command text
  def strip_command_pattern(command)
    /\A\s+#{Regexp.quote command}/
  end

  private

  # Wait for the program to show its prompt, and yield the output before the
  # prompt to the block
  def get_reply(command=nil)
    @output.expect @prompt do |reply, *_|
      reply.sub!(/#{@prompt}\z/m, '')
      reply.sub!(strip_command_pattern(command), '') if command
      return filter_output(reply)
    end
  end
end

