require_relative '../command'

class DescribeCommand < Command
  def initialize object
    @object = object
  end

  def run_command story
    state, descriptions = story.gamestate, story.descriptions
    # TODO: make this find rooms too.
    obj = story.find_local_item @object
    desc = descriptions[obj]

    if obj.nil? || desc.nil?
      return state, "I don't know what #{@object} is."
    elsif desc.long_desc.nil?
      return state, desc.short_desc
    else
      return state, desc.long_desc
    end
  end
end
