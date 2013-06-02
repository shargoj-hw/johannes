require 'rubygems'
require 'Docile'

require_relative 'item_builder'
require_relative '../game/command'

CommandData = Struct.new :command, :items, :descriptions, :commands

# Monkey-patching this class to avoid a ton of code duplication.
class Command
  def give_player &item_block
    new_item = item(&item_block)
    (@items ||= []).concat new_item.items
    (@descs ||= []).concat new_item.descriptions
    (@comms ||= []).concat new_item.commands

    @player_adds << new_item.item.name
  end

  def build
    CommandData.new(self,
                    (@items||[]),
                    (@descs||[]),
                    ((@comms||[]) << self))
  end
end

def command &block
  Docile.dsl_eval(Command.new, &block).build
end
