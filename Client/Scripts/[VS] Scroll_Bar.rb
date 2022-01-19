#==============================================================================
# ** Scroll_Bar
#------------------------------------------------------------------------------
#  Esta classe lida com a barra de rolagem.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Scroll_Bar < Control
  
  def initialize(win, max_lines, spacing, arrows = true)
    title_bar_height = win.is_a?(Window_Base2) ? win.contents_y - 4 : 0
    super(win, win.contents_x + win.contents_width - 4, title_bar_height + 2, 14, win.height - title_bar_height - 4)
    @min_bar_height = (@win.height - 32) / spacing + max_lines
    @min_bar_y = arrows ? 18 : 0
    @bitmap = Cache.system('ScrollBar')
    @spacing = spacing
    @title_bar_height = title_bar_height
    @arrows = arrows
    @dragging = false
    @up_area = false
    @down_area = false
    @bar_area = false
    @dif_y = nil
    create_bar
    refresh_back
    refresh
  end
  
  def create_bar
    @bar = Sprite.new
    @bar.bitmap = Bitmap.new(@back.bitmap.width, @win.height - @title_bar_height - @min_bar_y * 2)
    @bar.x = @back.x
    @bar.z = @back.z
  end
  
  def dispose
    super
    @bar.bitmap.dispose
    @bar.dispose
  end
  
  def visible=(visible)
    super
    @bar.visible = visible
  end
  
  def in_up_area?
    in_area?(0, 0, width, @bitmap.height)
  end
  
  def in_down_area?
    in_area?(0, @back.height - 18, width, @bitmap.height)
  end
  
  def in_bar_area?
    in_area?(0, @bar.y - @back.y, width, @bar_height)
  end
  
  def bar_y
    @win.oy * (@bar.bitmap.height - @bar_height) / (@win.contents.height - @bar.bitmap.height) + @min_bar_y
  end
  
  def refresh
    return if @contents_height == @win.contents.height
    @contents_height = @win.contents.height
    self.visible = @contents_height + 32 > @win.height && @win.visible
    @bar_height = @bar.bitmap.height - (@contents_height / @spacing) * 100 / @min_bar_height
    refresh_bar
    @bar_y = bar_y
    @bar.y = @back.y + @bar_y
  end
  
  def refresh_back
    @back.bitmap.clear
    @back.bitmap.stretch_blt(@back.bitmap.rect, @bitmap, Rect.new(28, 0, width, @bitmap.height))
    if @arrows
      @up_area = in_up_area?
      @down_area = in_down_area?
      @back.bitmap.blt(0, 0, @bitmap, Rect.new(@up_area ? 70 : 56, 0, width, @bitmap.height))
      @back.bitmap.blt(0, @back.height - 18, @bitmap, Rect.new(@down_area ? 98 : 84, 0, width, @bitmap.height))
    end
  end
  
  def refresh_bar
    @bar.bitmap.clear
    @bar_area = in_bar_area?
    x = @bar_area ? 14 : 0
    rect = Rect.new(0, 4, width, @bar_height - 8)
    @bar.bitmap.blt(0, 0, @bitmap, Rect.new(x, 0, width, 4))
    @bar.bitmap.stretch_blt(rect, @bitmap, Rect.new(x, 4, width, 10))
    @bar.bitmap.blt(0, (@bar_height - 18) / 2, @bitmap, Rect.new(42, 0, width, @bitmap.height))
    @bar.bitmap.blt(0, @bar_height - 4, @bitmap, Rect.new(x, 14, width, 4))
  end
  
  def update
    super
    @bar.x = @back.x
    @bar.y = @back.y + @bar_y
    if visible
      refresh_up_down
      update_dragging
      mouse_scroll
      @dragging = Mouse.press?(:L) && in_bar_area? && !dragging
    end
  end
  
  def refresh_up_down
    refresh_back if @arrows && !dragging && (in_up_area? != @up_area || in_down_area? != @down_area)
    refresh_bar if in_bar_area? != @bar_area && !dragging
  end
  
  def update_trigger
    return if !Mouse.repeat?(:L) || dragging || !@arrows
    click_up if in_up_area?
    click_down if in_down_area?
  end
  
  def mouse_scroll
    return unless @win.in_area?
    click_up(Mouse.scroll / 120) if Mouse.scroll > 0
    click_down(Mouse.scroll.abs / 120) if Mouse.scroll < 0
  end
  
  def click_up(scroll = 1)
    @win.oy = [@win.oy - @spacing * scroll, 0].max if @win.oy > 0
    @bar_y = bar_y
  end
  
  def click_down(scroll = 1)
    # Calcula o que está dentro de parênteses primeiro
    #para evitar um resultado diferente
    @win.oy = [@win.oy + @spacing * scroll, @win.contents.height - (@win.height - 32)].min
    @bar_y = bar_y
  end
  
  def update_dragging
    return if dragging
    if @dragging
      @bar_y = [[Mouse.y - @dif_y - @back.y, @min_bar_y].max, @min_bar_y - 2 + @bar.bitmap.height - @bar_height].min
      @win.oy = (@bar_y - @min_bar_y) * (@win.contents.height - @bar.bitmap.height) / (@bar.bitmap.height - @bar_height)
      @bar.y = @back.y + @bar_y
    else
      @dif_y = Mouse.y - @bar.y
    end
  end
  
end
