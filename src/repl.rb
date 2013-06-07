require_relative 'command_parser'

class REPL
  def initialize gamestate, commands, descriptions
    @gamestate = gamestate
    @commands = commands
    @descriptions = descriptions
  end

  def run
    while true do
      print '--> '; cmd = gets
      cmd = cmd.slice(0,cmd.length-1)

      @gamestate = run_command cmd, @gamestate, @commands

      puts @gamestate.inspect
    end
  end
end
