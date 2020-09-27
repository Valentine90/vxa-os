#==============================================================================
# ** Window_Chat
#------------------------------------------------------------------------------
#  Esta classe lida com a janela do bate-papo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Chat < Window_Base
  
  def initialize
    @data = []
    # Quando a resolução é alterada, a coordenada y é
    #reajustada no adjust_windows_position da Scene_Map
    super(12, adjust_y, 373, 158)
    self.windowskin = Cache.system('WindowChat')
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
    contents.font.outline = false
    contents.font.shadow = true
    contents.font.bold = true
    contents.font.size = 17
    @scroll_bar.refresh
    @data.each_with_index do |line, i|
      change_color(text_color(line.color_id))
      draw_text(0, line_height * i, width, line_height, line.text)
    end
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
    send_message
    if @message_box.active
      @message_box.active = false
      self.opacity = 0
    else
      @message_box.active = true
      self.opacity = 255
    end
  end
  
  def send_message
    return unless @message_box.active
    return if @message_box.text.strip.empty?
    if @message_box.text == '/clear'
      @data.clear
      refresh
    elsif @channel_box.index == Enums::Chat::GLOBAL && global_chat_spawning? && @message_box.text != '/who'
      write_message(Vocab::GlobalSpawning, Configs::ERROR_COLOR)
      Sound.play_buzzer
    elsif @channel_box.index == Enums::Chat::PARTY && $game_actors[1].party_members.size == 0
      write_message(Vocab::NotParty, Configs::ERROR_COLOR)
      Sound.play_buzzer
    elsif @channel_box.index == Enums::Chat::GUILD && $game_actors[1].guild.empty?
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
