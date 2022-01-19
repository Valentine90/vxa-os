#==============================================================================
# ** Combo_Box
#------------------------------------------------------------------------------
#  Esta classe lida com a caixa de combinação.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Combo_Box < Control
  
  attr_reader   :index, :enable
  
  def initialize(win, x, y, width, list, list_dir = :list_down, &block)
    @bitmap = Cache.system('ComboBox')
    super(win, x, y, width, @bitmap.height)
    @last_area = false
    @list = list
    @list_dir = list_dir
    @block = block
    @cursor_index = -1
    @last_index = 0
    @index = 0
    create_box
    create_cursor
    refresh
  end
  
  def box_y
    if @list_dir == :list_down
      y = @back.y + height
      y = Graphics.height - @box.bitmap.height if y + @box.bitmap.height > Graphics.height
    else
      y = [@back.y - @box.bitmap.height, 0].max
    end
    y
  end
  
  def create_box
    @box = Sprite2.new
    @box.z = @back.z + 1
    @box.visible = false
    b = Bitmap.new(1, 1)
    wth = @list.collect { |s| b.text_size(s).width }.max + 16
    b.dispose
    @list_width = wth < width ? width : wth
    @box.bitmap = Bitmap.new(@list_width, @list.size * line_height)
    @box.bitmap.stretch_blt(@box.bitmap.rect, @bitmap, Rect.new(36, 0, 18, line_height))
    @list.each_with_index do |text, i|
      @box.bitmap.draw_text(4, line_height * i, @list_width + 32, line_height, text)
    end
  end
  
  def create_cursor
    @cursor = Sprite.new
    @cursor.bitmap = Bitmap.new(@list_width, line_height)
    @cursor.bitmap.stretch_blt(@cursor.bitmap.rect, @bitmap, Rect.new(54, 0, 18, line_height))
    @cursor.z = @box.z + 1
    @cursor.visible = false
  end
  
  def list=(list)
    @list = list
    dispose_box
    create_box
    create_cursor
  end
  
  def dispose
    super
    dispose_box
  end
  
  def dispose_box
    @box.bitmap.dispose
    @box.dispose
    @cursor.bitmap.dispose
    @cursor.dispose
  end
  
  def visible=(visible)
    super
    @box.visible = false
    @cursor.visible = false
  end
  
  def index=(index)
    @index = index
    refresh
  end
  
  def refresh
    @back.bitmap.clear
    @last_area = in_area?
    fill_background(@bitmap, @last_area ? 18 : 0)
    x = @list_dir == :list_down ? 72 : 90
    @back.bitmap.blt(width - 18, 0, @bitmap, Rect.new(x, 0, 18, height))
    @back.bitmap.draw_text(4, 0, width, line_height, @list[@index])
  end
  
  def click
    return unless @enable
    Sound.play_ok
    @last_index = @index
    @box.visible = !@box.visible
    @box.x = @back.x
    @box.y = box_y
    @cursor.x = @box.x
    @cursor.y = line_height * @index + @box.y
    self.active = true
    # Se clicou em um item da lista que
    #está sobre @back
    @cursor.visible = false
  end
  
  def out_click
    super
    self.index = @cursor_index if @cursor_index >= 0
    block if @block && @box.in_area?
    @box.visible = false
    @cursor.visible = false
  end
  
  def update
    super
    refresh if in_area? != @last_area && @enable && !dragging
    update_cursor
  end
  
  def update_cursor
    return unless @box.visible
    @cursor_index = @last_index
    @cursor.visible = (@last_index >= 0)
    @list.each_index do |i|
      next unless @box.in_area?(0, line_height * i , @list_width, line_height)
      @cursor_index = i
      @cursor.visible = true
      @cursor.y = line_height * i + @box.y
      @last_index = -1
      break
    end
  end
  
end
