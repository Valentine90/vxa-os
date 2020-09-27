#==============================================================================
# ** RPG::UsableItem::Damage
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::UsableItem::Damage
  def initialize
    @type = 0
    @element_id = 0
    @formula = '0'
    @variance = 20
    @critical = false
  end

  def none?
    @type == 0
  end

  def to_hp?
    [1, 3, 5].include?(@type)
  end

  def to_mp?
    [2, 4, 6].include?(@type)
  end

  def recover?
    [3, 4].include?(@type)
  end

  def drain?
    [5, 6].include?(@type)
  end

  def sign
    recover? ? -1 : 1
  end

  def eval(a, b, v)
    [Kernel.eval(@formula), 0].max * sign rescue 0
  end

  attr_accessor :type
  attr_accessor :element_id
  attr_accessor :formula
  attr_accessor :variance
  attr_accessor :critical
end