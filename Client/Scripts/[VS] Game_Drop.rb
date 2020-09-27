#==============================================================================
# ** Game_Drop
#------------------------------------------------------------------------------
#  Esta classe lida com o drop.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Drop
  
  attr_reader   :name, :icon_index, :x, :y, :real_x, :real_y
  
  def initialize(name, icon_index, key, amount, x, y)
    @name = amount > 1 ? "#{name} x#{amount}" : name
    @icon_index = icon_index
    @key = key
    @x = @real_x = x
    @y = @real_y = y
  end
  
  def key_item?
    @key
  end
  
end
