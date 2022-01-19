#==============================================================================
# ** Window_Panel
#------------------------------------------------------------------------------
#  Esta classe lida com o painel de administração.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Panel < Window_Base
  
  def initialize
    # Quando a resolução é alterada, as coordenadas x e y
    #são reajustadas no adjust_windows_position da Scene_Map
    super(adjust_x, adjust_y, 385, 302)
    self.visible = false
    self.closable = true
    self.title = Vocab::AdmPanel
    #load_maps
    #load_items
    create_buttons
    @item_type = 0
  end
  
  def adjust_x
    Graphics.width / 2 - 192
  end
  
  def adjust_y
    Graphics.height / 2 - 176
  end
=begin
  def load_maps
    @map_ids = []
    @map_names = []
    $data_mapinfos.each do |map_id, map|
      @map_ids << map_id
      @map_names << map.name
    end
  end
  def load_items
    @items = []
    @items << $data_items.drop(1).collect(&:name)
    @items << $data_weapons.drop(1).collect(&:name)
    @items << $data_armors.drop(1).collect(&:name)
  end
=end
  def create_buttons
    @name_box = Text_Box.new(self, 53, 16, 163, Configs::MAX_CHARACTERS, false, Vocab::SecondaryPanelText) { enable_buttons }
    @kick_button = Button.new(self, 15, 40, Vocab::Kick, 99) { kick_player }
    @mute_button = Button.new(self, 118, 40, Vocab::Mute, 98) { mute_player }
    @pull_button = Button.new(self, 15, 66, Vocab::Pull, 99) { pull_player }
    @go_button = Button.new(self, 118, 66, Vocab::GoTo, 98) { go_to_player }
    @days_box = Number_Box.new(self, 53, 110, 61, 5)
    @unban_button = Button.new(self, 118, 109, Vocab::Unban, 98) { unban }
    @ban_account = Button.new(self, 15, 135, Vocab::BanAcc, 98) { ban_account }
    @ban_ip = Button.new(self, 118, 135, Vocab::BanIP, 98) { ban_ip }
    @motd_box = Text_Box.new(self, 15, 179, 138, 120)
    @change_button = Button.new(self, 158, 178, Vocab::Change, 58) { change_motd }
    @switch_box = Number_Box.new(self, 39, 222, 45, 4)
    @switch_on = Button.new(self, 89, 221, Vocab::On, 51) { switch_on }
    @switch_off = Button.new(self, 144, 221, Vocab::Off, 72) { switch_off }
    @map_box = Number_Box.new(self, 272, 16, 98, 5) { refresh_map unless @map_box.text.empty? }
    @map_box.text = $game_map.map_id.to_s
    #@map_box = Combo_Box.new(self, 234, 16, 136, @map_names) { refresh_map }
    @teleport_button = Button.new(self, 234, 150, Vocab::Teleport, 136) { teleport }
    @prev_button = Image_Button.new(self, 271, 194, 'Left') { prev_item_type }
    @next_button = Image_Button.new(self, 347, 194, 'Right') { next_item_type }
    @amount_box = Number_Box.new(self, 314, 244, 56, 5)
    @item_box = Number_Box.new(self, 258, 220, 112, 5)
    #@item_box = Combo_Box.new(self, 234, 220, 136, @items[0])
    @item_button = Button.new(self, 234, 268, Vocab::GiveItem, 136) { give_item }
    @message_box = Text_Box.new(self, 15, 268, 138, 120)
    @send_button = Button.new(self, 158, 267, Vocab::Send, 57) { admin_message }
  end
  
  def disable_buttons
    @kick_button.enable = false
    @mute_button.enable = false
    @pull_button.enable = false
    @go_button.enable = false
    @unban_button.enable = false
    @ban_account.enable = false
    @ban_ip.enable = false
    @teleport_button.enable = false
    @item_button.enable = false
    unless $game_player.admin?
      @change_button.enable = false
      @switch_on.enable = false
      @switch_off.enable = false
      @map_box.enable = false
      @prev_button.enable = false
      @next_button.enable = false
      @item_box.enable = false
      @send_button.enable = false
    end
  end
  
  def show
    @name_box.clear
    @motd_box.clear
    @days_box.clear
    @switch_box.clear
    @map_box.clear
    @amount_box.clear
    @item_box.clear
    @message_box.clear
    @map_box.text = $game_map.map_id.to_s
    #@map_box.index = $game_map.map_id - 1
    @x = $game_player.x * 136 / $game_map.width
    @y = $game_player.y * 109 / $game_map.height
    disable_buttons
    super
  end
  
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(3, 77, 205, line_height, Vocab::Banishment, 1)
    draw_text(3, 146, 205, line_height, Vocab::Motd, 1)
    draw_text(3, 189, 205, line_height, Vocab::GlobalSwitch, 1)
    draw_text(222, 161, 136, line_height, "#{Vocab::Item}:", 1)
    draw_text(3, 234, 205, line_height, Vocab::AlertMessage, 1)
    change_color(normal_color)
    draw_text(3, 4, 45, line_height, "#{Vocab::Name}:")
    draw_text(3, 97, 200, line_height, "#{Vocab::Days}:")
    draw_text(3, 207, 200, line_height, Vocab::ID)
    draw_text(222, 4, 200, line_height, "#{Vocab::Map}:")
    draw_text(222, 181, 136, line_height, Vocab::ItemType)
    draw_text(222, 207, 136, line_height, Vocab::ID)
    draw_text(222, 231, 136, line_height, "#{Vocab::Amount}:")
    case @item_type
    when 0
      item_type = Vocab::Item
    when 1
      item_type = Vocab.weapon
    when 2
      item_type = Vocab.armor
    when 3
      item_type = Vocab.currency_unit
    end
    draw_text(276, 181, 60, line_height, item_type, 1)
    draw_map
    draw_player_point
  end
  
  def refresh_map
    contents.clear_rect(222, 25, 136, 109)
    draw_map
    draw_player_point
  end
  
  def draw_map
    #return unless FileTest.exist?("Graphics/Minimaps/#{@map_ids[@map_box.index]}.png")
    #bitmap = Cache.minimap(@map_ids[@map_box.index].to_s)
    return unless FileTest.exist?("Graphics/Minimaps/#{@map_box.text}.png")
    bitmap = Cache.minimap(@map_box.text)
    contents.blt(222, 25, bitmap, bitmap.rect)
  end
  
  def draw_player_point
    rect = Rect.new(142, 0, 16, 16)
    x = [[222 + @x, 222].max, 342].min
    y = [[25 + @y, 25].max, 118].min
    bitmap = Cache.system('Minimap')
    contents.blt(x, y, bitmap, rect)
  end
  
  def kick_player
    $network.send_admin_command(Enums::Command::KICK, @name_box.text)
  end
  
  def mute_player
    $network.send_admin_command(Enums::Command::MUTE, @name_box.text)
  end
  
  def pull_player
    $network.send_admin_command(Enums::Command::PULL, @name_box.text)
  end
  
  def go_to_player
    $network.send_admin_command(Enums::Command::GO, @name_box.text)
  end
  
  def change_motd
    return if @motd_box.text.strip.empty?
    $network.send_admin_command(Enums::Command::MOTD, @motd_box.text)
  end
  
  def ban_account
    return if @days_box.value == 0
    $network.send_admin_command(Enums::Command::BAN_ACC, @name_box.text, @days_box.value)
  end
  
  def ban_ip
    return if @days_box.value == 0
    $network.send_admin_command(Enums::Command::BAN_IP, @name_box.text, @days_box.value)
  end
  
  def unban
    $network.send_admin_command(Enums::Command::UNBAN, @name_box.text)
  end
  
  def switch_on
    return if @switch_box.value == 0
    $network.send_admin_command(Enums::Command::SWITCH, @switch_box.text, 1)
  end
  
  def switch_off
    return if @switch_box.value == 0
    $network.send_admin_command(Enums::Command::SWITCH, @switch_box.text, 0)
  end
  
  def teleport
    return if @map_box.value == 0
    return unless $data_mapinfos.has_key?(@map_box.value)
    x = @x * $game_map.width / 136
    y = @y * $game_map.height / 109
    $network.send_admin_command(Enums::Command::TELEPORT, @name_box.text, @map_box.value, x, y)
  end
  
  def prev_item_type
    @item_type = @item_type > 0 ? @item_type - 1 : 3
    refresh_item_list
  end
  
  def next_item_type
    @item_type = @item_type < 3 ? @item_type + 1 : 0
    refresh_item_list
  end
  
  def refresh_item_list
    if @item_type < 3
      @item_box.enable = true
      #@item_box.list = @items[@item_type]
      #@item_box.index = 0
    else
      @item_box.enable = false
    end
    refresh
  end
  
  def give_item
    return if @item_box.value == 0 && @item_type < 3
    return if @amount_box.value == 0
    $network.send_admin_command(Enums::Command::ITEM + @item_type, @name_box.text, @item_box.value, @amount_box.value)
  end
  
  def admin_message
    return if @message_box.text.strip.empty?
    $network.send_admin_command(Enums::Command::MSG, @message_box.text)
    @message_box.clear
  end
  
  def enable_buttons
    enable = (@name_box.text.strip.size >= Configs::MIN_CHARACTERS)
    @mute_button.enable = enable
    @pull_button.enable = enable
    @go_button.enable = enable
    @kick_button.enable = enable && $game_player.admin?
    @unban_button.enable = enable && $game_player.admin?
    @ban_account.enable = enable && $game_player.admin?
    @ban_ip.enable = enable && $game_player.admin?
    @teleport_button.enable = enable && $game_player.admin?
    @item_button.enable = enable && $game_player.admin?
  end
  
  def update
    super
    if Mouse.click?(:L) && in_area?(234, 37, 136, 109)
      @x = Mouse.x - x - 234
      @y = Mouse.y - y - 37
      refresh_map
    end
  end
  
end
