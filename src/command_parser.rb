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
# that takes a GameState and a list of Commands
# (TODO: also descriptions?) and runs the command, returning
# a new GameState
class CommandTranslator < Parslet::Transform
  rule(:move => simple(:move), :location=>simple(:_location)) {
    location = simplify _location

    Proc.new do |state, commands|
      state.move_player location
    end
  }

  rule(:put => simple(:put), :item => simple(:_item)) {
    item = simplify _item

    Proc.new do |state, commands|
      state.put item
    end
  }

  rule(:put => simple(:put),
       :item => simple(:_item),
       :container => simple(:_container)) {
    item = simplify _item
    container = simplify _container

    Proc.new do |state, commands|
      state.put item, container
    end
  }

  rule(:take => simple(:take), :item => simple(:_item)) {
    item = simplify _item

    Proc.new do |state, commands|
      state.take item
    end
  }

  rule(:take => simple(:take),
       :item => simple(:_item),
       :container => simple(:_container)) {
    item = simplify _item
    container = simplify _container
    puts item, container

    Proc.new do |state, commands|
      state.take item, container
    end
  }

  rule(:verb => simple(:_verb), :items=>subtree(:_items)) {
    verb = simplify _verb
    items = _items.map {|i| simplify i[:item]}

    puts verb
    puts items.inspect

    Proc.new do |state, commands|
      viable_command = commands.find {|c| c.verbs.include? verb.to_s}
      puts viable_command.inspect
      viable_command.run_command state
    end
  }
end

# (String | ParsedCommand) GameState [Command] [Description] -> GameState
def run_command command, state, commands, descriptions
  command = CommandParser.new.parse command if command.is_a? String
  command = CommandTranslator.new.apply(command)

  command[state, commands, descriptions]
end
