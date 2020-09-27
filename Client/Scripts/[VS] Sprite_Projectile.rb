#==============================================================================
# ** Sprite_Projectile
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do projétil.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Projectile < Sprite
  
  def initialize(viewport, character)
    super(viewport)
    @character = character
    self.bitmap = Cache.projectile(@character.projectile_name)
    @width = character.step_anime ? self.bitmap.width / 4 : self.bitmap.width
    self.angle = @character.angle
    self.x = @real_x = @character.x
    self.y = @real_y = @character.y
    self.ox = @width / 2
    self.oy = self.bitmap.height
    @range_x = (@character.finish_x - @character.x).abs
    @range_y = (@character.finish_y - @character.y).abs
    @range_x -= 1 if @range_x > 0
    @range_y -= 1 if @range_y > 0
    @anime_count = 0
    @pattern = 0
  end
  
  def destroy?
    (@character.x - @real_x).abs > @range_x || (@character.y - @real_y).abs > @range_y
  end
  
  def update
    super
    update_coordinates
    update_animation
  end
  
  def update_coordinates
    # Soma valores decimais
    @real_x += @character.speed_x
    @real_y += @character.speed_y
    self.x = (@real_x - $game_map.display_x) * 32
    self.y = (@real_y - $game_map.display_y) * 32
  end
  
  def update_animation
    @anime_count += 1
    if @character.step_anime && @anime_count >= 10
      @pattern = (@pattern + 1) % 4
      @anime_count = 0
    end
    self.src_rect.set(@pattern * @width, 0, @width, self.bitmap.height)
  end
  
end
