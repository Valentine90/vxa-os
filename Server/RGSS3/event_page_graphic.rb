#==============================================================================
# ** RPG::Event::Page::Graphic
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Event::Page::Graphic
  def initialize
    @tile_id = 0
    @character_name = ''
    @character_index = 0
    @direction = 2
    @pattern = 0
  end

  attr_accessor :tile_id
  attr_accessor :character_name
  attr_accessor :character_index
  attr_accessor :direction
  attr_accessor :pattern
end