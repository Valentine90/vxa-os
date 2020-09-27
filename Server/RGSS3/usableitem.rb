#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  def initialize
    super
    @scope = 0
    @occasion = 0
    @speed = 0
    @success_rate = 100
    @repeats = 1
    @tp_gain = 0
    @hit_type = 0
    @animation_id = 0
    @damage = RPG::UsableItem::Damage.new
    @effects = []
    # VXA-OS
    @range = 0
    @aoe = 0
    @level = 0
    @ani_index = 0
  end

  def for_opponent?
    [1, 2, 3, 4, 5, 6].include?(@scope)
  end

  def for_friend?
    [7, 8, 9, 10, 11].include?(@scope)
  end

  def for_dead_friend?
    [9, 10].include?(@scope)
  end

  def for_user?
    @scope == 11
  end

  def for_one?
    [1, 3, 7, 9, 11].include?(@scope)
  end

  def for_random?
    [3, 4, 5, 6].include?(@scope)
  end

  def number_of_targets
    for_random? ? @scope - 2 : 0
  end

  def for_all?
    [2, 8, 10].include?(@scope)
  end

  def need_selection?
    [1, 7, 9].include?(@scope)
  end

  def battle_ok?
    [0, 1].include?(@occasion)
  end

  def menu_ok?
    [0, 2].include?(@occasion)
  end

  def certain?
    @hit_type == 0
  end

  def physical?
    @hit_type == 1
  end

  def magical?
    @hit_type == 2
  end

  def aoe?
    @aoe > 0
  end

  attr_accessor :scope
  attr_accessor :occasion
  attr_accessor :speed
  attr_accessor :animation_id
  attr_accessor :success_rate
  attr_accessor :repeats
  attr_accessor :tp_gain
  attr_accessor :hit_type
  attr_accessor :damage
  attr_accessor :effects
  # VXA-OS
  attr_accessor :range
  attr_accessor :aoe
  attr_accessor :level
  attr_accessor :ani_index
end