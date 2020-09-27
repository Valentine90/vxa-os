class RPG::Animation::Timing
  def initialize
    @frame = 0
    @se = RPG::SE.new('', 80)
    @flash_scope = 0
    @flash_color = Color.new(255, 255, 255, 255)
    @flash_duration = 5
  end

  attr_accessor :frame
  attr_accessor :se
  attr_accessor :flash_scope
  attr_accessor :flash_color
  attr_accessor :flash_duration
end