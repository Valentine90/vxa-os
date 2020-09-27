#==============================================================================
# ** RPG::MoveRoute
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::MoveRoute
  def initialize
    @repeat = true
    @skippable = false
    @wait = false
    @list = [RPG::MoveCommand.new]
  end

  attr_accessor :repeat
  attr_accessor :skippable
  attr_accessor :wait
  attr_accessor :list
end