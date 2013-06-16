require_relative '../command'

class StoryCommand < Command
  def initialize verb
    @verb = verb
  end

  def run_command story
    state = story.gamestate

    command = story.commands.find {|c| c.verbs.include? @verb}

    begin
      raise CantRun if command.nil?
      return command.run_command(state)
    rescue CantRun
      return state, "I don't know how to do that."
    end
  end
end
