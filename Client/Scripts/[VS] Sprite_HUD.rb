#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição de HP, MP, experiência,
# face e nível do jogador.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_HUD < Sprite2
  
  attr_reader :exp_sprite
  
  def initialize
    super
    self.bitmap = Bitmap.new(255, 107)
    self.x = 11
    self.y = 9
    self.z = 50
    self.bitmap.font.size = 18
    self.bitmap.font.bold = true
    @back = Cache.system('HUD')
    @bars = Cache.system('HUDBars')
    create_exp_bar
    refresh
    change_opacity
  end
  
  def dispose
    super
    @exp_sprite.bitmap.dispose
    @exp_sprite.dispose
  end
  
  def create_exp_bar
    @exp_sprite = Sprite2.new
    @exp_sprite.bitmap = Bitmap.new(308, 22)
    @exp_sprite.bitmap.font.size = 18
    @exp_sprite.bitmap.font.bold = true
    @exp_sprite.x = adjust_x
    @exp_sprite.y = adjust_y
    @exp_sprite.dragable = true
    @exp_sprite.z = self.z
    @exp_sprite.change_opacity
  end
  
  def adjust_x
    Graphics.width / 2 - 109
  end
  
  def adjust_y
    Graphics.height - 28
  end
  
  def refresh
    draw_background
    draw_face
    draw_hp_bar
    draw_mp_bar
    draw_exp_bar
    draw_level
  end
  
  def draw_background
    self.bitmap.clear
    rect = Rect.new(0, 0, 248, 98)
    self.bitmap.blt(7, 0, @back, rect)
  end
  
  def draw_face
    return if $game_actors[1].face_name.empty?
    face = Cache.face($game_actors[1].face_name)
    rect = Rect.new($game_actors[1].face_index % 4 * 96, $game_actors[1].face_index / 4 * 96, 96, 96)
    self.bitmap.blt(8, 1, face, rect)
  end
  
  def draw_hp_bar
    rect = Rect.new(0, 0, 123 * $game_actors[1].hp / $game_actors[1].mhp, 26)
    self.bitmap.blt(107, 2, @bars, rect)
    self.bitmap.draw_text(111, 7, 25, 18, Vocab::hp_a)
    self.bitmap.draw_text(0, 7, 229, 18, "#{$game_actors[1].hp}/#{$game_actors[1].mhp}", 2)
  end
  
  def draw_mp_bar
    rect = Rect.new(0, 26, 123 * $game_actors[1].mp / $game_actors[1].mmp, 26)
    self.bitmap.blt(107, 30, @bars, rect)
    self.bitmap.draw_text(111, 35, 25, 18, Vocab::mp_a)
    self.bitmap.draw_text(0, 35, 229, 18, "#{$game_actors[1].mp}/#{$game_actors[1].mmp}", 2)
  end
  
  def draw_exp_bar
    @exp_sprite.bitmap.clear
    rect1 = Rect.new(0, 98, @exp_sprite.bitmap.width, @exp_sprite.bitmap.height)
    rect2 = Rect.new(0, 52, 308 * $game_actors[1].now_exp / $game_actors[1].next_exp, @exp_sprite.bitmap.height)
    exp = $game_actors[1].level >= Configs::MAX_LEVEL ? Vocab::MaxLevel : convert_gold($game_actors[1].next_exp - $game_actors[1].now_exp)
    @exp_sprite.bitmap.blt(0, 0, @back, rect1)
    @exp_sprite.bitmap.blt(0, 0, @bars, rect2)
    @exp_sprite.bitmap.draw_text(4, 2, 25, 18, Vocab::Exp)
    @exp_sprite.bitmap.draw_text(0, 2, 308, 18, exp, 1)
  end
  
  def draw_level
    rect = Rect.new(0, 120, 29, 30)
    self.bitmap.blt(0, 77, @back, rect)
    self.bitmap.draw_text(0, 83, 30, 18, $game_actors[1].level, 1)
  end
  
  def update
    super
    @exp_sprite.update
    @exp_sprite.change_opacity
  end
  
end
