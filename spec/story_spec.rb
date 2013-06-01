require 'story_builder.rb'

sample_item = item do
  name :container
  short_desc "has a foo"

  contains do
    name :foo
    short_desc "this works!"
  end
end

LOCKEDIN = story do
  has_player do
    name :Jude
    description "I'm a sample girl in this sample world!"

    starts_in :bedroom

    has_item do
      name :magic_mirror
      short_desc 'magic mirror'

      isnt static
    end

    has_item do
      name :necronomicon
      short_desc 'copy of Necronomicon'

      isnt static
    end
  end

  has_room do
    name :bedroom
    short_desc 'your bedroom'

    connects_with []

    has_item do
      name :alchemy_lab
      short_desc 'your alchemy kit'

      is static

      responds_to do
        command_verbs verbs %w(alchemize combine use)
        requires :necronomicon, :metal_chunk

        removes_from_player :necronomicon
        removes_from_player :metal_chunk
        gives_to_player do
          name :skeleton_key
          short_desc "haunted looking key"
          isnt static
        end

        tells_player "There's a light and the ghostly sound of a door_hinge in another dimesion"
      end
    end

    has_item do
      name :vent
      short_desc 'loose vent cover'

      is static

      contains do
        name :metal_chunk
        short_desc 'chunk of metal'

        isnt static
      end
    end

    has_item do
      name :locked_door
      short_desc 'locked door'

      is static

      responds_to do
        command_verbs verbs %w(open unlock)
        requires :skeleton_key

        removes_from_room :locked_door
        creates_connection [:bedroom, :hallway]

        tells_player "I opened the door."
      end
    end
  end
end

gs = LOCKEDIN.initial_gamestate
descs = {}
LOCKEDIN.descriptions.each {|d| descs[d.name]=d}
gs.items.each {|i| puts "#{i.inspect}, #{descs[i.name].short_desc}"}
LOCKEDIN.commands.each {|c| puts c.verbs.inspect}
