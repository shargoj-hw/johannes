require_relative 'command_parser'

class REPL
  def initialize gamestate, commands, descriptions
    @gamestate = gamestate
    @commands = commands
    @descriptions = descriptions
  end

  def run
    while true do
      print '--> '; cmd = $stdin.gets
      cmd = cmd.slice(0,cmd.length-1)

      @gamestate, response = run_command(cmd,
                                         @gamestate,
                                         @commands,
                                         @descriptions)

      puts @gamestate.inspect
      puts response
    end
  end
end
