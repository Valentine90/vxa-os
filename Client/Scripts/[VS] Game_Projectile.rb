#==============================================================================
# ** Game_Projectile
#------------------------------------------------------------------------------
#  Esta classe lida com o projétil.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Projectile
  
  attr_reader   :projectile_name, :step_anime, :x, :y, :finish_x, :finish_y, :angle, :speed_x, :speed_y
  
  def initialize(start_x, start_y, finish_x, finish_y, target_x, target_y, projectile)
    @projectile_name = projectile[:projectile_name]
    @step_anime = projectile[:step_anime]
    @finish_x = finish_x
    @finish_y = finish_y
    @x = start_x
    @y = start_y
    @angle = to_angle(start_x, start_y, target_x, target_y)
    @speed_x = Math.sin(@radians)
    @speed_y = Math.cos(@radians)
  end
  
  def to_angle(start_x, start_y, target_x, target_y)
    # Retorna 0 se o alvo e o projétil estiverem nas
    #mesmas coordenadas x e y, pois, nesta versão do Ruby,
    #o atan2 retorna um erro
    if target_x == start_x && target_y == start_y
      @radians = 0.0
      return 0
    end
    # Converte em ângulo medido em radianos
    @radians = Math.atan2(target_x - start_x, target_y - start_y)
    # Converte radianos em graus
    #57.29577951308232 = 180 / Math::PI
    @radians * 57.29577951308232
  end
  
end
