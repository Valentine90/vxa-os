#==============================================================================
# ** RPG::Item
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Item < RPG::UsableItem
  def initialize
    super
    @scope = 7
    @itype_id = 1
    @price = 0
    @consumable = true
    # VXA-OS
    @soulbound = false
  end

  def key_item?
    @itype_id == 2
  end

  def soulbound?
    @soulbound
  end

  attr_accessor :itype_id
  attr_accessor :price
  attr_accessor :consumable
  # VXA-OS
  attr_accessor :soulbound
end