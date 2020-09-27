#==============================================================================
# ** RPG::System::Vehicle
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::System::Vehicle
  def initialize
    @character_name = ''
    @character_index = 0
    @bgm = RPG::BGM.new
    @start_map_id = 0
    @start_x = 0
    @start_y = 0
  end

  attr_accessor :character_name
  attr_accessor :character_index
  attr_accessor :bgm
  attr_accessor :start_map_id
  attr_accessor :start_x
  attr_accessor :start_y
end