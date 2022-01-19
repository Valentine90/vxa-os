#==============================================================================
# ** Window_Chat
#------------------------------------------------------------------------------
#  Esta classe lida com a janela do bate-papo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Chat < Window_Base
  
  attr_reader   :message_box
  
  def initialize
    @data = []
    # Quando a resolução é alterada, a coordenada y é
    #reajustada no adjust_windows_position da Scene_Map
    super(12, adjust_y, 373, 158)
    self.windowskin = Cache.system('WindowChat')
    #@emoji_icon = Icon.new(self, 343, 154, Configs::EMOJI_ICON, Vocab::Emojis) { $windows[:emoji].trigger }
    @scroll_bar = Scroll_Bar.new(self, Configs::MAX_CHAT_LINES, line_height)
    @message_box = Text_Box.new(self, 78, 156, 291, 100, false, Vocab::SecondaryText)
    @channel_box = Combo_Box.new(self, 4, 156, 70, [Vocab::Map, Vocab::All, Vocab::Party, Vocab::Guild, Vocab::Private], :list_up) { change_channel }
    @private_box = Text_Box.new(self, 267, 134, 80, Configs::MAX_CHARACTERS)
    @private_box.visible = false
    write_message($network.motd, Configs::GLOBAL_COLOR)
    @global_antispam_time = Time.now
    self.opacity = 0
    # Deixa o chat embaixo das outras janelas mesmo
    #que o contents seja recriado posteriormente
    self.z = 99
  end
  
  def adjust_y
    Graphics.height - 181
  end
  
  def contents_height
    @data.size * line_height
  end
  
  def in_border_area?
    in_area?
  end
  
  def global_chat_spawning?
    @global_antispam_time > Time.now
  end
  
  def refresh
    contents.height == Configs::MAX_CHAT_LINES * line_height ? contents.clear : create_contents
    reset_chat_font
    @scroll_bar.refresh
    @data.each_with_index do |line, i|
      change_color(text_color(line.color_id))
      draw_text(0, line_height * i, width, line_height, line.text)
      #draw_emojis(contents, 0, i, line.text)
    end
  end
  
  def draw_emojis(contents, start_x, line_index, text)
    Configs::CHAT_EMOJIS.each_with_index do |emoji, emoji_index|
      offset = 0
      text.size.times do
        text_index = text.index(emoji, offset)
        break unless text_index
        offset = text_index + 2
        x = contents.text_size(text[0...text_index]).width
        draw_emoji(contents, emoji_index, start_x + x, line_height * line_index)
      end
    end
  end
  
  def draw_emoji(contents, emoji_index, x, y)
    bitmap = Cache.system('Emojis')
    src_rect = Rect.new(emoji_index % 4 * 24, emoji_index / 4 * 24, 24, 24)
    dest_rect = Rect.new(x, y, 16, 16)
    contents.stretch_blt(dest_rect, bitmap, src_rect)
  end
  
  def reset_chat_font
    contents.font.name = Configs::CHAT_FONT_NAME
    contents.font.outline = Configs::CHAT_FONT_OUTLINE
    contents.font.shadow = Configs::CHAT_FONT_SHADOW
    contents.font.bold = Configs::CHAT_FONT_BOLD
    contents.font.size = Configs::CHAT_FONT_SIZE
  end
  
  def change_channel
    @private_box.visible = (@channel_box.index == Enums::Chat::PRIVATE)
  end
  
  def private(name)
    # Impede que o nome do jogador seja alterado
    @private_box.text = name.clone
    @channel_box.index = Enums::Chat::PRIVATE
    change_channel
  end
  
  def update
    super
    update_trigger
    click
  end
  
  def update_trigger
    return unless Input.trigger?(:C)
    return if $typing && $typing != @message_box
    enter_message
    if @message_box.active
      @message_box.active = false
      self.opacity = 0
    else
      @message_box.active = true
      self.opacity = 255
    end
  end
  
  def enter_message
    return unless @message_box.active
    return if @message_box.text.strip.empty?
    if @message_box.text == '/clear'
      @data.clear
      self.oy = 0
      refresh
    elsif @channel_box.index == Enums::Chat::GLOBAL && global_chat_spawning? && @message_box.text != '/who'
      write_message(Vocab::GlobalSpawning, Configs::ERROR_COLOR)
      Sound.play_buzzer
    elsif @channel_box.index == Enums::Chat::PARTY && $game_actors[1].party_members.size == 0
      write_message(Vocab::NotParty, Configs::ERROR_COLOR)
      Sound.play_buzzer
    elsif @channel_box.index == Enums::Chat::GUILD && $game_actors[1].guild_name.empty?
      write_message(Vocab::NotGuild, Configs::ERROR_COLOR)
      Sound.play_buzzer
    elsif @channel_box.index == Enums::Chat::PRIVATE && @private_box.text.strip.size < Configs::MIN_CHARACTERS
      write_message(sprintf(Vocab::Insufficient, Vocab::Name, Configs::MIN_CHARACTERS), Configs::ERROR_COLOR)
      Sound.play_buzzer
    else
      $network.send_chat_message(@message_box.text, @channel_box.index, @private_box.text)
      @global_antispam_time = Time.now + Configs::GLOBAL_ANTISPAM_TIME if @channel_box.index == Enums::Chat::GLOBAL && @message_box.text != '/who'
    end
    @message_box.clear
  end
  
  def click
    return unless Mouse.click?(:L)
    self.opacity = @message_box.active ? 255 : 0
  end
  
  def write_message(message, color_id)
    # Remove o caractere de nova linha do comando Chamar Script
    word_wrap(message.delete("\n")).each do |line|
      @data << Chat_Line.new(line, color_id)
      self.oy += line_height if @data.size > 7 && @data.size <= Configs::MAX_CHAT_LINES
      @data.shift if @data.size > Configs::MAX_CHAT_LINES
    end
    refresh
  end
  
end

#==============================================================================
# ** Window_Emoji
#==============================================================================
class Window_Emoji < Window_Base
  
  def initialize
    super(adjust_x, adjust_y, 120, 72)
    self.windowskin = Cache.system('Window3')
    self.visible = false
    @dragable = false
    draw_contents
  end
  
  def adjust_x
    $windows[:chat].x + 343
  end
  
  def adjust_y
    $windows[:chat].y + 80
  end
  
  def draw_contents
    bitmap = Cache.system('Emojis')
    contents.blt(0, 0, bitmap, bitmap.rect)
  end
  
  def update
    super
    click if Mouse.click?(:L)
  end
  
  def click
    Configs::CHAT_EMOJIS.each_with_index do |emoji, i|
      if in_area?(i % 4 * 24 + 16, i / 4 * 24 + 16, 24, 24)
        $windows[:chat].message_box.text += emoji
        hide
      end
    end
  end
  
end
