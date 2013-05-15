require "gameobj.rb"

describe 'game object creation' do
  specify 'create a simple object' do
    wrench_desc = "A rust-stained metal wrench."
    wrench = gameobj do
      name :wrench
      qualities :holdable, :throwable, :weapon
      short_desc wrench_desc
    end

    [:holdable, :throwable, :weapon].each do |quality|
      expect(wrench.is? quality).to be_true
    end

    expect(wrench.short_desc).to eq wrench_desc
  end

  specify 'objects are usually static' do
    vault_door = gameobj do
      name :vault_door
      qualities :openable
      short_desc "It looks really heavy."
    end

    vault_door.is_static?.should be_false
  end
end
