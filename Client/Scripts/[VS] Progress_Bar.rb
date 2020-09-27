#==============================================================================
# ** Progress_Bar
#------------------------------------------------------------------------------
#  Esta classe lida com a barra de progresso.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Progress_Bar < Control
  
  attr_accessor :index
  
  def initialize(win, x, y, width, max = 100, index = 0)
    @bitmap = Cache.system('ProgressBar')
    win ? super(win, x, y, width, @bitmap.height) : create_background(x, y, width, @bitmap.height)
    @max = max
    @index = index
  end
  
  def create_background(x, y, width, height)
    @back = Sprite.new
    @back.bitmap = Bitmap.new(width, height)
    @back.x = x
    @back.y = y
    @back.z = 50
    @enable = true
    @win = nil
    @x = x
    @y = y
  end
  
  def width=(width)
    return if width == self.width
    visible = self.visible
    dispose
    initialize(@win, @x, @y, width, @max, @index)
    self.visible = visible
  end
  
  def text=(text)
    @text = text
    refresh
  end
  
  def refresh
    @back.bitmap.clear
    fill_background(@bitmap)
    @back.bitmap.stretch_blt(Rect.new(1, 0, (width - 2) * @index / @max, @bitmap.height), @bitmap, Rect.new(19, 0, 16, @bitmap.height))
    @back.bitmap.draw_text(@back.bitmap.rect, @text, 1)
  end
  
  def update
    super if @win
  end
  
end
