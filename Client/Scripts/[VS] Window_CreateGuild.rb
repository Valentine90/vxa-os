#==============================================================================
# ** Window_CreateGuild
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de criação de guilda.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_CreateGuild < Window_Base
  
  def initialize
    # Quando a resolução é alterada, as coordenadas x e y
    #são reajustadas no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 192, 271)
    self.visible = false
    self.closable = true
    self.title = Vocab::NewGuild
    @create_button = Button.new(self, 71, 236, Vocab::Create) { create_guild }
    @name_box = Text_Box.new(self, 62, 18, 106, Configs::MAX_CHARACTERS) { enable_create_button }
    @colors = Cache.system('GuildColors')
  end
  
  def adjust_x
    Graphics.width / 2 - 96
  end
  
  def adjust_y
    Graphics.height / 2 - 150
  end
  
  def hide_window
    $network.send_close_window
  end
  
  def blank_color
    Color.new(128, 128, 128, 70)
  end
  
  def invalid_name?
    @name_box.text =~ /[^A-Za-z0-9 ]/
  end
  
  def empty_flag?
    !@flag.any? { |color_id| color_id < 255 }
  end
  
  def show
    @color_id = 0
    @flag = Array.new(64, 255)
    @name_box.clear
    @create_button.enable = false
    super
    contents.blt(10, 180, @colors, Rect.new(64, 0, 16, 16))
    # Ativa a caixa de texto após a janela ficar visível
    @name_box.active = true
  end
  
  def refresh
    draw_background
    draw_flag
    draw_colors
  end
  
  def draw_background
    contents.clear
    draw_text(7, 7, 45, line_height, "#{Vocab::Name}:")
  end
  
  def draw_flag
    @flag.each_index { |i| contents.fill_rect(i % 8 * 17 + 17, i / 8 * 17 + 35, 16, 16, blank_color) }
  end
  
  def draw_colors
    16.times { |color_id| contents.fill_rect(color_id % 8 * 19 + 10, color_id / 8 * 19 + 180, 16, 16, color(color_id)) }
  end
  
  def color(n)
    @colors.get_pixel(n % 8 * 8, n / 8 * 8)
  end
  
  def create_guild
    return unless @create_button.enable
    if invalid_name?
      $windows[:chat].write_message(Vocab::ForbiddenCharacter, Configs::ERROR_COLOR)
    elsif empty_flag?
      $windows[:chat].write_message(Vocab::EmptyFlag, Configs::ERROR_COLOR)
    else
      $network.send_create_guild(@name_box.text, @flag)
      hide
    end
  end
  
  def enable_create_button
    @create_button.enable = @name_box.text.strip.size >= Configs::MIN_CHARACTERS
  end
  
  def update
    super
    select_color
    change_flag
    clear_flag
    create_guild if Input.trigger?(:C)
  end
  
  def select_color
    return unless Mouse.click?(:L)
    16.times do |color_id|
      if in_area?(color_id % 8 * 19 + 21, color_id / 8 * 19 + 191, 16, 16)
        contents.clear_rect(@color_id % 8 * 19 + 10, @color_id / 8 * 19 + 180, 16, 16)
        contents.fill_rect(@color_id % 8 * 19 + 10, @color_id / 8 * 19 + 180, 16, 16, color(@color_id))
        @color_id = color_id
        contents.blt(@color_id % 8 * 19 + 10, @color_id / 8 * 19 + 180, @colors, Rect.new(64, 0, 16, 16))
        Sound.play_ok
        break
      end
    end
  end
  
  def change_flag
    return unless Mouse.click?(:L)
    @flag.each_index do |i|
      if in_area?(i % 8 * 17 + 28, i / 8 * 17 + 47, 16, 16)
        @flag[i] = @color_id
        contents.clear_rect(i % 8 * 17 + 17, i / 8 * 17 + 35, 16, 16)
        contents.fill_rect(i % 8 * 17 + 17, i / 8 * 17 + 35, 16, 16, color(@color_id))
        Sound.play_ok
        break
      end
    end
  end
  
  def clear_flag
    return unless Mouse.click?(:R)
    @flag.each_index do |i|
      if in_area?(i % 8 * 17 + 28, i / 8 * 17 + 47, 16, 16)
        @flag[i] = 255
        contents.clear_rect(i % 8 * 17 + 17, i / 8 * 17 + 35, 16, 16)
        contents.fill_rect(i % 8 * 17 + 17, i / 8 * 17 + 35, 16, 16, blank_color)
        Sound.play_cancel
        break
      end
    end
  end
  
end
