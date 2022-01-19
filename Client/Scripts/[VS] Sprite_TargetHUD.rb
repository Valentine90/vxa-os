#==============================================================================
# ** Sprite_TargetHUD
#------------------------------------------------------------------------------
#  Esta classe lida com a exibição de HP, nome e nível do
# alvo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Sprite_TargetHUD < Sprite2
  
  def initialize
    super
    self.bitmap = Bitmap.new(175, 72)
    # Cria os ícones, cuja visibilidade é alterada no
    #def visible, antes de chamá-lo
    create_all_icons
    self.x = adjust_x
    self.y = 63
    self.z = 50
    self.visible = false
    self.bitmap.font.size = 18
    self.bitmap.font.bold = true
    @dragable = true
  end
  
  def create_all_icons
    @icons = []
    @icons << Icon.new(nil, 0, 0, Configs::PRIVATE_ICON, Vocab::Private) { private_chat }
    @icons << Icon.new(nil, 0, 0, Configs::BLOCK_ICON, Vocab::Block) { block }
    @icons << Icon.new(nil, 0, 0, Configs::UNLOCK_ICON, Vocab::Unlock) { unlock }
    @icons << Icon.new(nil, 0, 0, Configs::FRIEND_ICON, Vocab::Friend) { add_friend }
    @icons << Icon.new(nil, 0, 0, Configs::TRADE_ICON, Vocab::Trade) { trade_request }
    @icons << Icon.new(nil, 0, 0, Configs::PARTY_ICON, Vocab::Party) { party_request }
    @icons << Icon.new(nil, 0, 0, Configs::GUILD_ICON, Vocab::Guild) { guild_request }
  end
  
  def adjust_x
    Graphics.width / 2 - 87
  end
  
  def dispose
    super
    @icons.each(&:dispose)
  end
  
  def visible=(visible)
    super
    visible_icons = (visible && $game_player.target.is_a?(Game_NetPlayer))
    @icons.each { |icon| icon.visible = visible_icons }
  end
  
  def hide
    self.visible = false
  end
  
  def x=(x)
    super
    value = 0
    @icons.each do |icon|
      icon.x = x + value
      value += 25
    end
  end
  
  def y=(y)
    super
    @icons.each { |icon| icon.y = self.y + 48 }
  end
  
  def refresh
    draw_name
    draw_level
    draw_hp_bar
  end
  
  def draw_name
    self.bitmap.clear
    self.bitmap.font.color.set(text_color(name_color))
    self.bitmap.draw_text(1, 0, self.bitmap.width, 18, $game_player.target.actor.name)
  end
  
  def name_color
    return Configs::ADMIN_COLOR if $game_player.target.admin?
    return Configs::MONITOR_COLOR if $game_player.target.monitor?
    return Configs::ENEMY_COLOR if $game_player.target.is_a?(Game_Event)
    return Configs::DEFAULT_COLOR
  end
  
  def draw_level
    self.bitmap.font.color.set(normal_color)
    self.bitmap.draw_text(0, 0, self.bitmap.width, 18, "#{Vocab::level_a}. #{$game_player.target.actor.level}", 2) if $game_player.target.is_a?(Game_NetPlayer)
  end
  
  def draw_hp_bar
    bitmap = Cache.system('TargetHPBar')
    rect = Rect.new(0, 0, self.bitmap.width, 26)
    self.bitmap.blt(0, 20, bitmap, rect)
    rect = Rect.new(0, 26, self.bitmap.width * $game_player.target.actor.hp / $game_player.target.actor.mhp, 26)
    self.bitmap.blt(0, 20, bitmap, rect)
    self.bitmap.draw_text(4, 25, 25, 18, Vocab::hp_a)
    self.bitmap.draw_text(0, 25, 173, 18, "#{$game_player.target.actor.hp}/#{$game_player.target.actor.mhp}", 2)
  end
  
  def private_chat
    $windows[:chat].private($game_player.target.actor.name)
  end
  
  def block
    return if $game_player.blocked.include?($game_player.target.actor.name)
    $game_player.blocked << $game_player.target.actor.name
    $windows[:chat].write_message("#{$game_player.target.actor.name} #{Vocab::Blocked}", Configs::ERROR_COLOR)
  end
  
  def unlock
    return unless $game_player.blocked.include?($game_player.target.actor.name)
    $game_player.blocked.delete($game_player.target.actor.name)
    $windows[:chat].write_message("#{$game_player.target.actor.name} #{Vocab::Unlocked}", Configs::SUCCESS_COLOR)
  end
  
  def add_friend
    if $game_actors[1].friends.include?($game_player.target.actor.name)
      $error_msg = Vocab::FriendExist
    elsif $game_actors[1].friends.size >= Configs::MAX_FRIENDS
      $error_msg = Vocab::FullFriends
    elsif !$game_player.in_range?($game_player.target, 10)
      $error_msg = Vocab::PlayerNotInRange
    else
      $network.send_request(Enums::Request::FRIEND, $game_player.target.id)
    end
  end
  
  def trade_request
    if !$game_player.in_range?($game_player.target, 10)
      $error_msg = Vocab::PlayerNotInRange
    elsif $windows[:my_trade].visible
      $error_msg = Vocab::InTrade
    else
      $network.send_request(Enums::Request::TRADE, $game_player.target.id)
    end
  end
  
  def party_request
    if $game_actors[1].party_members.size >= Configs::MAX_PARTY_MEMBERS - 1
      $error_msg = Vocab::FullParty
    elsif !$game_player.in_range?($game_player.target, 10)
      $error_msg = Vocab::PlayerNotInRange
    else
      $network.send_request(Enums::Request::PARTY, $game_player.target.id)
    end
  end
  
  def guild_request
    if $game_actors[1].guild_name.empty?
      $error_msg = Vocab::NotGuild
    elsif !$game_player.target.actor.guild_name.empty?
      $error_msg = "#{$game_player.target.actor.name} #{Vocab::PlayerInGuild} #{$game_player.target.actor.guild_name}."
    else
      $network.send_request(Enums::Request::GUILD, $game_player.target.id)
    end
  end
  
  def update
    super
    @icons.each { |icon| icon.update if icon.visible }
    change_opacity
  end
  
end
