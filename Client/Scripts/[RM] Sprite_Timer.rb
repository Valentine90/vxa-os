#==============================================================================
# ** Sprite_Timer
#------------------------------------------------------------------------------
#  Este sprite é usado para exibir o cronômetro. Ele observa o $game_timer
# e automaticamente muda as condições do sprite.
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     viewport : camada
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    create_bitmap
    update
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Criação do bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(96, 48)
    self.bitmap.font.size = 32
    self.bitmap.font.color.set(255, 255, 255)
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    update_position
    update_visibility
  end
  #--------------------------------------------------------------------------
  # * Atualização do bitmap de origem
  #--------------------------------------------------------------------------
  def update_bitmap
    if $game_timer.sec != @total_sec
      @total_sec = $game_timer.sec
      redraw
    end
  end
  #--------------------------------------------------------------------------
  # * Redesenhar
  #--------------------------------------------------------------------------
  def redraw
    self.bitmap.clear
    self.bitmap.draw_text(self.bitmap.rect, timer_text, 1)
  end
  #--------------------------------------------------------------------------
  # * Criação do texto do cronômetro
  #--------------------------------------------------------------------------
  def timer_text
    sprintf("%02d:%02d", @total_sec / 60, @total_sec % 60)
  end
  #--------------------------------------------------------------------------
  # * Atualização da posição
  #--------------------------------------------------------------------------
  def update_position
    self.x = Graphics.width - self.bitmap.width
    self.y = 0
    self.z = 200
  end
  #--------------------------------------------------------------------------
  # * Atualização da visibilidade
  #--------------------------------------------------------------------------
  def update_visibility
    self.visible = $game_timer.working?
  end
end
