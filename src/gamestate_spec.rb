require "gamestate.rb"

describe GameState do
  let(:game) do
    wrench = Item.new :wrench
    screw = Item.new :screw
    boulder = Item.new :boulder, nil, true
    bedroom = Room.new :bedroom, [:screw, :boulder], []
    hallway = Room.new :hallway, [], []
    player = Player.new [:wrench]

    GameState.new [wrench, screw], [bedroom, hallway], :bedroom, player
  end

  describe '.current_room' do
    it 'should be the one initialized' do
      game.current_room.name.should == :bedroom
    end
  end

  describe '.take' do
    context 'when the object is in the room' do
      context 'when the object is not static' do
        it 'should remove the object from the room' do
          (game.take :screw).current_room.items.should_not include :screw
        end

        it 'should give the player the object' do
          (game.take :screw).player.items.should include :wrench
        end
      end

      context 'when the object is static' do
        it 'should raise an error' do
          expect {game.take :boulder}.to raise_error
        end
      end
    end

    context 'when the object is not in the room' do
      it 'should raise an error' do
        expect {game.take :pickle}.to raise_error(ItemNotFound)
      end
    end
  end

  describe '.put' do
    context 'when the player has the object' do
      it 'should remove the object from the player' do
        (game.put :wrench).player.items.should_not include :wrench
      end

      it 'should add the object to the room' do
        (game.put :wrench).current_room.items.should include :wrench
      end
    end

    context 'when the player does not have the object' do
      it 'should throw an error' do
        expect {game.put :pickle}.to raise_error(ItemNotFound)
      end
    end
  end

  describe '.create' do
  end

  describe '.destroy' do
    context 'when the item exists locally' do
      it 'should remove it from the player' do
        (game.destroy :wrench).player.items.should_not include :wrench
      end

      it 'should remove it from the current room' do
        (game.destroy :screw).current_room.items.should_not include :screw
      end
    end

    context 'when it does not exist locally' do
      it 'should raise an error' do
        expect {game.destroy :pickle}.to raise_error(ItemNotFound)
      end
    end
  end

  describe '.create_connections' do
    context 'when the rooms exist' do
      it 'should connect the rooms' do
        connected_state = game.create_connections :hallway, :bedroom
        (connected_state.room :hallway).connections.should include :bedroom
        (connected_state.room :bedroom).connections.should include :hallway
      end
    end
  end

  describe '.destroy_connections' do
    context 'when the rooms exist' do
      it 'should connect the rooms' do
        connected = game.create_connections :hallway, :bedroom
        disconnected = connected.destroy_connections :hallway, :bedroom

        (disconnected.room :hallway).connections.should_not include :bedroom
        (disconnected.room :bedroom).connections.should_not include :hallway
      end
    end
  end

end
