#==============================================================================
# ** Mouse
#------------------------------------------------------------------------------
#  Este módulo lida com funções extras do dispositivo de 
# mouse do RGD.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Mouse
  
  def self.tile_x
    # Corrige o display_x, já que a tela pode se mover
    #16 em vez de 32 pixel na horizontal se a largura da
    #resolução for superior a 1000
    x = $game_map.display_x > 0 && $game_map.display_x > $game_map.display_x.to_i ? self.x + 16 : self.x
    (x / 32 + $game_map.display_x).to_i
  end
  
  def self.tile_y
    (self.y / 32 + $game_map.display_y).to_i
  end
  
  def self.in_tile?(object)
    object.x == tile_x && object.y == tile_y
  end
  
  def self.repeat?(key)
    return Input.repeat?(:LBUTTON) if key == :L
    return Input.repeat?(:RBUTTON) if key == :R
  end
  
end
