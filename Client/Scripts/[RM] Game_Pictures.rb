#==============================================================================
# ** Game_Pictures
#------------------------------------------------------------------------------
#  Esta classe gerencia as imagens. Esta classe é utilizada dentro da classe
# Game_Screen. Imagens de mapa e batalha são tratadas separadamente
#==============================================================================

class Game_Pictures
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Aquisição de informação da ID da imagens
  #     number : ID da imagens
  #--------------------------------------------------------------------------
  def [](number)
    @data[number] ||= Game_Picture.new(number)
  end
  #--------------------------------------------------------------------------
  # * Iteradores
  #--------------------------------------------------------------------------
  def each
    @data.compact.each {|picture| yield picture } if block_given?
  end
end
