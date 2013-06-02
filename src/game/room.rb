require 'rubygems'
require 'extensions/all'

require_relative 'gameobject'

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
