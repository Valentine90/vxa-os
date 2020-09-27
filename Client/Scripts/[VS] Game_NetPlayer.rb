#==============================================================================
# ** Game_NetPlayer
#------------------------------------------------------------------------------
#  Esta classe lida com uma instância de cada um dos demais
# jogador do mapa. Ela contém dados, como direção, coordenadas x e y.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_NetPlayer < Game_Character
  
  def initialize(id)
    super()
    @id = id
    @actor = Game_Actor.new(1)
  end
  
  def refresh
    @character_name = actor.character_name
    @character_index = actor.character_index
  end
  
end
