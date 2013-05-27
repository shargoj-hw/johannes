require 'story_builder.rb'

LOCKEDIN = story do
  has_player(player do
               name :Jude
               description "I'm a simple girl in this sample world!"

               starts_in :bedroom

               has_item(item do
                          name :magic_mirror
                          short_desc 'magic mirror'

                          isnt static
                        end)

               has_item(item do
                          name :necronomicon
                          short_desc 'copy of Necronomicon'

                          isnt static
                        end)
             end)

  has_room(room do
             name :bedroom
             short_desc 'your bedroom'

             connects_with []

             has_item(item do
                        name :alchemy_lab
                        short_desc 'your alchemy kit'

                        is static

                        responds_to(command do
                                      verbs %w(alchemize combine use)
                                      takes_and_destroys :necronomicon
                                      takes_and_destroys :metal_chunk
                                      gives_player(item do
                                                     name :skeleton_key
                                                     short_desc "haunted looking key"
                                                     isnt static
                                                   end)

                                      tells_player "There's a light and the ghostly sound of a door_hinge in another dimesion"
                                    end)
                      end)

             has_item(item do
                        name :vent
                        short_desc 'loose vent cover'

                        is static

                        contains(item do
                                   name :metal_chunk
                                   short_desc 'chunk of metal'

                                   isnt static
                                 end)
                      end)

             has_item(item do
                        name :locked_door
                        short_desc 'locked door'

                        is static

                        responds_to(command do
                                      verbs %w(open unlock)
                                      takes_and_destroys :skeleton_key
                                      destroys :locked_door
                                      creates_exit :hallway
                                    end)
                      end)
           end)
end
