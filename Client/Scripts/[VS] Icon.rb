#==============================================================================
# ** Icon
#------------------------------------------------------------------------------
#  Esta classe lida com o ícone.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Icon < Control
  
  def initialize(win, x, y, icon_index, tip_text = '', &block)
    win ? super(win, x, y, 24, 24) : create_background(x, y)
    @icon_index = icon_index
    @tip_text = tip_text
    @block = block
    @back.opacity = 160
    refresh
    create_tool_tip
  end
  
  def create_background(x, y)
    @back = Sprite.new
    @back.bitmap = Bitmap.new(24, 24)
    @back.x = x
    @back.y = y
    @back.z = 50
    @enable = true
    @win = nil
  end
  
  def create_tool_tip
    return if @tip_text.empty?
    @tool_tip = Sprite.new
    @tool_tip.bitmap = Bitmap.new(text_width(@tip_text) + 8, line_height)
    @tool_tip.bitmap.fill_rect(@tool_tip.bitmap.rect, Color.new(0, 0, 0, 160))
    @tool_tip.bitmap.draw_text(@tool_tip.bitmap.rect, @tip_text, 1)
    @tool_tip.z = @back.z
    @tool_tip.visible = false
  end
  
  def dispose
    super
    if @tool_tip
      @tool_tip.bitmap.dispose
      @tool_tip.dispose
    end
  end
  
  def visible=(visible)
    super
    @tool_tip.visible = false if @tool_tip
  end
  
  def refresh
    bitmap = Cache.system('Iconset')
    rect = Rect.new(@icon_index % 16 * 24, @icon_index / 16 * 24, 24, 24)
    @back.bitmap.blt(0, 0, bitmap, rect)
  end
  
  def update
    @win ? super : update_trigger
    @back.opacity = in_area? && !dragging ? 255 : 160
    update_tool_tip
  end
  
  def update_tool_tip
    return unless @tool_tip && visible
    @tool_tip.visible = @back.opacity == 255
    if @tool_tip.visible
      @tool_tip.x = Mouse.x + 18 + @tool_tip.bitmap.width > Graphics.width ? Graphics.width - @tool_tip.bitmap.width :  Mouse.x + 18
      @tool_tip.y = Mouse.y + 18 + @tool_tip.bitmap.height > Graphics.height ? Graphics.height - @tool_tip.bitmap.height : Mouse.y + 18
    end
  end
  
end
