require_relative './sample_story'

describe 'story' do
  let(:story) { LOCKEDIN }

  describe '#find_local_item' do
    it 'should look at item names' do
      (story.find_local_item 'magic_mirror').should == :magic_mirror
    end

    it 'should look at item descriptions' do
      (story.find_local_item 'foggy mirror')
    end

    it 'should ignore whitespace'
  end
end
