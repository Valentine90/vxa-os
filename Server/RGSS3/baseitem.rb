#==============================================================================
# ** RPG::BaseItem
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::BaseItem
  def initialize
    @id = 0
    @name = ''
    @icon_index = 0
    @description = ''
    @features = []
    @note = ''
  end

  attr_accessor :id
  attr_accessor :name
  attr_accessor :icon_index
  attr_accessor :description
  attr_accessor :features
  attr_accessor :note
end