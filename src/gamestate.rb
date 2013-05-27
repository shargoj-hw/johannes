class ItemNotFound < Exception; end

class GameState
  attr_reader :items, :rooms, :player

  def initialize items, rooms, current_room, player
    @items = items
    @rooms = rooms
    @current_room = current_room
    @player = player
  end

  def current_room
    # TODO: should this error out?
    room @current_room
  end

  def room room_name
    @rooms.find {|room| room.name == room_name}
  end

  def item item_name
    @items.find {|item| item.name == item_name}
  end

  def take item
    if current_room.items.include? item
      raise 'tried to pick up a static object' if (self.item item).is_static?
      room_without_item = current_room.destroy_items item
      player_with_item = player.add_items item

      new_rooms = rooms_with_current_room room_without_item

      GameState.new items, new_rooms, @current_room, player_with_item
    else
      raise ItemNotFound
    end
  end

  # TODO: make this aware of containers
  def put item
    if player.items.include? item
      room_with_item = current_room.add_items item
      player_without_item = player.destroy_items item

      new_rooms = rooms_with_current_room room_with_item

      GameState.new items, new_rooms, @current_room, player_without_item
    else
      raise ItemNotFound
    end
  end

  def player_create
    raise NotImplementedError
  end

  def room_create
    raise NotImplementedError
  end

  def container_create
    raise NotImplementedError
  end

  # TODO: add player-destroy specific option
  def destroy item
    if (player.items.include? item) || (current_room.items.include? item)
      new_rooms = rooms_with_current_room current_room.destroy_items item
      new_player = player.destroy_items item

      GameState.new items, new_rooms, @current_room, new_player
    else
      raise ItemNotFound
    end
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

  private
  def rooms_with_current_room new_current_room
    (rooms - [current_room]) + [new_current_room]
  end
end

class Description
  attr_reader :name, :short_desc, :long_desc

  def initialize name, short_desc, long_desc
    @name, @short_desc, @long_desc = name, short_desc, long_desc
  end
end

class GameObject
  # Symbol name of this object
  attr_reader :name
  # List of ItemReferences in this object, or nil if not a container
  attr_reader :items

  def initialize name, items
    @name = name
    @items = items
  end

  def add_items *items
    raise '#{name} is not a container' if items.nil?

    new_with_items((@items + items).uniq)
  end

  def destroy_items *items
    raise '#{name} is not a container' if items.nil?

    new_with_items @items.reject {|item| items.include? item}
  end

  def new_with_items items
    raise NotImplementedError
  end
end

class Item < GameObject
  def initialize name, items=nil, static=false
    super(name, items)
    @static = static
  end

  def is_static?
    @static
  end

  def new_with_items items
    Item.new name, items
  end
end

class Room < GameObject
  # List of RoomReferences connected to this room
  attr_reader :connections

  def initialize name, items, connections
    super(name, items)

    @connections = connections
  end

  def add_connections *connections
    Room.new name, items, (connections+@connections).uniq
  end

  def destroy_connections *connections
    Room.new name, items, (@connections-connections)
  end

  def new_with_items items
    Room.new name, items, connections
  end
end

class Player < GameObject
  def initialize name, items
    super(name, items)
  end

  def new_with_items items
    Player.new items
  end
end
