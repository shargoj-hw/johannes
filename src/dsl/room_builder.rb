require "rubygems"
require 'extensions/all'
require "Docile"

require_relative "builder_builder"
require_relative "item_builder"

require_relative "../game/room"
require_relative "../game/description"

RoomData = Struct.new :room, :items, :descriptions, :commands
room_build = Proc.new do
  items, descs, comms = unpack_metadata @items

  room_desc = Description.new @name, @short_desc, @long_desc
  descs << room_desc

  room_items = @items.map {|itemdata| itemdata.item.name}
  room = Room.new @name, room_items, @connects_with

  RoomData.new room, items, descs, comms
end

RoomBuilder = builder(room_build) do
  required :name
  required :short_desc

  optional :long_desc

  defaulted :connects_with, []

  accumulates_dsl :has_item, :items, method(:item)
end

def room &block
  Docile.dsl_eval(RoomBuilder.new, &block).build
end
