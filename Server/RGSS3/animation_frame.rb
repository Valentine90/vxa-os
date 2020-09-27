class RPG::Animation::Frame
  def initialize
    @cell_max = 0
    @cell_data = Table.new(0, 0)
  end

  attr_accessor :cell_max
  attr_accessor :cell_data
end