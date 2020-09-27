#==============================================================================
# ** RPG::UsableItem::Effect
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::UsableItem::Effect
  def initialize(code = 0, data_id = 0, value1 = 0, value2 = 0)
    @code = code
    @data_id = data_id
    @value1 = value1
    @value2 = value2
  end

  attr_accessor :code
  attr_accessor :data_id
  attr_accessor :value1
  attr_accessor :value2
end