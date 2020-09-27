#==============================================================================
# ** RPG::Enemy::Action
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Enemy::Action
  def initialize
    @skill_id = 1
    @condition_type = 0
    @condition_param1 = 0
    @condition_param2 = 0
    @rating = 5
  end

  attr_accessor :skill_id
  attr_accessor :condition_type
  attr_accessor :condition_param1
  attr_accessor :condition_param2
  attr_accessor :rating
end