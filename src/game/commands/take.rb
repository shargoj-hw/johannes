require_relative '../command'

class TakeCommand < Command
  def initialize object, from=nil
    @object, @from = object, from
  end

  def run_command story
    state = story.gamestate
    object = story.find_local_item @object
    from = story.find_local_item @from unless @from.nil?

    begin
      return (state.take object, from), "I got the #{@object}."
    rescue InvalidContainer
      return state, "I don't know how to take the #{@object} from the #{@from}"
    rescue AttemptedStaticObjectPickup
      return state, "I can't pick up the #{@object}"
    rescue ItemNotFound
      return state, "I don't know how to pick up the #{@object}"
    end
  end
end
