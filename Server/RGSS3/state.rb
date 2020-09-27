#==============================================================================
# ** RPG::State
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::State < RPG::BaseItem
  def initialize
    super
    @restriction = 0
    @priority = 50
    @remove_at_battle_end = false
    @remove_by_restriction = false
    @auto_removal_timing = 0
    @min_turns = 1
    @max_turns = 1
    @remove_by_damage = false
    @chance_by_damage = 100
    @remove_by_walking = false
    @steps_to_remove = 100
    @message1 = ''
    @message2 = ''
    @message3 = ''
    @message4 = ''
  end

  attr_accessor :restriction
  attr_accessor :priority
  attr_accessor :remove_at_battle_end
  attr_accessor :remove_by_restriction
  attr_accessor :auto_removal_timing
  attr_accessor :min_turns
  attr_accessor :max_turns
  attr_accessor :remove_by_damage
  attr_accessor :chance_by_damage
  attr_accessor :remove_by_walking
  attr_accessor :steps_to_remove
  attr_accessor :message1
  attr_accessor :message2
  attr_accessor :message3
  attr_accessor :message4
end