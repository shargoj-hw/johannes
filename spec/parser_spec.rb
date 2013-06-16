require 'parslet/rig/rspec'

require 'command_parser'

describe CommandParser do
  let(:parser) {CommandParser.new}

  context 'simple commands' do
    it 'should parse a take command' do
      parser.take.should parse("take the fist")
    end

    it 'should parse a take command with a container' do
      parser.take.should parse("grab gummies from the bum")
    end

    it 'should parse a put command' do
      parser.put.should parse("drop the weapon")
    end

    it 'should parse a put command with a container' do
      parser.put.should parse("drop the money in the hole")
      parser.put.should parse("drop the money into the hole")
    end

    it 'should parse a move command' do
      parser.move.should parse("go to east")
      parser.move.should parse("walk bedroom")
      parser.move.should parse("run to the ballroom")
      parser.move.should parse("exit to florida")
      parser.move.should parse("move into the car")
    end

    it 'should parse a describe command' do
      parser.describe.should parse("describe the chumbucket")
    end
  end

  context 'full sentences' do
    it 'should parse one word sentences' do
      parser.sentence.should parse("dance")
    end

    it 'should parse sentences with one object' do
      parser.sentence.should parse("dance with the cat")
    end

    it 'should parse verb->noun sentences' do
      parser.sentence.should parse("alchemize with the necronomicon and fluffy")
    end
  end

end
