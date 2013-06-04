require_relative 'gameobject'

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

  def is_container?
    !items.nil?
  end
end
