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
