require_relative '../command'

class PutCommand < Command
  def initialize object, where=nil
    @object, @where = object, where
  end

  def run_command story
    state, descriptions = story.gamestate, story.descriptions

    obj = story.find_local_item @object

    begin
      return (state.put obj, @where), "I no longer have the #{@object}."
    rescue InvalidContainer
      return state, "I can't put that there."
    rescue ItemNotFound
      return state, "I don't have the #{@object}"
    end
  end
end
