#==============================================================================
# ** Tab_Control
#------------------------------------------------------------------------------
#  Esta classe lida com as páginas de guia.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Tab_Control < Control
  
  attr_reader   :index
  
  def initialize(win, list, windowskin = false, &block)
    @bitmap = Cache.system('TabControl')
    @win = win
    @list = list
    @block = block
    @cursor_index = -1
    @index = 0
    @win.controls << self
    create_windowskin if windowskin
    create_pages
  end
  
  def border_color
    Color.new(0, 0, 0, 192)
  end
  
  def create_windowskin
    @windowskin = Sprite.new
    @windowskin.bitmap = Bitmap.new(@win.width, 13)
    @windowskin.x = @win.x
    @windowskin.y = @win.y - 11
    bitmap = @win.windowskin
    @windowskin.bitmap.stretch_blt(@windowskin.bitmap.rect, bitmap, Rect.new(0, 0, 64, @windowskin.height))
    @windowskin.bitmap.blt(0, 0, bitmap, Rect.new(64, 8, 4, @windowskin.height))
    @windowskin.bitmap.blt(@windowskin.width - 4, 0, bitmap, Rect.new(124, 8, 4, @windowskin.height))
    @windowskin.z = @win.z
    @windowskin.visible = @win.visible
    @win.title_y += 19
  end
  
  def create_pages
    @y = @windowskin ? -9 : 10
    @x_pages = []
    @pages = []
    x = 12
    @list.each_with_index do |text, i|
      page = Sprite2.new
      width = text.is_a?(Integer) ? 44 : text_width(text) + 20
      page.bitmap = Bitmap.new(width, @bitmap.height)
      page.x = @win.x + x
      page.y = @win.y + @y
      page.z = @win.z + 1
      page.visible = @win.visible
      page.opacity = 192
      @pages << page
      @x_pages << x
      x += width
      refresh_page(i, i == @index ? 18 : 0)
    end
  end
  
  def dispose
    @pages.each do |page|
      page.bitmap.dispose
      page.dispose
    end
    if @windowskin
      @windowskin.bitmap.dispose
      @windowskin.dispose
    end
  end
  
  def visible=(visible)
    @pages.each { |page| page.visible = visible }
    @windowskin.visible = visible if @windowskin
  end
  
  def index=(index)
    refresh_page(@index, 0)
    refresh_page(index, 18)
    @index = index
    block if @block
  end
  
  def refresh_page(index, x)
    @pages[index].bitmap.clear
    @pages[index].bitmap.blt(0, 0, @bitmap, Rect.new(x, 0, 4, @bitmap.height))
    @pages[index].bitmap.stretch_blt(Rect.new(4, 0, @pages[index].bitmap.width - 8, @bitmap.height), @bitmap, Rect.new(x + 4, 0, 10, @bitmap.height))
    @pages[index].bitmap.blt(@pages[index].bitmap.width - 4, 0, @bitmap, Rect.new(x + 14, 0, 4, @bitmap.height))
    if @list[index].is_a?(Integer)
      bitmap = Cache.system('Iconset')
      rect = Rect.new(@list[index] % 16 * 24, @list[index] / 16 * 24, 24, 24)
      @pages[index].bitmap.blt(@pages[index].bitmap.rect.x + 10, @pages[index].bitmap.rect.y, bitmap, rect)
    else
      @pages[index].bitmap.draw_text(@pages[index].bitmap.rect, @list[index], 1)
    end
  end
  
  def draw_border
    @win.contents.fill_rect(0, 1, 1, @win.contents_height, border_color)
    @win.contents.fill_rect(@win.contents_width - 1, 0, 1, @win.contents_height, border_color)
    @win.contents.fill_rect(@x_pages.last + @pages.last.width - 12, 0, @win.contents_width, 1, border_color)
    @win.contents.fill_rect(0, @win.contents_height - 1, @win.contents_width, 1, border_color)
  end
  
  def update
    update_positions
    update_trigger
    update_cursor
  end
  
  def update_positions
    @pages.each_with_index do |page, i|
      page.x = @win.x + @x_pages[i]
      page.y = @win.y + @y
    end
    if @windowskin
      @windowskin.x = @win.x
      @windowskin.y = @win.y - 11
    end
  end
  
  def update_trigger
    return unless Mouse.click?(:L)
    @pages.each_with_index do |page, i|
      next unless page.in_area?
      self.index = i unless @index == i
      break
    end
  end
  
  def update_cursor
    return if dragging
    last_index = @cursor_index
    @cursor_index = -1
    @pages.each_with_index do |page, i|
      next unless page.in_area? && @index != i
      @cursor_index = i
      break
    end
    unless @cursor_index == last_index
      refresh_page(@cursor_index, 36) if @cursor_index > -1
      refresh_page(last_index, 0) if last_index > -1 && last_index != @index
    end
  end
  
end
