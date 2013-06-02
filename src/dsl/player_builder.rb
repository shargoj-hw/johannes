require "rubygems"
require 'extensions/all'
require "Docile"

require_relative "builder_builder"
require_relative "item_builder"

require_relative "../game/player"

PlayerData = Struct.new :player, :room, :items, :descriptions, :commands
player_build = Proc.new do
  items, descs, comms = unpack_metadata @items

  player_desc = Description.new @name, @description, @description
  descs << player_desc

  player_items = @items.map {|itemdata| itemdata.item.name}
  player = Player.new @name, player_items

  PlayerData.new player, @starts_in, items, descs, comms
end

PlayerBuilder = builder(player_build) do
  required :name
  required :description
  required :starts_in

  accumulates_dsl :has_item, :items, method(:item)
end

def player &block
  Docile.dsl_eval(PlayerBuilder.new, &block).build
end
