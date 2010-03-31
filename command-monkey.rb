require 'pty'
require 'expect'
require 'revactor'

# This library runs an interactive program, such as pacmd or irb, and provides
# a method to execute commands in the program and return the replies.
class CommandMonkey

  # program: the interactive program to execute
  # prompt: regex detecting the interactive program's prompt
  def initialize(program, prompt)
    @prompt = prompt
    @library = Actor.current

    # run the program in a separate thread so that this library does not block
    # the client program
    @operator = Actor.spawn do
      PTY.spawn program do |output, input, pid|
        @output = output

        get_reply

        loop do
          # wait for a command request
          Actor.receive do |filter|
            filter.when Case[:command, String] do |_, text|
              # enter the command
              input.print "#{text}\n"

              # wait for the next prompt, which should mark the end of the reply
              get_reply(text) do |reply|
                @library << [:reply, reply]
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
    Actor.receive do |filter| 
      filter.when Case[:reply, String] do |_, reply|
        reply
      end
    end
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

  # Wait for the program to show its prompt, and yield the output before the
  # prompt to the block
  def get_reply(command=nil, &block)
    @output.expect @prompt do |reply, *_|
      reply.sub!(/#{@prompt}\z/m, '')
      reply.sub!(strip_command_pattern(command), '') if command
      yield filter_output(reply) if block_given?
    end
  end
end

