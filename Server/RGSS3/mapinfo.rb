#==============================================================================
# ** RPG::MapInfo
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::MapInfo
  def initialize
    @name = ''
    @parent_id = 0
    @order = 0
    @expanded = false
    @scroll_x = 0
    @scroll_y = 0
  end

  attr_accessor :name
  attr_accessor :parent_id
  attr_accessor :order
  attr_accessor :expanded
  attr_accessor :scroll_x
  attr_accessor :scroll_y
end