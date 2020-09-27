#==============================================================================
# ** Sprite_Drop
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do drop.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Drop < Sprite2
  
  attr_reader   :character
  
  def initialize(viewport, character)
    super(viewport)
    @character = character
    self.bitmap = Bitmap.new(24, 24)
    bitmap = Cache.system('Iconset')
    rect = Rect.new(@character.icon_index % 16 * 24, @character.icon_index / 16 * 24, 24, 24)
    self.bitmap.blt(0, 0, bitmap, rect)
    #@count = 0
    create_name
    update
  end
  
  def dispose
    super
    @name_sprite.bitmap.dispose
    @name_sprite.dispose
  end
  
  def visible=(visible)
    super
    @name_sprite.visible = visible
  end
  
  def create_name
    @name_sprite = Sprite.new
    @name_sprite.bitmap = Bitmap.new(text_width(@character.name), 15)
    @name_sprite.bitmap.font.size = 15
    color = @character.key_item? ? crisis_color : normal_color
    @name_sprite.bitmap.font.color.set(color)
    @name_sprite.bitmap.draw_text(@name_sprite.bitmap.rect, @character.name, 1)
    @name_sprite.z = self.z + 50
    @name_sprite.visible = false
  end
  
  def update
    super
    self.x = (@character.real_x - $game_map.display_x) * 32
    self.y = (@character.real_y - $game_map.display_y) * 32
    #move_y
    @name_sprite.x = self.x + 12 - (@name_sprite.bitmap.width / 2)
    @name_sprite.y = self.y - 18
    @name_sprite.visible = in_area? && !$dragging_window && !$cursor.object
  end
=begin
  def move_y
    @count += 1
    if @count < 50
      self.y -= @count / 10
    elsif @count >= 50 && @count <= 100
      self.y = self.y - 5 + (@count - 50) / 10
    else
      @count = 0
    end
  end
=end
end
