require 'docile'

class BuilderBuilder
  def initialize
    @required_fields = []
    @required_dsl = {}
    @defaulted_fields = {}
    @optional_fields = []
    @booleans = []
    @accumulators = {}
    @dsl_accumulators = {}
  end

  def all_basic_fields
    @required_fields + @defaulted_fields.keys + @optional_fields + @booleans
  end

  def required(*names);@required_fields += names if names;end
  def required_dsl(name, method); @required_dsl[name] = method; end
  def defaulted(name, val);@defaulted_fields[name] = val;end
  def optional(*names);@optional_fields += names if names;end
  def boolean(*names);@booleans += names if names; end
  def accumulates(builder_name, property=nil)
    property ||= builder_name
    @accumulators[builder_name] = "@#{property}"
  end

  def accumulates_dsl(builder_name, property, method)
    @dsl_accumulators[builder_name] = ["@#{property}", method]
  end

  # TODO: Refactor into smaller methods?
  def builder_build build
    builder = Class.new
    class << builder
      attr_accessor :reqs, :defaults, :builder, :booleans, :accumulated
    end

    all_basic_fields.each {|field| _create_name_method builder, field}

    @required_dsl.each do |name, method|
      builder.class_eval do
        define_method(name) do |&block|
          instance_variable_set "@#{name}", (method.call(&block))
        end
      end
    end

    @accumulators.each {|builder_name, property|
      builder.class_eval do
        define_method(builder_name) do |val|
          current_value = (instance_variable_get property)
          instance_variable_set property, (current_value.push val)
        end
      end
    }

    @dsl_accumulators.each do |name, prop_meth|
      property, method = prop_meth

      builder.class_eval do
        define_method(name) do |&block|
          current_value = (instance_variable_get property)
          instance_variable_set property, (current_value.push(method.call(&block)))
        end
      end
    end

    @booleans.each do |name|
      builder.class_eval do
        define_method(name) do
          name
        end
      end
    end

    builder.reqs = @required_fields + @required_dsl.keys
    builder.defaults = @defaulted_fields
    builder.accumulated = (@accumulators.values + @dsl_accumulators.values.map(&:first))
    builder.builder = build

    builder.class_eval do
      def initialize
        self.class.accumulated.each do |accumulated|
          instance_variable_set accumulated, []
        end
      end

      def is quality
        instance_variable_set "@#{quality}", true
      end

      def isnt quality
        instance_variable_set "@#{quality}", false
      end

      def is_valid?
        self.class.reqs.each do |field|
          if instance_variable_get("@#{field}") == nil
            puts "Required field @#{field} was not defined"
            return false
          end
        end
        true
      end

      def validate
        raise "Not all required fields are defined." unless self.is_valid?
        self.class.defaults.each do |name, val|
          prop_name = "@#{name}"
          if instance_variable_get(prop_name) == nil
            instance_variable_set prop_name, val
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
