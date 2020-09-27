#==============================================================================
# ** Sprite_Cursor
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição do cursor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_Cursor
  
  attr_reader   :object
  attr_reader   :type
  attr_accessor :sprite_index
  
  def initialize
    @cursor_sprite = Sprite.new
    @cursor_sprite.bitmap = Cache.system('Cursor')
    @cursor_sprite.z = 999
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
    @item_sprite.x = @cursor_sprite.x - 13
    @item_sprite.y = @cursor_sprite.y - 13
    @item_sprite.z = @cursor_sprite.z - 1
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
    @cursor_sprite.src_rect.set(@cursor_sprite.bitmap.width / 5 * @sprite_index, 0, @cursor_sprite.bitmap.width / 5, @cursor_sprite.bitmap.height)
    @cursor_sprite.x = Mouse.x
    @cursor_sprite.y = Mouse.y
    if @item_sprite
      @item_sprite.x = @cursor_sprite.x - 13
      @item_sprite.y = @cursor_sprite.y - 13
    end
    update_drag
  end
  
  def update_drag
    return if Mouse.press?(:L) || !@object
    change_item(nil, Enums::Mouse::NONE)
  end
  
end
