class ItemNotFound < Exception; end
class RoomNotAdjacent < Exception; end
class InvalidContainer < Exception; end
class AttemptedStaticObjectPickup < Exception; end

class GameState
  attr_reader :items, :rooms, :player

  def initialize items, rooms, current_room, player
    @items = items
    @rooms = rooms
    @current_room = current_room
    @player = player
  end

  def to_mongo
    mongo_items = {}
    items.each{|i| mongo_items[i.name] = i.items}

    mongo_rooms = {}
    rooms.each{|r| mongo_rooms[r.name] = r.items}

    mongo_player_items = player.items

    {
      'items' => mongo_items,
      'rooms' => mongo_rooms,
      'current_room' => current_room.name,
      'player_items' => mongo_player_items
    }
  end

  def self.from_mongo initial, mongo_data
    items = initial.items.map {|i|
      items = i.is_container? ? (mongo_data['items'][i.name.to_s]) : nil
      i.new_with_items items
    }

    rooms = initial.rooms.map {|r|
      r.new_with_items(mongo_data['rooms'][r.name.to_s])
    }

    current_room = mongo_data['current_room']

    player = initial.player.new_with_items mongo_data['player_items']

    GameState.new items, rooms, current_room, player
  end

  def current_room
    # TODO: should this error out?
    room @current_room
  end

  def room room_name
    if room_name == :current_room
      current_room
    else
      @rooms.find {|room| room.name == room_name}
    end
  end

  def item item_name
    @items.find {|item| item.name == item_name}
  end

  def take item, from=nil
    player_with_item = player.add_items item

    if !from.nil?
      real_item = self.item from
      if real_item.nil? || !real_item.contains?(item)
        raise InvalidContainer
      end

      container_less_item = (self.item from).destroy_items item
      new_items = replace_item container_less_item

      GameState.new new_items, rooms, @current_room, player_with_item
    elsif current_room.items.include? item
      raise AttemptedStaticObjectPickup if (self.item item).is_static?

      room_without_item = current_room.destroy_items item

      new_rooms = replace_room room_without_item

      GameState.new items, new_rooms, @current_room, player_with_item
    else
      raise ItemNotFound
    end
  end

  def put item, into=nil
    raise ItemNotFound unless player.items.include? item
    raise InvalidContainer if !into.nil? && !valid_container(into)

    real_item = (self.item item)
    player_without_item = player.destroy_items item

    if !into.nil? && real_item.is_container?
      item_with_item = real_item.add_items item
      new_items = replace_item item_with_item
      GameState.new new_items, rooms, @current_room, player_without_item
    else
      room_with_item = current_room.add_items item
      new_rooms = replace_room room_with_item
      GameState.new items, new_rooms, @current_room, player_without_item
    end
  end

  def player_create item
    GameState.new items, rooms, @current_room, (player.add_items item)
  end

  def room_create room, item
    new_rooms = replace_room((self.room room).add_items item)
    GameState.new items, new_rooms, @current_room, player
  end

  def container_create
    new_items = replace_item((self.item item).add_items item)
    GameState.new new_items, rooms, @current_room, player
  end

  def player_destroy item
    GameState.new items, rooms, @current_room, (player.destroy_items item)
  end

  def room_destroy room, item
    new_rooms = replace_room((self.room room).destroy_items item)
    GameState.new items, new_rooms, @current_room, player
  end

  def item_destroy container, item
    new_items = replace_item((self.item item).destroy_items item)
    GameState.new new_items, rooms, @current_room, player
  end

  def create_connections *rooms
    rooms_with_connections = @rooms.map do |room|
      if rooms.include? room.name
        room.add_connections(*(rooms - [room.name]))
      else
        room
      end
    end

    GameState.new items, rooms_with_connections, @current_room, player
  end

  def destroy_connections *rooms
    rooms_without_connections = @rooms.map do |room|
      if rooms.include? room.name
        room.destroy_connections(*(rooms - [room.name]))
      else
        room
      end
    end

    GameState.new items, rooms_without_connections, @current_room, player
  end

  def move_player to_room
    if current_room.is_connected? to_room
      GameState.new items, rooms, to_room, player
    else
      raise RoomNotAdjacent
    end
  end

  def force_move_player to_room
    GameState.new items, rooms, to_room, player
  end

  private
  def replace_room room
    (rooms.select {|r| r.name != room.name}) << room
  end

  def replace_item item
    (items.select {|i| i.name != item.name}) << item
  end

  def valid_container item
    item = (self.item item)

    !item.nil? && item.is_container?
  end
end
