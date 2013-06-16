# TODO: Decouple the model from twitter
class MongoModel
  def initialize db
    @db = db
  end

  # Get the story's state for the given twitter id. If there is no
  # story associated with the id, the database is updated with the
  # initial state of the story.
  def get_story initial_story, twitter_id
    player_story = stories.find_one('twitter_id' => twitter_id)

    if player_story.nil?
      state = initial_story.gamestate
      stories.insert(make_player_story(twitter_id, state))

      initial_story
    else
      gs = gamestate_from_mongo(initial_story.gamestate, player_story['story'])
      initial_story.with_gamestate gs
    end
  end

  # Update the story for the given twitter id.
  def update_story! twitter_id, gamestate
    stories.update({'twitter_id'=>twitter_id},
                   make_player_story(twitter_id, gamestate))
  end

  private
  def stories
    @db['stories_in_progress']
  end

  def gamestate_to_mongo state
    mongo_items = {}
    state.items.each{|i| mongo_items[i.name] = i.items}

    mongo_rooms = {}
    state.rooms.each{|r| mongo_rooms[r.name] = r.items}

    mongo_player_items = state.player.items

    {
      'items' => mongo_items,
      'rooms' => mongo_rooms,
      'current_room' => state.current_room.name,
      'player_items' => mongo_player_items
    }
  end

  def gamestate_from_mongo initial, mongo_data
    items = initial.items.map {|i|
      items = (i.is_container? ?
               (mongo_data['items'][i.name.to_s]) : nil)
      i.new_with_items items
    }

    rooms = initial.rooms.map {|r|
      r.new_with_items(mongo_data['rooms'][r.name.to_s])
    }

    current_room = mongo_data['current_room']

    player = initial.player.new_with_items mongo_data['player_items']

    GameState.new items, rooms, current_room, player
  end

  def make_player_story twitter_id, gamestate
    {'twitter_id'=>twitter_id, 'story'=>gamestate_to_mongo(gamestate)}
  end
end
