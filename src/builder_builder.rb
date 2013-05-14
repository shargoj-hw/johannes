require 'rubygems'
require 'docile'

class BuilderBuilder
  def initialize
    @new_builder = Class.new {}
    @required_fields    = []
    @defaulted_fields   = {}
  end

  def required(*names)
    return unless names
    @required_fields += names
    names.each {|name| _create_name_method name}
  end

  def defaulted(name, val)
    @defaulted_fields["@#{name}"] = val
    _create_name_method name
  end

  def optional(*names)
    names.each {|name| _create_name_method name}
  end

  def build_builder
    @new_builder.class_eval %Q{
      def isValid?
        #{@required_fields.inspect}.each do |field|
          return false if instance_variable_get("@\#{field}") == nil
        end
        true
      end

      def prebuild
        raise "Not all required fields are defined." unless self.isValid?
        #{@defaulted_fields.inspect}.each do |name, val|
          if instance_variable_get(name) == nil
            instance_variable_set name, val
          end
        end
      end
    }

    @new_builder
  end

  private
 sd
  def _create_name_method name
    @new_builder.class_eval do
      define_method(name) do |val|
        instance_variable_set "@#{name}", val
      end
    end
  end
end

bb = BuilderBuilder.new
bb.required :needed
bb.optional :opt1, :opt2
bb.defaulted :three, 3
TestBuilder = bb.build_builder

class TestBuilder
  def build
    prebuild
    puts @needed, @opt1, @opt2, @three
  end
end

testbuilder = TestBuilder.new
testbuilder.needed "Got needed"
testbuilder.opt1 "Option 1"
testbuilder.build

def builder(&block)
  Docile.dsl_eval(BuilderBuilder.new, &block).build_builder
end

GameObjectBuilder = builder do
  required :short_desc, :qualities
  optional :long_desc, :smell
  defaulted :static, true
end

class GameObjectBuilder
  def build
    puts @short_desc, @qualities.inspect
  end
end

def gameobj(&block)
  Docile.dsl_eval(GameObjectBuilder.new, &block).build
end

wrench = gameobj do
  short_desc "It turns shit."
  qualities :holdable, :awesome
end
