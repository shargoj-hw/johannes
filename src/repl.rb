require_relative 'command_parser'

class REPL
  def initialize story
    @story = story
  end

  def run
    while true do
      print '--> '; cmd = $stdin.gets
      cmd = cmd.slice(0,cmd.length-1)

      @story.gamestate, response = run_command(cmd, @story)
      puts @story.gamestate.inspect
      puts response
    end
  end
end
