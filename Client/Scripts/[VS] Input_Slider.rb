#==============================================================================
# ** Input_Slider
#------------------------------------------------------------------------------
#  Esta classe lida com o controle deslizante.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Input_Slider < Control
  
  attr_reader   :index
  
  def initialize(win, x, y, width, &block)
    @bitmap = Cache.system('InputSlider')
    super(win, x, y, width, @bitmap.height)
    @block = block
    @last_area = false
    @slider_ox = 4
    @slider_x = 0
    @index = 0
    create_slider
    refresh
  end
  
  def create_slider
    @slider = Sprite.new
    @slider.bitmap = @bitmap
    @slider.z = @back.z + 1
    @slider.visible = @back.visible
    update
  end
  
  def slider_width
    14
  end
  
  def in_slider_area?
    in_area?(@slider_x, 0, slider_width, height)
  end
  
  def dispose
    super
    @slider.bitmap.dispose
    @slider.dispose
  end
  
  def visible=(visible)
    super
    @slider.visible = visible
  end
  
  def slider_x=(x)
    @slider_x = [[x - slider_width / 2, 0].max, width - slider_width].min
    @index = @slider_x * 100 / (width - slider_width)
  end
  
  def index=(index)
    @index = index
    @slider_x = @index * (width - slider_width) / 100
  end
  
  def refresh
    @back.bitmap.stretch_blt(@back.bitmap.rect, @bitmap, Rect.new(0, 0, 4, height))
  end
  
  def refresh_slider
    @last_area = in_slider_area?
    @slider_ox = @last_area ? 18 : 4
  end
  
  def click
    self.slider_x = Mouse.x - @back.x
    super
  end
  
  def update
    super
    update_dragging
    @slider.x = @back.x + @slider_x
    @slider.y = @back.y
    refresh_slider if in_slider_area? != @last_area && @back.visible && !dragging
    @slider.src_rect.set(@slider_ox, 0, slider_width, height)
  end
  
  def update_dragging
    return unless Mouse.press?(:L)
    return unless in_area?
    return if dragging
    # Desliza sem ficar reproduzindo o som play_ok
    #no block, submétodo do click
    self.slider_x = Mouse.x - @back.x
    @block.call if @block
    self.active = true
  end
  
end
