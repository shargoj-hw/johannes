require_relative '../command'

class MovePlayerCommand < Command
  def initialize to_room
    @to_room = to_room
  end

  def run_command story
    state = story.gamestate

    begin
      return (state.move @to_room), "I just got to the #{@to_room}."
    rescue RoomNotAdjacent
      return state, "I can't get there."
    end
  end
end
