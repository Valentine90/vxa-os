#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  Esta é a superclasse de todas as janelas do jogo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Base < Window
  
  attr_reader   :controls
  attr_accessor :title_y
  
  def init_features
    self.back_opacity = 255
    @title_height = 20
    @title_y = 0
    @dragable = true
    @closable = false
    @controls = []
    @last_item = nil
    @dif_x = nil
    @dif_y = nil
  end
  
  def create_desc
    @desc_sprite = Sprite_Desc.new
    @desc_sprite.z = z + 2
  end
  
  def closable=(closable)
    @closable = closable
  end
  
  def in_border_area?
    in_area?(0, -@title_y, width - 20, @title_height)
  end
  
  def title=(title)
    bitmap = Cache.system('TitleBar')
    @title_height = bitmap.height
    @title_y = @title_height - 8
    @title = Sprite.new
    @title.x = x
    @title.y = y - @title_y
    @title.z = z + 1
    @title.visible = visible
    @title.bitmap = Bitmap.new(width, @title_height)
    @title.bitmap.blt(0, 0, bitmap, Rect.new(0, 0, 4, @title.bitmap.height))
    @title.bitmap.stretch_blt(Rect.new(4, 0, @title.bitmap.width - 8, @title.bitmap.height), bitmap, Rect.new(4, 0, 12, @title.bitmap.height))
    @title.bitmap.blt(@title.bitmap.width - 4, 0, bitmap, Rect.new(16, 0, 4, @title.bitmap.height))
    @title.bitmap.blt(@title.bitmap.width - 20, 0, bitmap, Rect.new(20, 0, 20, @title.bitmap.height)) if @closable
    @title.bitmap.draw_text(@title.bitmap.rect, title, 1)
    self.windowskin = Cache.system('Window2')
  end
  
  def dispose_features
    @controls.each(&:dispose)
    dispose_desc
    dispose_title
  end
  
  def dispose_desc
    return unless @desc_sprite
    @desc_sprite.bitmap.dispose
    @desc_sprite.dispose
  end
  
  def dispose_title
    return unless @title
    @title.bitmap.dispose
    @title.dispose
  end
  
  def line_height
    18
  end
  
  def show_desc(item)
    return if @last_item == item
    @desc_sprite.refresh(item)
    @last_item = item
  end
  
  def hide_desc
    @desc_sprite.visible = false
    @last_item = nil
  end
  
  def trigger
    self.visible ? hide : show
  end
  
  def show
    self.visible = true
    @title.visible = true if @title
    @controls.each { |control| control.visible = true }
    refresh
  end
  
  def hide
    self.visible = false
    @title.visible = false if @title
    @controls.each { |control| control.visible = false }
    hide_desc if @desc_sprite
  end
  
  def hide_window
    hide
  end
  
  def draw_shadow(x, y)
    bitmap = Cache.system('Shadow')
    contents.blt(x, y, bitmap, bitmap.rect)
  end
  
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
    draw_paperdolls(actor, x, y)
  end
  
  def draw_paperdolls(actor, x, y)
    [3, 5, 2, 7, 6, 8, 1, 0, 4].each do |slot_id|
      next unless actor.equips[slot_id]
      draw_paperdoll(actor.equips[slot_id].paperdoll_name, actor.equips[slot_id].paperdoll_index, actor.sex, x, y)
    end
  end
  
  def draw_paperdoll(paperdoll_name, paperdoll_index, sex, x, y)
    return unless paperdoll_name
    bitmap = Cache.paperdoll(paperdoll_name, sex)
    sign = paperdoll_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    src_rect = Rect.new((paperdoll_index % 4 * 3 + 1) * cw, (paperdoll_index / 4 * 4) * ch, cw, ch)
    contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  
  def refresh
  end
  
  def in_area?(x = 0, y = 0, w = width, h = height)
    Mouse.x >= self.x + x && Mouse.x <= self.x + x + w && Mouse.y >= self.y + y && Mouse.y <= self.y + y + h
  end
  
  def convert_gold(value)
    value.to_s.reverse.scan(/...|..|./).join('.').reverse
  end
  
  def word_wrap(text, width = contents_width)
    # Corrige a compressão de texto do RGD
    width -= 20
    bitmap = contents || Bitmap.new(1, 1)
    return [text] if bitmap.text_size(text).width <= width
    lines = []
    line = ''
    line_size = 0
    text.each_line(' ') do |word|
      word_size = bitmap.text_size(word).width
      if word_size > width
        line, lines = character_wrap(word, width, bitmap, line, lines)
      elsif line_size + word_size <= width
        line << word
        line_size += word_size
      else
        lines << line
        line = word
        line_size = word_size
      end
    end
    bitmap.dispose unless contents
    lines << line
  end
  
  def character_wrap(word, width, bitmap, line, lines)
    cs = ''
    cs_size = 0
    word.each_char do |c|
      c_size = bitmap.text_size(c).width
      if cs_size + c_size <= width
        cs << c
        cs_size += c_size
      else
        # Impede que as linhas sejam alteradas quando a
        #linha atual for apagada
        lines << line.clone unless line.empty?
        lines << cs
        cs = c
        cs_size = c_size
        line.clear
      end
    end
    return line << cs, lines
  end
  
  def update_features
    update_dragging
    hide_window if Mouse.click?(:L) && in_area?(width - 20, -@title_y, 20, @title_height) && @closable
    $dragging_window = Mouse.press?(:L) ? in_border_area? && !$dragging_window && self.opacity > 0 && @dragable ? self : $dragging_window : nil
    update_title
    @controls.each(&:update)
  end
  
  def update_title
    return unless @title
    @title.x = x
    @title.y = y - @title_y
  end
  
  def update_dragging
    return unless @dragable
    return if $cursor.object
    if $dragging_window == self
      self.x = Mouse.x - @dif_x
      self.y = Mouse.y - @dif_y
    else
      @dif_x = Mouse.x - self.x
      @dif_y = Mouse.y - self.y
    end
  end
  
end
