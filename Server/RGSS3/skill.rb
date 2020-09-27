#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Skill < RPG::UsableItem
  def initialize
    super
    @scope = 1
    @stype_id = 1
    @mp_cost = 0
    @tp_cost = 0
    @message1 = ''
    @message2 = ''
    @required_wtype_id1 = 0
    @required_wtype_id2 = 0
  end

  attr_accessor :stype_id
  attr_accessor :mp_cost
  attr_accessor :tp_cost
  attr_accessor :message1
  attr_accessor :message2
  attr_accessor :required_wtype_id1
  attr_accessor :required_wtype_id2
end