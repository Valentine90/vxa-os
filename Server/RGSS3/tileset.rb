#==============================================================================
# ** RPG::Tileset
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Tileset
  def initialize
    @id = 0
    @mode = 1
    @name = ''
    @tileset_names = Array.new(9).collect { '' }
    @flags = Table.new(8192)
    @flags[0] = 0x0010
    (2048..2815).each { |i| @flags[i] = 0x000F }
    (4352..8191).each { |i| @flags[i] = 0x000F }
    @note = ''
  end

  attr_accessor :id
  attr_accessor :mode
  attr_accessor :name
  attr_accessor :tileset_names
  attr_accessor :flags
  attr_accessor :note
end