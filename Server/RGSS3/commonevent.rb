#==============================================================================
# ** RPG::CommonEvent
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::CommonEvent
  def initialize
    @id = 0
    @name = ''
    @trigger = 0
    @switch_id = 1
    @list = [RPG::EventCommand.new]
  end

  def autorun?
    @trigger == 1
  end

  def parallel?
    @trigger == 2
  end

  attr_accessor :id
  attr_accessor :name
  attr_accessor :trigger
  attr_accessor :switch_id
  attr_accessor :list
end