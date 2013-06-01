require 'gamestate'

# TODO: Add real requirement system
class Command
  attr_reader :verbs, :on_success
  def initialize
    @verbs = []
    @on_success = nil

    @requirements = []
    @creates_connections = []
    @moves_player_to = nil

    @player_adds = []
    @room_adds = Hash.new {|h, k| h[k]=[]}
    @container_adds = Hash.new {|h, k| h[k]=[]}

    @player_deletes = []
    @room_deletes = Hash.new {|h, k| h[k]=[]}
    @container_deletes = Hash.new {|h, k| h[k]=[]}
  end

  def command_verbs verbs
    @verbs = verbs
  end

  def tells_player phrase
    @on_success = phrase
  end

  ########################################
  ### Core Sub-Commands
  ########################################
  def requires *requirements; @requirements.concat requirements; end
  def moves_player_to room; @moves_player_to = room; end
  def creates_connection rooms; @creates_connections << rooms; end

  def gives_to_player item; @player_adds << item; end
  def gives_to_room room, item; @room_adds[room] << item; end
  def gives_to_container container, item
    @container_adds[container] = item
  end

  def removes_from_player item; @player_deletes << item; end
  def removes_from_room room, item; @room_deletes[room] << item; end
  def removes_from_container container, item
    @container_deletes[container] << item
  end




  def can_run? gamestate
    has_response = !@on_success.nil?
    requirements_met = @requirements.all? {|req| gamestate.player.items.includes? req}

    has_response && requirements_met
  end

  def run_command gs
    raise CommandCantRun unless can_run? gs

    gs = @creates_connections.reduce(gs) {|state, item|
      state.creates_connections(*item)
    }

    gs = @player_adds.reduce(gs) {|state, item|
      state.player_create item
    }
    gs = @room_adds.reduce(gs) {|state, room_tuple|
      room, items = room_tuple
      items.reduce(state) {|s, i| s.room_create room, i}
    }
    gs = @container_adds.reduce(gs) {|state, container_tuple|
      container, items = container_tuple
      items.reduce(state) {|s, i| s.container_create container, i}
    }

    gs = @player_deletes.reduce(gs) {|state, item|
      state.player_destroy item
    }
    gs = @room_deletes.reduce(gs) {|state, room_tuple|
      room, items = room_tuple
      items.reduce(state) {|s, i| s.room_destroy room, i}
    }
    gs = @container_deletes.reduce(gs) {|state, container_tuple|
      container, items = container_tuple
      items.reduce(state) {|s, i| s.container_destroy container, i}
    }


    if @moves_player_to
        gs = GameState.new gs.items, gs.rooms, @moves_player_to, gs.player
    end

    gs
  end
end
