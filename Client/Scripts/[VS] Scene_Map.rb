#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  Esta classe lida com a cena do mapa.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Scene_Map < Scene_Base
  
  def start
    super
    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    # Limpa as janelas antes do over_window? dos métodos
    #in_object_area? e in_drop_area? do update da
    #Spriteset_Map serem chamados quando o mouse estiver
    #sobre um evento, inimigo, jogador ou drop ao
    #instanciar a cena do mapa
    $windows.clear
    create_spriteset
    create_all_windows
  end
  
  def create_all_windows
    create_message_window
    create_scroll_text_window
    $windows[:hud] = Sprite_HUD.new
    $windows[:target_hud] = Sprite_TargetHUD.new
    $windows[:popup] = Sprite_Popup.new
    $windows[:party] = Sprite_Party.new
    $windows[:states] = Sprite_States.new
    $windows[:hotbar] = Sprite_Hotbar.new
    $windows[:minimap] = Sprite_Minimap.new
    $windows[:icon] = Window_Icon.new
    $windows[:chat] = Window_Chat.new
    # A Window_Amount é instanciada logo para que
    #a sua caixa de texto fique ativa ao pressionar o
    #botão do mouse duas vezes sobre o item na janela de
    #itens, loja, banco e troca
    $windows[:amount] = Window_Amount.new
    $windows[:equip] = Window_Equip.new
    $windows[:item] = Window_Item.new
    $windows[:skill] = Window_Skill.new
    $windows[:status] = Window_Status.new
    $windows[:menu] = Window_Menu.new
    $windows[:config] = Window_Config.new
    $windows[:shop] = Window_Shop.new
    $windows[:his_trade] = Window_HisTrade.new
    $windows[:my_trade] = Window_MyTrade.new
    $windows[:trade] = Window_Trade.new
    $windows[:bank] = Window_Bank.new
    $windows[:teleport] = Window_Teleport.new
    $windows[:teleportinfo] = Window_TeleportInfo.new
    $windows[:quest] = Window_Quest.new
    $windows[:quest_info] = Window_QuestInfo.new
    $windows[:friend] = Window_Friend.new
    $windows[:create_guild] = Window_CreateGuild.new
    $windows[:guild] = Window_Guild.new
    $windows[:choice] = Window_Choice.new
    $windows[:panel] = Window_Panel.new
    adjust_windows_position
  end
  
  def adjust_windows_position
    $windows[:hud].exp_sprite.x = $windows[:hud].adjust_x
    $windows[:hud].exp_sprite.y = $windows[:hud].adjust_y
    $windows[:target_hud].x = $windows[:target_hud].adjust_x
    $windows[:hotbar].x = $windows[:hotbar].adjust_x
    $windows[:hotbar].y = $windows[:hotbar].adjust_y
    $windows[:minimap].x = $windows[:minimap].adjust_x
    $windows[:chat].y = $windows[:chat].adjust_y
    $windows[:equip].x = $windows[:equip].adjust_x
    $windows[:item].x = $windows[:item].adjust_x
    $windows[:menu].x = $windows[:menu].adjust_x
    $windows[:config].x = $windows[:config].adjust_x
    $windows[:choice].x = $windows[:choice].adjust_x
    $windows[:panel].x = $windows[:panel].adjust_x
    $windows[:panel].y = $windows[:panel].adjust_y
    $windows[:icon].x = $windows[:icon].adjust_x
    $windows[:icon].y = $windows[:icon].adjust_y
    @message_window.x = @message_window.adjust_x
  end
  
  def add_player(id, player)
    # Só desenha os jogadores se spriteset já existe
    return unless @spriteset
    @spriteset.player_sprites[id] = Sprite_Character.new(@spriteset.viewport1, player)
  end
  
  def remove_player(id)
    return unless @spriteset
    @spriteset.player_sprites[id].dispose
    @spriteset.player_sprites.delete(id)
  end
  
  def add_drop(drop)
    return unless @spriteset
    @spriteset.drop_sprites << Sprite_Drop.new(@spriteset.viewport1, drop)
  end
  
  def remove_drop(id)
    return unless @spriteset
    @spriteset.drop_sprites[id].dispose
    @spriteset.drop_sprites.delete_at(id)
  end
  
  def add_projectile(projectile)
    return unless @spriteset
    @spriteset.projectile_sprites << Sprite_Projectile.new(@spriteset.viewport1, projectile)
  end
  
  def clear_map
    @spriteset.dispose_drops
    @spriteset.dispose_projectiles
    @spriteset.dispose_players
    $windows[:target_hud].hide
    $windows[:choice].hide
    $windows[:minimap].refresh
    $windows[:party].refresh
    $game_player.target = nil
  end
  
  def update_all_windows
    super
    @message_window.update if @message_window.visible
    @scroll_text_window.update
    show_balloon
  end
  
  def update_trigger
    close_all_windows
    return if $typing
    if Input.trigger?(Configs::ITEM_KEY)
      $windows[:equip].trigger
    elsif Input.trigger?(Configs::SKILL_KEY)
      $windows[:skill].trigger
    elsif Input.trigger?(Configs::STATUS_KEY)
      $windows[:status].trigger
    elsif Input.trigger?(Configs::QUEST_KEY)
      $windows[:quest].trigger
    elsif Input.trigger?(Configs::FRIEND_KEY)
      $windows[:friend].trigger
    elsif Input.trigger?(Configs::GUILD_KEY)
      $windows[:guild].trigger
    elsif Input.trigger?(Configs::MENU_KEY)
      $windows[:menu].trigger
    elsif Input.trigger?(:INSERT) && !$game_player.standard?
      $windows[:panel].trigger
    elsif Input.press?(:SHIFT) && Mouse.click?(:L) && $game_player.admin?
      $network.send_admin_command(Enums::Command::TELEPORT, $game_actors[1].name, $game_map.map_id, Mouse.tile_x, Mouse.tile_y)
    end
  end
  
  def show_balloon
    Configs::BALLOONS_KEYS.each_with_index do |key, i|
      next unless Input.trigger?(key)
      $network.send_balloon(i + 1)
      break
    end
  end
  
  def close_all_windows
    return unless Input.trigger?(:B)
    $windows[:equip].hide
    $windows[:skill].hide
    $windows[:status].hide
    $windows[:menu].hide
    $windows[:config].hide
    $windows[:shop].hide_window
    $windows[:bank].hide_window
    $windows[:teleport].hide
    $windows[:teleportinfo].hide
    $windows[:quest].hide
    $windows[:quest_info].hide
    $windows[:friend].hide
    $windows[:create_guild].hide
    $windows[:guild].hide
    $windows[:amount].hide
    $windows[:panel].hide
  end
  
  def dispose_all_windows
    super
    @message_window.dispose
    @scroll_text_window.dispose
  end
  
end
