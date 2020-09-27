#==============================================================================
# ** Sprite_Popup
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do item e ouro obtidos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Popup < Sprite2
  
  def initialize
    super
    self.bitmap = Bitmap.new(225, 24)
    self.x = 11
    self.z = 50
    self.visible = false
  end
  
  def show(name, icon_index, amount, key = false)
    self.y = $game_actors[1].party_members.empty? ? 120 : $game_actors[1].party_members.size * 35 + 163
    self.y += 42 if $windows[:states].visible
    @text = amount > 1 ? "#{name} x#{convert_gold(amount)}" : name
    @width = text_width(@text) + 40
    @icon_index = icon_index
    @key = key
    self.visible = true
    @time = 60
    refresh
  end
  
  def refresh
    draw_background
    draw_item
  end
  
  def draw_background
    self.bitmap.clear
    rect = Rect.new(0, 0, @width, self.bitmap.height)
    self.bitmap.fill_rect(rect, Color.new(0, 0, 0, 160))
  end
  
  def draw_item
    rect = Rect.new(@icon_index % 16 * 24, @icon_index / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')
    self.bitmap.blt(5, 0, bitmap, rect)
    color = @key ? crisis_color : normal_color
    self.bitmap.font.color.set(color)
    self.bitmap.draw_text(35, 3, self.bitmap.width, 18, @text)
  end
  
  def update
    super
    @time -= 1
    self.visible = false if @time == 0
  end
  
end
