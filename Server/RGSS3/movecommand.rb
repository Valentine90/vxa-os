#==============================================================================
# ** RPG::MoveCommand
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::MoveCommand
  def initialize(code = 0, parameters = [])
    @code = code
    @parameters = parameters
  end

  attr_accessor :code
  attr_accessor :parameters
end