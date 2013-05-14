require "gameobj.rb"

describe 'game object creation' do
  specify 'create a simple object' do
    wrench_desc = "A rust-stained metal wrench."
    wrench = object do
      has_qualities :holdable, :throwable, :weapon
      short_description wrench_desc
    end

    [:holdable, :throwable, :weapon].each do |quality|
      expect(wrench).to include quality
    end

    expect(wrench.short_description).to eq wrench_desc
  end
end
