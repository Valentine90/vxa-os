#==============================================================================
# ** Text_Box
#------------------------------------------------------------------------------
#  Esta classe lida com a caixa de texto.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Text_Box < Control
  
  attr_reader   :text
  
  def initialize(win, x, y, width, max, pass = false, secondary_text = '', &block)
    @bitmap = Cache.system('TextBox')
    super(win, x, y, width, @bitmap.height)
    @secondary_text = secondary_text
    @max = max
    @pass = pass
    @block = block
    @text = ''
    @cursor_time = 0
    @text_width = 0
    create_cursor
    refresh
  end
  
  def create_cursor
    @cursor = Sprite.new
    @cursor.bitmap = Bitmap.new(3, line_height)
    @cursor.bitmap.draw_text(@cursor.bitmap.rect, '|')
    @cursor.z = @back.z
    @cursor.visible = false
  end
  
  def dispose
    super
    @cursor.bitmap.dispose
    @cursor.dispose
  end
  
  def text=(text)
    @text = text
    refresh
  end
  
  def clear
    @text.clear
    refresh
  end
  
  def max_chars?
    @text.size >= @max
  end
  
  def visible=(visible)
    super
    @cursor.visible = false
    # Limpa o typing
    out_click
  end
  
  def active=(active)
    super
    @cursor.visible = false
    return unless $typing == self || active
    $typing = active ? self : nil
  end
  
  def refresh
    @back.bitmap.clear
    text = display_text
    fill_background(@bitmap)
    if !@secondary_text.empty? && text.empty?
      @back.bitmap.font.color.set(195, 195, 195)
      @back.bitmap.font.size = Font.default_size - 1
      @back.bitmap.draw_text(4, 0, width, line_height, @secondary_text)
      @text_width = 0
    else
      color = max_chars? ? Color.new(255, 128, 128) : Font.default_color
      @back.bitmap.font.color.set(color)
      @back.bitmap.font.size = Font.default_size
      # Corrige a compressão de texto do RGD
      @back.bitmap.draw_text(4, 0, width + 35, line_height, text)
      @text_width = @back.bitmap.text_size(text).width
    end
  end
  
  def display_text
    text = @pass ? '•' * @text.size : @text
    # O 13 em vez de 8 corrige a compressão de texto do RGD
    wth = width - 13
    return text if @back.bitmap.text_size(text).width <= wth
    text_width = 0
    text.reverse.chars.each_with_index do |c, index|
      c_width = @back.bitmap.text_size(c).width
      if text_width + c_width >= wth
        text = text[text.size - index...text.size]
        break
      end
      text_width += c_width
    end
    text
  end
  
  def click
    self.active = true
  end
  
  def update
    super
    @cursor.x = @back.x + @text_width + 4
    @cursor.y = @back.y
    if @active
      update_cursor
      update_input
    end
  end
  
  def update_cursor
    @cursor_time += 1
    if @cursor_time == 40
      @cursor.visible = !@cursor.visible
      @cursor_time = 0
    end
  end
  
  def update_input
    c = Input.utf8_string
    if Input.repeat?(:BACKSPACE) && !@text.empty?
      @text.chop!
      refresh
      @block.call if @block
    elsif valid_character?(c) && !max_chars?
      @text << c
      refresh
      @block.call if @block
    end
  end
  
  def valid_character?(c)
    !c.empty?
  end
  
end

#==============================================================================
# ** Number_Box
#==============================================================================
class Number_Box < Text_Box
  
  def value=(value)
    self.text = value.to_s
  end
  
  def value
    @text.to_i
  end
  
  def display_text
    @text.reverse.scan(/...|..|./).join('.').reverse
  end
  
  def valid_character?(c)
    super && c =~ /\d/
  end
  
end
