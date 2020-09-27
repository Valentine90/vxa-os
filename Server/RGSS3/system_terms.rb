#==============================================================================
# ** RPG::System::Terms
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class RPG::System::Terms
  def initialize
    @basic = Array.new(8) { '' }
    @params = Array.new(8) { '' }
    @etypes = Array.new(5) { '' }
    @commands = Array.new(23) { '' }
  end

  attr_accessor :basic
  attr_accessor :params
  attr_accessor :etypes
  attr_accessor :commands
end