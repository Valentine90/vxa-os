#==============================================================================
# ** RPG::System::TestBattler
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::System::TestBattler
  def initialize
    @actor_id = 1
    @level = 1
    @equips = [0, 0, 0, 0, 0]
  end

  attr_accessor :actor_id
  attr_accessor :level
  attr_accessor :equips
end