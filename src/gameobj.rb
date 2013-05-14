require 'rubygems'
require 'docile'

class GameObject

end


# class GameObjectBuilder < SimpleBuilder
#   attr_builder_required_fields :short_description, :qualities
#   # attr_builder_field_with_default :static, true
#   # attr_builder_optional_fields :long_description, :smell

#   def build
#     puts short_description
#     puts qualities
#   end
# end

def object(&block)
  Docile.dsl_eval(GameObjectBuilder.new, &block).build
end
