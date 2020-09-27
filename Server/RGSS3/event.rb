#==============================================================================
# ** RPG::Event
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::Event
  def initialize(x, y)
    @id = 0
    @name = ''
    @x = x
    @y = y
    @pages = [RPG::Event::Page.new]
  end

  attr_accessor :id
  attr_accessor :name
  attr_accessor :x
  attr_accessor :y
  attr_accessor :pages
end