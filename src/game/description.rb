class Description
  attr_reader :name, :short_desc, :long_desc

  def initialize name, short_desc, long_desc
    @name, @short_desc, @long_desc = name, short_desc, long_desc
  end
end
