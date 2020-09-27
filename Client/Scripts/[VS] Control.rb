#==============================================================================
# ** Control
#------------------------------------------------------------------------------
#  Esta é a superclasse de todos os elementos de interface
# gráfica.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Control
  
  attr_reader   :active
  
  def initialize(win, x, y, width, height = line_height)
    @win = win
    @x = x
    @y = y
    @back = Sprite.new
    if width.is_a?(Bitmap)
      @back.bitmap = width
    else
      @back.bitmap = Bitmap.new(width, height)
    end
    @back.x = @win.x + @x
    @back.y = @win.y + @y
    @back.z = @win.z + 1
    @back.visible = @win.visible
    @back.opacity = 192
    @win.controls << self
    @enable = true
    @active = false
    @block = nil
  end
  
  def dispose
    @back.bitmap.dispose
    @back.dispose
  end
  
  def visible=(visible)
    @back.visible = visible
  end
  
  def visible
    @back.visible
  end
  
  def active=(active)
    @active = active
  end
  
  def enable=(enable)
    @back.opacity = enable ? 192 : 100
    @enable = enable
  end
  
  def x=(x)
    @back.x = x
  end
  
  def y=(y)
    @back.y = y
  end
  
  def width
    @back.bitmap.width
  end
  
  def height
    @back.bitmap.height
  end
  
  def line_height
    18
  end
  
  def in_area?(x = 0, y = 0, w = width, h = height)
    Mouse.x >= @back.x + x && Mouse.x <= @back.x + x + w && Mouse.y >= @back.y + y && Mouse.y <= @back.y + y + h
  end
  
  def dragging
    $dragging_window || $cursor.object
  end
  
  def text_width(str)
    b = Bitmap.new(1, 1)
    wth = b.text_size(str).width
    b.dispose
    wth
  end
  
  def fill_background(bitmap, x = 0)
    @back.bitmap.blt(0, 0, bitmap, Rect.new(x, 0, 4, height))
    @back.bitmap.stretch_blt(Rect.new(4, 0, width - 8, height), bitmap, Rect.new(x + 4, 0, 10, height))
    @back.bitmap.blt(width - 4, 0, bitmap, Rect.new(x + 14, 0, 4, height))
  end
  
  def update
    @back.x = @win.x + @x
    @back.y = @win.y + @y
    update_trigger if visible
  end
  
  def update_trigger
    return unless Mouse.click?(:L)
    if in_area? && @enable
      click
    # Se não está na área, mas está ativo
    elsif @active
      out_click
    end
  end
  
  def click
    block if @block
    self.active = true
  end
  
  def block
    Sound.play_ok
    @block.call
  end
  
  def out_click
    self.active = false
  end
  
end
