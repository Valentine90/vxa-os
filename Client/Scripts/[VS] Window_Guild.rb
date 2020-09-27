#==============================================================================
# ** Window_Guild
#------------------------------------------------------------------------------
#  Esta classe lida com a janela de guilda.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Window_Guild < Window_Selectable
  
  MAIN_PAGE   = 0
  MANAGE_PAGE = 1
  
  def initialize
    super(400, 170, 252, 222)
    self.visible = false
    self.closable = true
    self.title = Vocab::Guild
    @tab_page = Tab_Control.new(self, [Vocab::Main, Vocab::Manage, "#{Vocab::Member}s"], true) { refresh }
    @shutdown_button = Button.new(self, 94, 170, Vocab.shutdown, 65) { $windows[:choice].show(Vocab::Ask, Enums::Choice::LEAVE_GUILD) }
    @kick_box = Text_Box.new(self, 98, 22, 101, Configs::MAX_CHARACTERS) { enable_kick_button }
    @leader_box = Text_Box.new(self, 98, 48, 101, Configs::MAX_CHARACTERS) { enable_leader_button }
    @notice_box = Text_Box.new(self, 98, 74, 101, 64) { enable_notice_button }
    @kick_button = Button.new(self, 204, 22, Vocab::Ok) { kick_member }
    @leader_button = Button.new(self, 204, 48, Vocab::Ok) { change_leader }
    @notice_button = Button.new(self, 204, 74, Vocab::Ok) { change_notice }
    @colors = Cache.system('GuildColors')
    disable_buttons
  end
  
  def disable_buttons
    @kick_box.clear
    @leader_box.clear
    @notice_box.clear
    @kick_button.enable = false
    @leader_button.enable = false
    @notice_button.enable = false
  end
  
  def trigger
    self.visible ? hide : request_guild_data
  end
  
  def request_guild_data
    if $game_actors[1].guild.empty?
      $error_msg = Vocab::NotGuild
      return
    end
    $network.send_open_guild_window
  end
  
  def item
    @data[index]
  end
  
  def make_list
    # Impede que a lista de membros seja alterada
    #quando @data for apagado no refresh
    @data = $game_guild.members.clone
  end
  
  def refresh
    contents.clear
    @shutdown_button.visible = false
    @kick_box.visible = false
    @leader_box.visible = false
    @notice_box.visible = false
    @kick_button.visible = false
    @leader_button.visible = false
    @notice_button.visible = false
    if @tab_page.index == MAIN_PAGE
      main_page
    elsif @tab_page.index == MANAGE_PAGE
      manage_page
    else
      super
    end
    @tab_page.draw_border
  end
  
  def main_page
    @data.clear
    $game_guild.flag.each_with_index { |color_id, i| contents.fill_rect(i % 8 * 4 + 10, i / 8 * 4 + 5, 4, 4, color(color_id)) if color_id < 255 }
    draw_text(55, 7, 105, line_height, $game_actors[1].guild)
    change_color(system_color)
    draw_text(10, 45, 60, line_height, "#{Vocab::Leader}:")
    draw_text(10, 65, 80, line_height, "#{Vocab::Member}s:")
    change_color(text_color(3))
    draw_text(0, 85, contents_width, line_height, Vocab::Notice, 1)
    change_color(normal_color)
    draw_text(0, 45, contents_width - 8, line_height, $game_guild.leader, 2)
    draw_text(0, 65, contents_width - 8, line_height, "#{$game_guild.members.size}/#{Configs::MAX_GUILD_MEMBERS}", 2)
    word_wrap($game_guild.notice).each_with_index do |text, i|
      draw_text(0, line_height * i + 105, contents_width, line_height, text, 1)
    end
    @shutdown_button.text = $game_guild.leader == $game_actors[1].name ? Vocab::Delete : Vocab.shutdown
    @shutdown_button.visible = true
  end
  
  def manage_page
    @data.clear
    draw_text(7, 7, 85, line_height, "#{Vocab::Kick}:")
    draw_text(7, 33, 100, line_height, Vocab::NewLeader)
    draw_text(7, 59, 75, line_height, Vocab::Notice)
    @kick_box.visible = true
    @leader_box.visible = true
    @notice_box.visible = true
    @kick_button.visible = true
    @leader_button.visible = true
    @notice_button.visible = true
    enable = $game_guild.leader == $game_actors[1].name
    @kick_box.enable = enable
    @leader_box.enable = enable
    @notice_box.enable = enable
  end
  
  def draw_item(index)
    rect = item_rect_for_text(index)
    icon_index = index >= $game_guild.online_size ? Configs::PLAYER_ON_ICON : Configs::PLAYER_OFF_ICON
    rect2 = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap = Cache.system('Iconset')
    contents.blt(7, rect.y, bitmap, rect2)
    rect.x += 32
    draw_text(rect, @data[index])
    rect.x += 85
    draw_text(rect, $game_guild.leader == @data[index] ? Vocab::Leader : Vocab::Member)
  end
  
  def color(n)
    @colors.get_pixel(n % 8 * 8, n / 8 * 8)
  end
  
  def kick_member
    return if @kick_box.text == $game_actors[1].name
    $network.send_remove_guild_member(@kick_box.text)
    @kick_box.clear
    @kick_button.enable = false
  end
  
  def change_leader
    return if @leader_box.text == $game_actors[1].name
    $network.send_guild_leader(@leader_box.text)
    @leader_box.clear
    @leader_button.enable = false
  end
  
  def change_notice
    $network.send_guild_notice(@notice_box.text)
  end
  
  def enable_kick_button
    @kick_button.enable = (@kick_box.text.strip.size >= Configs::MIN_CHARACTERS)
  end
  
  def enable_leader_button
    @leader_button.enable = (@leader_box.text.strip.size >= Configs::MIN_CHARACTERS)
  end
  
  def enable_notice_button
    @notice_button.enable = !@notice_box.text.strip.empty?
  end
  
  def update
    super
    update_trigger
    private_chat
    ok
  end
  
  def update_trigger
    return unless index >= 0
    return unless $game_guild.leader == $game_actors[1].name
    return if $game_guild.leader == item
    if Input.trigger?(:DELETE)
      $windows[:choice].show(Vocab::Ask, Enums::Choice::REMOVE_GUILD_MEMBER, 0, item)
    elsif Input.trigger?(:LETTER_L)
      $windows[:choice].show(Vocab::Ask, Enums::Choice::CHANGE_GUILD_LEADER, 0, item)
    end
  end
  
  def private_chat
    return unless Mouse.dbl_clk?(:L)
    return unless index >= 0
    return if $game_actors[1].name == item
    $windows[:chat].private(item)
  end
  
  def ok
    return unless Input.trigger?(:C)
    return unless @tab_page.index == MANAGE_PAGE
    if @kick_box.active
      kick_member
    elsif @leader_box.active
      change_leader
    elsif @notice_box.active
      change_notice
    end
  end
  
end
