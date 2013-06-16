class Story
  attr_reader :gamestate, :items, :descriptions, :commands

  def initialize gamestate, items, descriptions, commands
    @gamestate= gamestate
    @items = items
    @descriptions = descriptions
    @commands = commands
  end

  def with_gamestate gs
    Story.new gs, items, descriptions, commands
  end

  # Find an object in the current room or in the player's inventory
  # based on it's name or description.
  def find_local_item item
    local_items = gamestate.player.items +
      gamestate.current_room.items +
      gamestate.current_room.items.reduce([]) {|is, i|
      i = gamestate.item i
      if i.is_container?
        is + i.items
      else
        is
      end
    }

    itemsym = item.to_sym
    local_items.each {|i|
      return i if i == itemsym
    }

    item_words = item.split
    local_items.each {|i|
      desc = descriptions[i]

      return i if item_words.all? { |w| desc.short_desc.include? w}
    }

    return nil
  end

  def find_room room

  end
end
