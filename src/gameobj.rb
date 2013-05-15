require 'rubygems'
require 'builder_builder'
require 'docile'

# A GameObject is a physical object in a GameState.
#
# It can be the object of Commands. If it is static, it can't be
# picked up.
class GameObject
  attr_reader :name, :qualities, :short_desc, :long_desc

  def initialize name, short_desc, qualities, long_desc, static
    @name = name
    @short_desc = short_desc
    @qualities = qualities
    @long_desc = long_desc
    @static = static
  end

  def is? obj; @qualities.include? obj; end
  def is_static?; @static; end
end

gameobj_build = Proc.new do
  GameObject.new @name, @short_desc, @qualities, @long_desc, @static
end

GameObjectBuilder = builder(gameobj_build) do
  required :name # an ID used to refer to this specific object
  required :short_desc # A short (<5 word) description of the object
  required :qualities # A list of the qualities of the object
  optional :long_desc # A longer description for inspections
  defaulted :static, false # Can the player pick this object up?
end

def gameobj(&block)
  Docile.dsl_eval(GameObjectBuilder.new, &block).build
end
