require_relative '../command'

class DescribeCommand < Command
  def initialize object
    @object = object
  end

  def run_command story
    state, descriptions = story.gamestate, story.descriptions
    # TODO: make this find rooms too.
    desc = descriptions[story.find_local_item @object]

    if desc.long_desc.nil?
      return state, desc.short_desc
    else
      return state, desc.long_desc
    end
  end
end
