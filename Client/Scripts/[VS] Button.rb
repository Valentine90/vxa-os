#==============================================================================
# ** Button
#------------------------------------------------------------------------------
#  Esta classe lida com o botão padrão.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Button < Control
  
  attr_reader   :enable
  
  def initialize(win, x, y, text, width = 0, &block)
    @bitmap = Cache.button('Default')
    super(win, x, y, width > 0 ? width : text_width(text) + 16, @bitmap.height)
    @text = text
    @block = block
    @last_area = false
    refresh
  end
  
  def text=(text)
    @text = text
    refresh
  end
  
  def refresh
    @back.bitmap.clear
    @last_area = in_area?
    fill_background(@bitmap, @last_area ? 18 : 0)
    @back.bitmap.draw_text(@back.bitmap.rect, @text, 1)
  end
  
  def update
    super
    refresh if in_area? != @last_area && @back.visible && @enable && !dragging
  end
  
end
