require 'rubygems'
require 'extensions/all'

require_relative 'gameobject'

class Player < GameObject
  def initialize name, items
    super(name, items)
  end

  def new_with_items items
    Player.new @name, items
  end
end
