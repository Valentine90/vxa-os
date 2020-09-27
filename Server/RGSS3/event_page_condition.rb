#==============================================================================
# ** RPG::Event::Page::Condition
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Event::Page::Condition
  def initialize
    @switch1_valid = false
    @switch2_valid = false
    @variable_valid = false
    @self_switch_valid = false
    @item_valid = false
    @actor_valid = false
    @switch1_id = 1
    @switch2_id = 1
    @variable_id = 1
    @variable_value = 0
    @self_switch_ch = 'A'
    @item_id = 1
    @actor_id = 1
  end

  attr_accessor :switch1_valid
  attr_accessor :switch2_valid
  attr_accessor :variable_valid
  attr_accessor :self_switch_valid
  attr_accessor :item_valid
  attr_accessor :actor_valid
  attr_accessor :switch1_id
  attr_accessor :switch2_id
  attr_accessor :variable_id
  attr_accessor :variable_value
  attr_accessor :self_switch_ch
  attr_accessor :item_id
  attr_accessor :actor_id
end