require "rubygems"
require 'extensions/all'
require "Docile"

require_relative "builder_builder"
require_relative "command_builder"
require_relative "util"

require_relative "../game/item"
require_relative "../game/description"

ItemData = Struct.new :item, :items, :descriptions, :commands

item_build = Proc.new do
  items, descs, comms = unpack_metadata(@items+@commands)

  contained_items = @items.map {|itemdata| itemdata.item.name}
  contained_items = (@container || contained_items) ? contained_items : nil

  this_item = Item.new @name, contained_items, @static

  items << this_item
  descs << (Description.new @name, @short_desc, @long_desc)

  ItemData.new this_item, items, descs, comms
end

# These methods exist so that ItemBuilder can be recursive
# and use commands
def helper_item &block; item(&block); end
def helper_command &block; command(&block); end

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
