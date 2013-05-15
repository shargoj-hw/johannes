require 'builder_builder.rb'

describe 'building builders' do
  specify "a builder's default attributes are single objects" do
    build = Proc.new do
      validate
      @req
    end

    TestBuilder = builder(build) do
      required :req
    end

    def test &block
      Docile.dsl_eval(TestBuilder.new, &block).build
    end

    foostring = test {req "foo"}

    expect(foostring).to eq "foo"
  end

  specify 'a builder has a default build function' do
    TestBuilder2 = builder {required :req, :req2}

    def test &block
      Docile.dsl_eval(TestBuilder2.new, &block).build
    end

    default_build_map = test {
      req "val"
      req2 "number"
    }

    expect(default_build_map.length).to be(2)
    expect(default_build_map).to be_an_instance_of(Hash)
    expect(default_build_map[:req]).to eq("val")
  end

  specify 'a builder can have a default valued attribute' do
    TestDefaultBuilder = builder {defaulted :three, 3}
    def test &block
      Docile.dsl_eval(TestDefaultBuilder.new, &block).build
    end

    defaulted = test {}

    expect(defaulted[:three]).to be(3)
  end
end
