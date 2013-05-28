require "rubygems"
require "Docile"
require "builder_builder.rb"
require "gamestate.rb"

def unpack_metadata data
  items = data.reduce([]) {|items, itemdata| items+itemdata.items}
  descs = data.reduce([]) {|descs, itemdata| descs+itemdata.descriptions}
  comms = data.reduce([]) {|comms, itemdata| comms+itemdata.commands}

  [items, descs, comms]
end

ItemData = Struct.new :item, :items, :descriptions, :commands

item_build = Proc.new do
  @items ||= []

  items, descs, comms = unpack_metadata @items

  contained_items = @items.map {|itemdata| itemdata.item.name}
  contained_items = (@container || contained_items) ? contained_items : nil

  this_item = Item.new @name, contained_items, @static

  items << this_item
  descs << (Description.new @name, @short_desc, @long_desc)
  comms.concat @commands if @commands

  ItemData.new this_item, items, descs, comms
end

# These methods exist so that ItemBuilder can be recursive
# and use commands
def helper_item &block
  item(&block)
end

def helper_command &block
  command(&block)
end

ItemBuilder = builder(item_build) do
  required :name
  required :short_desc
  optional :long_desc

  boolean :static
  boolean :container

  accumulates_dsl :contains, :items, method(:helper_item)
  accumulates_dsl :responds_to, :commands, method(:helper_command)
end

def item &block
  Docile.dsl_eval(ItemBuilder.new, &block).build
end

item_proc = method(:item)

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

PlayerData = Struct.new :player, :room, :items, :descriptions, :commands
player_build = Proc.new do
  @items ||= []

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

class CommandBuilder
  def method_missing meth, *args, &block
  end

  def verbs n
    @name = (n.first.to_str+"_COMMAND").to_s
  end

  def build
    @name
  end
end

def command &block
  Docile.dsl_eval(CommandBuilder.new, &block).build
end

StoryData = Struct.new(:initial_gamestate, :items, :descriptions, :commands)

story_build = Proc.new do
  player = @has_player
  @items ||= []
  @rooms ||= []

  items, descs, comms = unpack_metadata(@items+@rooms+[player])

  initial_rooms = @rooms.map {|roomdata| roomdata.room}
  start_gamestate = GameState.new items, initial_rooms, player.room, player.player

  StoryData.new start_gamestate, items, descs, comms
end

StoryBuilder = builder(story_build) do
  required_dsl :has_player, method(:player)

  accumulates_dsl :has_room, :rooms, method(:room)
  accumulates_dsl :has_item, :items, method(:item)
end

def story &block
  Docile.dsl_eval(StoryBuilder.new, &block).build
end
