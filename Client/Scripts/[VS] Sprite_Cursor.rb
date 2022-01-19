#==============================================================================
# ** Sprite_Cursor
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do cursor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Cursor < Sprite
  
  attr_reader   :object
  attr_reader   :type
  attr_accessor :sprite_index
  
  def initialize
    super
    self.bitmap = Cache.system('Cursor')
    self.z = 999
    @type = Enums::Mouse::NONE
    @sprite_index = Enums::Cursor::NONE
    @item_sprite = nil
    @object = nil
    update
  end
  
  def create_item
    @item_sprite = Sprite.new
    @item_sprite.bitmap = Bitmap.new(24, 24)
    bitmap = Cache.system('Iconset')
    rect = Rect.new(@object.icon_index % 16 * 24, @object.icon_index / 16 * 24, 24, 24)
    @item_sprite.bitmap.blt(0, 0, bitmap, rect)
    # Define imediatamente as coordenadas x e y
    @item_sprite.x = self.x - 13
    @item_sprite.y = self.y - 13
    @item_sprite.z = self.z - 1
  end
  
  def dispose_item
    @item_sprite.bitmap.dispose
    @item_sprite.dispose
    @item_sprite = nil
  end
  
  def change_item(object, type)
    @object = object
    @type = type
    if @object
      create_item
    else
      dispose_item
    end
  end
  
  def update
    super
    self.src_rect.set(self.bitmap.width / 5 * @sprite_index, 0, self.bitmap.width / 5, self.bitmap.height)
    self.x = Mouse.x
    self.y = Mouse.y
    if @item_sprite
      @item_sprite.x = self.x - 13
      @item_sprite.y = self.y - 13
    end
    update_drag
  end
  
  def update_drag
    return if Mouse.press?(:L) || !@object
    change_item(nil, Enums::Mouse::NONE)
  end
  
end
