$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'nagios'
require 'stringio'

def capture_output(&block)
  original_output = STDOUT.clone
  pipe_r, pipe_w = IO.pipe
  pipe_r.sync = true
  output = ""
  reader = Thread.new do
    begin
      loop do
        output << pipe_r.readpartial(1024)
      end
    rescue EOFError
    end
  end
  STDOUT.reopen(pipe_w)
  yield
ensure
  STDOUT.reopen(original_output)
  pipe_w.close
  reader.join
  return output
end

# prevent output to STDOUT which default logger does
Nagios.logger = Logger.new(StringIO.new)
