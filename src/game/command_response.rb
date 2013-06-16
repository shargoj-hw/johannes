class CommandRequest
  attr_reader :raw_command, :gamestate, :commands, :descriptions

  def initialize command, state, commands, descriptions
    @raw_command = command
    @state = state
    @commands = commands
    @descriptions = descriptions
  end
end

class CommandResponse
  attr_reader :command_request

  def initialize command_request, *args

    begin
      @response_state = do_command
      @response_text = success_response
    rescue Exception=>e
      @response_state = request_state
      @response_text = error_lookup_response e.class
    end
  end

  def do_command
    raise 'run_command not implemented'
  end

  def error_lookup_response classname
    raise 'error_lookup not implemented'
  end

  def success_response
    raise 'success_response not implemented'
  end
end

class PutResponse < CommandResponse
  def run_command
    request_state.put(*args)
  end
end
