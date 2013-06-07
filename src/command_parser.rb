require 'parslet'

TAKE_WORDS = %w(take grab hold collect) << "pick up"
PUT_WORDS = %w(drop put discard) << "put down"
MOVE_WORDS = %w(go move walk run exit)

def stri(str)
  key_chars = str.split(//)
  key_chars.
    collect! { |char| match["#{char.upcase}#{char.downcase}"] }.
    reduce(:>>)
end

def any_of items
  items.reduce(:|)
end

def any_of_stri items
  items.map{|w| stri w}.reduce(:|)
end

def spaced thing
  match('\s').repeat >> thing >> match('\s').repeat
end

# TODO: generate these from items?
class CommandParser < Parslet::Parser
  rule(:item) {
    match('[A-Za-z_]').repeat(1)
  }

  rule(:the) {spaced(stri("the"))}; rule(:the?) {the.maybe}

  rule(:from) {
    spaced(str("from")) >> the? >> item.as(:container)
  }
  rule(:takeword) {any_of_stri TAKE_WORDS}
  rule(:take) {
    spaced(takeword).as(:take) >> the? >> item.as(:item) >>
    from.maybe
  }

  rule(:into) {
    spaced(any_of_stri ['into', 'in']) >> the? >>
    item.as(:container)
  }
  rule(:putword) {any_of_stri PUT_WORDS}
  rule(:put) {
    spaced(putword).as(:put) >> the? >> item.as(:item) >>
    into.maybe
  }

  rule(:move) {
    spaced(any_of_stri MOVE_WORDS).as(:move) >>
    spaced(any_of_stri ['into', 'in', 'to']).maybe >>
    the? >>
    item.as(:location)
  }

  rule(:with?) {spaced(stri "with").maybe}
  rule(:and?) {spaced(any_of_stri [', and', ',', 'and']).maybe}
  rule(:withitem) {
    and? >> with? >> the? >> item.as(:item) >> match('\s').repeat
  }
  rule(:sentence) {
    item.as(:verb) >>
    withitem.repeat.as(:items)
  }

  rule(:command) {
    [move, take, put, sentence].reduce(:|)
  }

  root(:command)
end

# convert to a reasonable symbol for the gamestate
def simplify o
  o.to_s.downcase.strip.to_sym
end

# Translate a parsed command (from CommandParser) into a procedure
# that takes a GameState and a list of Commands and runs the command,
# returning a new [GameState, ResponseText]
class CommandTranslator < Parslet::Transform
  rule(:move => simple(:move), :location=>simple(:_location)) {
    location = simplify _location

    lambda do |state, commands, descriptions|
      begin
        return state.move_player(location), "I just got to the #{location.to_s}."
      rescue RoomNotAdjacent
        return state, "I don't know how to get there from here."
      end
    end
  }


  rule(:put => simple(:put), :item => simple(:_item)) {
    item = simplify _item

    lambda do |state, commands, descriptions|
      begin
        return state.put(item), "I got rid of it."
      rescue ItemNotFound
        return state, "I'm not carrying that."
      end
    end
  }


  rule(:put => simple(:put),
       :item => simple(:_item),
       :container => simple(:_container)) {
    item = simplify _item
    container = simplify _container

    lambda do |state, commands, descriptions|
      begin
        return state.put(item, container), "There it goes!"
      rescue ItemNotFound
        return state, "I'm not carrying that."
      end
    end
  }


  rule(:take => simple(:take), :item => simple(:_item)) {
    item = simplify _item

    lambda do |state, commands, descriptions|
      begin
        return state.take(item), "I grabbed it."
      rescue ItemNotFound
        return state, "I can't find one of those"
      end
    end
  }


  rule(:take => simple(:take),
       :item => simple(:_item),
       :container => simple(:_container)) {
    item = simplify _item
    container = simplify _container

    lambda do |state, commands, descriptions|
      begin
        return state.take(item, container), "I got it!"
      rescue ItemNotFound
        return state, "I couldn't grab that."
      rescue AttemptedStaticObjectPickup
        return state, "I can't pick that up."
      end
    end
  }


  rule(:verb => simple(:_verb), :items=>subtree(:_items)) {
    verb = simplify _verb
    # items = _items.map {|i| simplify i[:item]}

    lambda do |state, commands, descriptions|
      viable_command = commands.find {|c| c.verbs.include? verb.to_s}

      if viable_command.nil?
        return state, "I don't know what you mean by that."
      end

      begin
        return viable_command.run_command(state), viable_command.on_success
      rescue
        return state, "I can't do that for some reason."
      rescue InvalidContainer
        return state, "I don't know how to take that from there"
      end
    end
  }

end

# (String | ParsedCommand) GameState [Command] [Description] -> GameState
def run_command command, state, commands, descriptions
  command = CommandParser.new.parse command if command.is_a? String

  CommandTranslator.new.apply(command)[state, commands, descriptions]
end
