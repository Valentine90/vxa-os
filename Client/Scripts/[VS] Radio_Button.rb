#==============================================================================
# ** Radio_Button
#------------------------------------------------------------------------------
#  Esta classe lida com o botão de opção.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Radio_Button < Control
  
  attr_reader   :index
  
  def initialize(win, list, index = 0, &block)
    @win = win
    @list = list
    @index = index
    @block = block
    @visible = @win.visible
    @win.controls << self
    @buttons = []
    create_buttons
  end
  
  def create_buttons
    @list.each_index do |index| 
      button = Sprite2.new
      button.bitmap = Bitmap.new(text_width(@list[index][2]) + 19, line_height)
      button.x = @win.x + @list[index][0]
      button.y = @win.y + @list[index][1]
      button.z = @win.z + 1
      button.visible = @visible
      @buttons << button
      refresh_button(index)
    end
  end
  
  def dispose
    @buttons.each do |button|
      button.bitmap.dispose
      button.dispose
    end
  end
  
  def index=(index)
    last_index = @index
    @index = index
    refresh_button(last_index)
    refresh_button(@index)
    block if @block
  end
  
  def visible=(visible)
    @visible = visible
    @buttons.each { |button| button.visible = @visible }
  end
  
  def refresh_button(index)
    @buttons[index].bitmap.clear
    bitmap = Cache.system('RadioButton')
    @buttons[index].bitmap.blt(0, 1, bitmap, Rect.new(@index == index ? 14 : 0, 0, bitmap.width / 2, bitmap.height))
    @buttons[index].bitmap.draw_text(19, 0, @buttons[index].bitmap.width, line_height, @list[index][2])
  end
  
  def update
    update_positions
    update_trigger if @visible
  end
  
  def update_positions
    @buttons.each_with_index do |button, i|
      button.x = @win.x + @list[i][0]
      button.y = @win.y + @list[i][1]
    end
  end
  
  def update_trigger
    return unless Mouse.click?(:L)
    @buttons.each_with_index do |button, i|
      next unless button.in_area?
      self.index = i unless @index == i
      break
    end
  end
  
end
