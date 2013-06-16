require 'parslet'

require_relative 'game/commands/all_commands'

DESCRIBE_WORDS = ['look at'].concat %w(look inspect describe see l i)
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

  rule(:describe) {
    spaced(any_of_stri DESCRIBE_WORDS).as(:describe) >>
    the? >>
    item.as(:item)
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
    [move, take, put, describe, sentence].reduce(:|)
  }

  root(:command)
end

# homogenize the input data
def simplify o
  o.to_s.downcase.strip
end

# Translate a parsed command (from CommandParser) into a procedure
# that takes a GameState and a list of Commands and runs the command,
# returning a new [GameState, ResponseText]
class CommandTranslator < Parslet::Transform
  rule(:move => simple(:move), :location=>simple(:_location)) {
    location = simplify _location

    MovePlayerCommand.new location.to_sym
  }


  rule(:put => simple(:put), :item => simple(:_item)) {
    item = simplify _item

    PutCommand.new item
  }


  rule(:put => simple(:put),
       :item => simple(:_item),
       :container => simple(:_container)) {
    item = simplify _item
    container = simplify _container

    PutCommand.new item, container
  }


  rule(:take => simple(:take), :item => simple(:_item)) {
    item = simplify _item

    TakeCommand.new item
  }


  rule(:take => simple(:take),
       :item => simple(:_item),
       :container => simple(:_container)) {
    item = simplify _item
    container = simplify _container

    TakeCommand.new item, container
  }

  rule(:describe => simple(:describe),
       :item => simple(:_item)) {
    item = simplify _item

    DescribeCommand.new item
  }

  rule(:verb => simple(:_verb), :items=>subtree(:_items)) {
    verb = simplify _verb

    StoryCommand.new verb
  }
end

# (string | command) Story -> [GameState, String]
def run_command command, story
  begin
    command = CommandParser.new.parse command if command.is_a? String
  rescue Parslet::ParseFailed
    return [story.gamestate, "I don't know what you mean."]
  end

  return CommandTranslator.new.apply(command).run_command(story)
end
