#==============================================================================
# ** RPG::Event::Page
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Event::Page
  def initialize
    @condition = RPG::Event::Page::Condition.new
    @graphic = RPG::Event::Page::Graphic.new
    @move_type = 0
    @move_speed = 3
    @move_frequency = 3
    @move_route = RPG::MoveRoute.new
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @through = false
    @priority_type = 0
    @trigger = 0
    @list = [RPG::EventCommand.new]
  end

  attr_accessor :condition
  attr_accessor :graphic
  attr_accessor :move_type
  attr_accessor :move_speed
  attr_accessor :move_frequency
  attr_accessor :move_route
  attr_accessor :walk_anime
  attr_accessor :step_anime
  attr_accessor :direction_fix
  attr_accessor :through
  attr_accessor :priority_type
  attr_accessor :trigger
  attr_accessor :list
end