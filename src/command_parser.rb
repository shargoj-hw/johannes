require 'rubygems'
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
    match('[A-Za-z]').repeat(1)
  }

  rule(:the) {spaced(stri("the"))}; rule(:the?) {the.maybe}

  rule(:from) {
    spaced(str("from")) >> the? >> item.as(:container)
  }
  rule(:takeword) {any_of_stri TAKE_WORDS}
  rule(:take) {
    spaced(takeword).as(:verb) >> the? >> item.as(:item) >>
    from.maybe
  }

  rule(:into) {
    spaced(any_of_stri ['into', 'in']) >> the? >>
    item.as(:container)
  }
  rule(:putword) {any_of_stri PUT_WORDS.map}
  rule(:put) {
    spaced(putword).as(:verb) >> the? >> item.as(:item) >>
    into.maybe
  }

  rule(:move) {
    spaced(any_of_stri MOVE_WORDS).as(:verb) >>
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
