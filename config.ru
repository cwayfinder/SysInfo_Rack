require 'rack'

#\ -w -p 8765

# The line above containg options
# passed to rackup utility.
# (Ruby warnings enabled, request port 8765)

use Rack::Reloader, 0
use Rack::ContentLength

class SysInfo

  def call(env)
    @request = Rack::Request.new(env)
    @response = Rack::Response.new

    @response.status = 200
    @response['Content-Type'] = 'text/plain'
    @response.body = [handle(@request.env['REQUEST_PATH'])]

    @response.finish
  end

  def handle(path)
    if path == '/'
      default()
    else
      command = path[1..-1]
      send(command.to_sym)
    end
  end

  def default
    memory() + "\n" + disk()
  end

  def method_missing(method_name)
    "\"#{method_name}\" is not recognized. Use /help to display available options."
  end

  def disk
    `fsutil volume diskfree C:`
  end

  def memory
    # todo: add checking OS and strategies for different systems
    `systeminfo |find "Available Physical Memory"`
  end

  def help
    '"/" - available memory and disk space
    "/memory" - available memory size
    "/disc" - disk capacity
    "/help" - shows this help page'
  end
end

run SysInfo.new
