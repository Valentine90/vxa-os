#==============================================================================
# ** Image_Button
#------------------------------------------------------------------------------
#  Esta classe lida com o botão por imagem.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Image_Button < Control
  
  def initialize(win, x, y, image, &block)
    super(win, x, y, Cache.button(image))
    @block = block
    @last_area = false
    @back_ox = 0
  end
  
  def width
    @back.bitmap.width / 2
  end
  
  def refresh
    @last_area = in_area?
    @back_ox = @last_area ? width : 0
  end
  
  def update
    super
    refresh if in_area? != @last_area && @back.visible && @enable && !dragging
    @back.src_rect.set(@back_ox, 0, width, height)
  end
  
end
