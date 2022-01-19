#==============================================================================
# ** Sprite
#------------------------------------------------------------------------------
#  Esta é a superclasse de alguns objetos gráficos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Bitmap
  
  alias vxaos_draw_text draw_text
  
  # Corrige a compressão de texto do RGD
  def draw_text(*args)
    if args[5] && args[5] == 1
      args[2] += 20
      args[0] -= 9
    end
    vxaos_draw_text(*args)
  end
  
end

#==============================================================================
# ** Sprite2
#==============================================================================
class Sprite2 < Sprite
  
  attr_writer   :dragable
  
  def initialize(viewport = nil)
    super(viewport)
    @dragable = false
    @dif_x = nil
    @dif_y = nil
  end
  
  def in_area?(x = 0, y = 0, w = self.bitmap.width, h = self.bitmap.height)
    Mouse.x >= self.x + x && Mouse.x <= self.x + x + w && Mouse.y >= self.y + y && Mouse.y <= self.y + y + h
  end
  
  def in_player_area?(x, y)
    x = (self.x + x) / 32 + $game_map.display_x
    y = (self.y + y) / 32 + $game_map.display_y
    $game_player.x >= x && $game_player.x <= x + self.bitmap.width / 32 && $game_player.y >= y && $game_player.y <= y + self.bitmap.height / 32
  end
  
  def change_opacity(x = 0, y = 0)
    self.opacity = in_player_area?(x, y) ? 50 : 255
  end
  
  def text_color(n)
    windowskin = Cache.system('Window')
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  
  def normal_color
    text_color(0)
  end
  
  def system_color
    text_color(16)
  end
  
  def crisis_color
    text_color(17)
  end
  
  def text_width(str)
    b = Bitmap.new(1, 1)
    wth = b.text_size(str).width
    b.dispose
    wth
  end
  
  def format_number(value)
    value.to_s.reverse.scan(/...|..|./).join('.').reverse
  end
  
  def update
    super
    return unless @dragable
    update_dragging
    $dragging_window = Mouse.press?(:L) ? in_area? && !$dragging_window ? self : $dragging_window : nil
  end
  
  def update_dragging
    return if $cursor.object
    if $dragging_window == self
      self.x = Mouse.x - @dif_x
      self.y = Mouse.y - @dif_y
    else
      @dif_x = Mouse.x - self.x
      @dif_y = Mouse.y - self.y
    end
  end
  
end

#==============================================================================
# ** Color
#==============================================================================
class Color
  
  White = self.new(255, 255, 255)
  Black = self.new(0, 0, 0)
  Red = self.new(255, 120, 76)
  Green = self.new(0, 224, 96)
  Yellow = self.new(255, 255, 0)
  Blue = self.new(0, 162, 232)
  
end
