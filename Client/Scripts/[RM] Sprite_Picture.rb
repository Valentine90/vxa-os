#==============================================================================
# ** Sprite_Picture
#------------------------------------------------------------------------------
#  Este sprite é usado para exibir imagens. Ele observa uma instância
# da classe Game_Picture e automaticamente muda as condições do sprite.
#==============================================================================

class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     viewport : camada
  #     picture : imagem (Game_Picture)
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    update
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    update_origin
    update_position
    update_zoom
    update_other
  end
  #--------------------------------------------------------------------------
  # * Atualização do bitmap de origem
  #--------------------------------------------------------------------------
  def update_bitmap
    self.bitmap = Cache.picture(@picture.name)
  end
  #--------------------------------------------------------------------------
  # * Atualização da origem
  #--------------------------------------------------------------------------
  def update_origin
    if @picture.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = bitmap.width / 2
      self.oy = bitmap.height / 2
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da posição
  #--------------------------------------------------------------------------
  def update_position
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number
  end
  #--------------------------------------------------------------------------
  # * Atualização do zoom
  #--------------------------------------------------------------------------
  def update_zoom
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
  end
  #--------------------------------------------------------------------------
  # * Atualizações variadas
  #--------------------------------------------------------------------------
  def update_other
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    self.angle = @picture.angle
    self.tone.set(@picture.tone)
  end
end
