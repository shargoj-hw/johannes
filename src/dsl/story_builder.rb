require "Docile"

require_relative "builder_builder"
require_relative "player_builder"
require_relative "command_builder"
require_relative "item_builder"
require_relative "room_builder"

require_relative "../game/story"

StoryData = Struct.new(:initial_gamestate,
                       :items,
                       :descriptions,
                       :commands)



story_build = Proc.new do
  player = @has_player

  items, descs, comms = unpack_metadata(@items+@rooms+[player])

  initial_rooms = @rooms.map {|roomdata| roomdata.room}
  start_gamestate = GameState.new items, initial_rooms, player.room, player.player

  desc_map = Hash.new
  descs.each {|d| desc_map[d.name] = d}

  Story.new start_gamestate, items, desc_map, comms
end

StoryBuilder = builder(story_build) do
  required_dsl :has_player, method(:player)

  accumulates_dsl :has_room, :rooms, method(:room)
  accumulates_dsl :has_item, :items, method(:item)
end

def story &block
  Docile.dsl_eval(StoryBuilder.new, &block).build
end
