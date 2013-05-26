require 'rubygems'
require 'docile'

class BuilderBuilder
  def initialize
    @required_fields = []
    @defaulted_fields = {}
    @optional_fields = []
  end

  def all_fields
    @required_fields + @defaulted_fields.keys + @optional_fields
  end

  def required(*names);@required_fields += names if names;end
  def defaulted(name, val);@defaulted_fields["@#{name}"] = val;end
  def optional(*names);@optional_fields += names if names;end

  # TODO: Refactor into smaller methods?
  def builder_build build
    builder = Class.new
    class << builder
      attr_accessor :reqs, :defaults, :builder
    end

    all_fields.each {|field| _create_name_method builder, field}

    builder.reqs = @required_fields
    builder.defaults = @defaulted_fields
    builder.builder = build

    builder.class_eval do
      def isValid?
        self.class.reqs.each do |field|
          return false if instance_variable_get("@#{field}") == nil
        end
        true
      end

      def validate
        raise "Not all required fields are defined." unless self.isValid?
        self.class.defaults.each do |name, val|
          if instance_variable_get(name) == nil
            instance_variable_set name, val
          end
        end
      end

      def build
        validate
        instance_eval(&self.class.builder)
      end
    end

    builder
  end

  private
  def _create_name_method builder, name
    builder.class_eval do
      define_method(name) do |val|
        instance_variable_set "@#{name}", val
      end
    end
  end
end

def builder(build=nil, &block)
  build ||= Proc.new do
    validate
    Hash[instance_variables.map do |var|
           [var[1..-1].to_sym, instance_variable_get(var)]
         end]
  end

  Docile.dsl_eval(BuilderBuilder.new, &block).builder_build(build)
end

=begin
# Tests that should be integrated into the spec
bb = BuilderBuilder.new
bb.required :needed
bb.optional :opt1, :opt2
bb.defaulted :three, 3
TestBuilder_ = bb.builder_build(Proc.new do
    validate
    puts @needed, @opt1, @opt2, @three
end)

testbuilder = TestBuilder_.new
testbuilder.needed "Got needed"
testbuilder.opt1 "Option 1"
testbuilder.build

print_game_obj = Proc.new do
    puts @short_desc, @qualities.inspect
end

GameObjectBuilder = builder(print_game_obj) do
  required :short_desc, :qualities
  optional :long_desc, :smell
  defaulted :static, true
end

def gameobj(&block)
  Docile.dsl_eval(GameObjectBuilder.new, &block).build
end

wrench = gameobj do
  short_desc "It turns shit."
  qualities :holdable, :awesome
end
=end
