#==============================================================================
# ** Check_Box
#------------------------------------------------------------------------------
#  Esta classe lida com a caixa de verificação.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Check_Box < Control
  
  attr_reader   :checked
  
  def initialize(win, x, y, text, checked = false)
    super(win, x, y, text_width(text) + 19)
    @text = text
    @checked = checked
    refresh
  end
  
  def refresh
    @back.bitmap.clear
    bitmap = Cache.system('CheckBox')
    @back.bitmap.blt(0, 1, bitmap, Rect.new(@checked ? 14 : 0, 0, bitmap.width / 2, bitmap.height))
    @back.bitmap.draw_text(19, 0, width, line_height, @text)
  end
  
  def click
    @checked = !@checked
    refresh
  end
  
end
