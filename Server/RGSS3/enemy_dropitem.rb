#==============================================================================
# ** RPG::Enemy::DropItem
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Enemy::DropItem
  def initialize
    @kind = 0
    @data_id = 1
    @denominator = 1
  end

  attr_accessor :kind
  attr_accessor :data_id
  attr_accessor :denominator
end