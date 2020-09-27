#==============================================================================
# ** Handle_Data
#------------------------------------------------------------------------------
#  Este script recebe as mensagens do servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Handle_Data
  
  def handle_messages(message)
    buffer = Buffer_Reader.new(message)
    header = buffer.read_byte
    if @in_game
      handle_messages_game(header, buffer)
    else
      handle_messages_menu(header, buffer)
    end
  end
  
  def handle_messages_menu(header, buffer)
    case header
    when Enums::Packet::LOGIN
      handle_login(buffer)
    when Enums::Packet::FAIL_LOGIN
      handle_failed_login(buffer)
    when Enums::Packet::CREATE_ACCOUNT
      handle_create_account(buffer)
    when Enums::Packet::ACTOR
      handle_create_actor(buffer)
    when Enums::Packet::FAIL_CREATE_ACTOR
      handle_failed_create_actor
    when Enums::Packet::REMOVE_ACTOR
      handle_remove_actor(buffer)
    when Enums::Packet::USE_ACTOR
      handle_use_actor(buffer)
    end
  end
  
  def handle_messages_game(header, buffer)
    case header
    when Enums::Packet::MOTD
      handle_motd(buffer)
    when Enums::Packet::PLAYER_DATA
      handle_player_data(buffer)
    when Enums::Packet::REMOVE_PLAYER
      handle_remove_player(buffer)
    when Enums::Packet::PLAYER_MOVE
      handle_player_movement(buffer)
    when Enums::Packet::MAP_MSG
      handle_map_message(buffer)
    when Enums::Packet::CHAT_MSG
      handle_chat_message(buffer)
    when Enums::Packet::ALERT_MSG
      handle_alert_message(buffer)
    when Enums::Packet::ATTACK_PLAYER
      handle_attack_player(buffer)
    when Enums::Packet::ATTACK_ENEMY
      handle_attack_enemy(buffer)
    when Enums::Packet::ANIMATION
      handle_animation(buffer)
    when Enums::Packet::BALLOON
      handle_balloon(buffer)
    when Enums::Packet::ENEMY_REVIVE
      handle_enemy_revive(buffer)
    when Enums::Packet::EVENT_DATA
      handle_event_data(buffer)
    when Enums::Packet::EVENT_MOVE
      handle_event_movement(buffer)
    when Enums::Packet::ADD_DROP
      handle_add_drop(buffer)
    when Enums::Packet::REMOVE_DROP
      handle_remove_drop(buffer)
    when Enums::Packet::ADD_PROJECTILE
      handle_add_projectile(buffer)
    when Enums::Packet::PLAYER_VITALS
      handle_player_vitals(buffer)
    when Enums::Packet::PLAYER_EXP
      handle_player_exp(buffer)
    when Enums::Packet::PLAYER_STATE
      handle_player_state(buffer)
    when Enums::Packet::PLAYER_BUFF
      handle_player_buff(buffer)
    when Enums::Packet::PLAYER_ITEM
      handle_player_item(buffer)
    when Enums::Packet::PLAYER_GOLD
      handle_player_gold(buffer)
    when Enums::Packet::PLAYER_PARAM
      handle_player_param(buffer)
    when Enums::Packet::PLAYER_EQUIP
      handle_player_equip(buffer)
    when Enums::Packet::PLAYER_SKILL
      handle_player_skill(buffer)
    when Enums::Packet::PLAYER_CLASS
      handle_player_class(buffer)
    when Enums::Packet::PLAYER_SEX
      handle_player_sex(buffer)
    when Enums::Packet::PLAYER_GRAPHIC
      handle_player_graphic(buffer)
    when Enums::Packet::PLAYER_POINTS
      handle_player_points(buffer)
    when Enums::Packet::PLAYER_HOTBAR
      handle_player_hotbar(buffer)
    when Enums::Packet::TARGET
      handle_target(buffer)
    when Enums::Packet::TRANSFER
      handle_transfer_player(buffer)
    when Enums::Packet::OPEN_FRIENDS
      handle_open_friends(buffer)
    when Enums::Packet::ADD_FRIEND
      handle_add_friend(buffer)
    when Enums::Packet::REMOVE_FRIEND
      handle_remove_friend(buffer)
    when Enums::Packet::OPEN_CREATE_GUILD
      handle_open_create_guild
    when Enums::Packet::OPEN_GUILD
      handle_open_guild(buffer)
    when Enums::Packet::GUILD_LEADER
      handle_guild_leader(buffer)
    when Enums::Packet::GUILD_NOTICE
      handle_guild_notice(buffer)
    when Enums::Packet::GUILD_NAME
      handle_guild_name(buffer)
    when Enums::Packet::REMOVE_GUILD_MEMBER
      handle_remove_guild_member(buffer)
    when Enums::Packet::JOIN_PARTY
      handle_join_party(buffer)
    when Enums::Packet::LEAVE_PARTY
      handle_leave_party(buffer)
    when Enums::Packet::DISSOLVE_PARTY
      handle_dissolve_party
    when Enums::Packet::OPEN_BANK
      handle_open_bank(buffer)
    when Enums::Packet::BANK_ITEM
      handle_bank_item(buffer)
    when Enums::Packet::BANK_GOLD
      handle_bank_gold(buffer)
    when Enums::Packet::CLOSE_WINDOW
      handle_close_window
    when Enums::Packet::OPEN_SHOP
      handle_open_shop(buffer)
    when Enums::Packet::OPEN_TELEPORT
      handle_open_teleport(buffer)
    when Enums::Packet::EVENT_COMMAND
      handle_event_command(buffer)
    when Enums::Packet::REQUEST
      handle_request(buffer)
    when Enums::Packet::ACCEPT_REQUEST
      handle_accept_request(buffer)
    when Enums::Packet::TRADE_ITEM
      handle_trade_item(buffer)
    when Enums::Packet::TRADE_GOLD
      handle_trade_gold(buffer)
    when Enums::Packet::ADD_QUEST
      handle_add_quest(buffer)
    when Enums::Packet::FINISH_QUEST
      handle_finish_quest(buffer)
    when Enums::Packet::VIP_DAYS
      handle_vip_days(buffer)
    when Enums::Packet::LOGOUT
      handle_logout(buffer)
    when Enums::Packet::ADMIN_COMMAND
      handle_admin_command(buffer)
    when Enums::Packet::SWITCH
      handle_switch(buffer)
    when Enums::Packet::VARIABLE
      handle_variable(buffer)
    when Enums::Packet::SELF_SWITCH
      handle_player_self_switch(buffer)
    when Enums::Packet::NET_SWITCHES
      handle_global_switches(buffer)
    end
  end
  
  def handle_login(buffer)
    @group = buffer.read_byte
    @vip_time = buffer.read_time
    size = buffer.read_byte
    size.times { handle_actor(buffer) }
    $windows[:login].save_user
    SceneManager.goto(Scene_Character)
  end
  
  def handle_actor(buffer)
    actor_id = buffer.read_byte
    @actors[actor_id] = Actor.new
    @actors[actor_id].name = buffer.read_string
    @actors[actor_id].character_name = buffer.read_string
    @actors[actor_id].character_index = buffer.read_byte
    @actors[actor_id].face_name = buffer.read_string
    @actors[actor_id].face_index = buffer.read_byte
    @actors[actor_id].sex = buffer.read_byte
    @actors[actor_id].equips = [$data_weapons[buffer.read_short]]
    (Configs::MAX_EQUIPS - 1).times { @actors[actor_id].equips << $data_armors[buffer.read_short] }
  end
  
  def handle_failed_login(buffer)
    type = buffer.read_byte
    case type
    when Enums::Login::SERVER_FULL
      $windows[:alert].show(Vocab::ServerFull)
    when Enums::Login::IP_BANNED
      $windows[:alert].show(Vocab::IPBanned)
    when Enums::Login::OLD_VERSION
      $windows[:alert].show(Vocab::OldVersion)
    when Enums::Login::ACC_BANNED
      $windows[:alert].show(Vocab::AccBanned)
    when Enums::Login::INVALD_USER
      $windows[:alert].show(Vocab::InvalidUser)
    when Enums::Login::MULTI_ACCOUNT
      $windows[:alert].show(Vocab::MultiAccount)
    when Enums::Login::INVALID_PASS
      $windows[:alert].show(Vocab::InvalidPass)
    when Enums::Login::IP_BLOCKED
      if SceneManager.scene_is?(Scene_Login)
        $windows[:alert].show(Vocab::IPBlocked)
      else
        $alert_msg = Vocab::IPBlocked
      end
    when Enums::Login::INACTIVITY
      $alert_msg = Vocab::Inactivity
    end
  end
  
  def handle_create_account(buffer)
    type = buffer.read_byte
    case type
    when Enums::Register::ACC_EXIST
      $windows[:alert].show(Vocab::AccExist)
    when Enums::Register::SUCCESSFUL
      $windows[:alert].show(Vocab::Successful)
      $windows[:create_acc].login
    end
  end
  
  def handle_create_actor(buffer)
    handle_actor(buffer)
    $windows[:create_char].hide
  end
  
  def handle_failed_create_actor
    $windows[:alert].show(Vocab::CharExist)
  end
  
  def handle_remove_actor(buffer)
    actor_id = buffer.read_byte
    @actors.delete(actor_id)
    $windows[:use_char].refresh
  end
  
  def handle_use_actor(buffer)
    # Reseta as informações caso o usuário já tenha
    #entrado anteriormente
    DataManager.create_game_objects
    $game_party.setup_starting_members
    @player_id = buffer.read_short
    $game_player.group = @group
    $game_actors[1].name = buffer.read_string
    $game_actors[1].set_graphic(buffer.read_string, buffer.read_byte, buffer.read_string, buffer.read_byte)
    $game_actors[1].change_class(buffer.read_short)
    $game_actors[1].sex = buffer.read_byte
    Configs::MAX_EQUIPS.times { |slot_id| $game_actors[1].change_equip_by_id(slot_id, buffer.read_short) }
    8.times { |param_id| $game_actors[1].add_param(param_id, buffer.read_int) }
    $game_actors[1].hp = buffer.read_int
    $game_actors[1].mp = buffer.read_int
    $game_actors[1].change_exp(buffer.read_int, false)
    $game_actors[1].points = buffer.read_short
    $game_actors[1].guild = buffer.read_string
    $game_party.gain_gold(buffer.read_int)
    size = buffer.read_byte
    size.times { $game_party.gain_item($data_items[buffer.read_short], buffer.read_short) }
    size = buffer.read_byte
    size.times { $game_party.gain_item($data_weapons[buffer.read_short], buffer.read_short) }
    size = buffer.read_byte
    size.times { $game_party.gain_item($data_armors[buffer.read_short], buffer.read_short) }
    size = buffer.read_byte
    size.times { $game_actors[1].learn_skill(buffer.read_short) }
    size = buffer.read_byte
    size.times { $game_actors[1].friends << buffer.read_string }
    size = buffer.read_byte
    size.times do
      quest_id = buffer.read_byte
      $game_actors[1].quests[quest_id] = Game_Quest.new(quest_id, buffer.read_byte)
    end
    Configs::MAX_HOTBAR.times { |id| $game_actors[1].change_hotbar(id, buffer.read_byte, buffer.read_short)} 
    Configs::MAX_PLAYER_SWITCHES.times { |switch_id| $game_switches[switch_id] = buffer.read_boolean}
    Configs::MAX_PLAYER_VARIABLES.times { |variable_id| $game_variables[variable_id] = buffer.read_short }
    size = buffer.read_short
    size.times do
      key = [buffer.read_short, buffer.read_short, buffer.read_string]
      $game_self_switches[key] = buffer.read_boolean
    end
    $game_map.setup(buffer.read_short)
    $game_player.moveto(buffer.read_short, buffer.read_short)
    $game_player.set_direction(buffer.read_byte)
    $game_player.refresh
    Graphics.frame_count = 0
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
    $game_map.autoplay
    @in_game = true
    # Limpa o typing da caixa de texto de senha da
    #janela de entrada, caso esteja ativa
    $typing = nil
    $wait_player_move = false
    SceneManager.goto(Scene_Map)
  end
  
  def handle_motd(buffer)
    @motd = buffer.read_string
  end
  
  def handle_player_data(buffer)
    player_id = buffer.read_short
    $game_map.players[player_id] = Game_NetPlayer.new(player_id)
    $game_map.players[player_id].group = buffer.read_byte
    $game_map.players[player_id].actor.name = buffer.read_string
    $game_map.players[player_id].actor.set_graphic(buffer.read_string, buffer.read_byte, '', 0)
    $game_map.players[player_id].actor.sex = buffer.read_byte
    Configs::MAX_EQUIPS.times { |slot_id| $game_map.players[player_id].actor.change_equip_by_id(slot_id, buffer.read_short) }
    $game_map.players[player_id].actor.add_param(0, buffer.read_int)
    $game_map.players[player_id].actor.hp = buffer.read_int
    $game_map.players[player_id].actor.change_exp(buffer.read_int, false)
    $game_map.players[player_id].actor.guild = buffer.read_string
    $game_map.players[player_id].moveto(buffer.read_short, buffer.read_short)
    $game_map.players[player_id].set_direction(buffer.read_byte)
    $game_map.players[player_id].refresh
    SceneManager.scene.add_player(player_id, $game_map.players[player_id])
    if $game_actors[1].party_members.has_key?(player_id)
      $game_actors[1].party_members[player_id] = $game_map.players[player_id]
      $windows[:party].refresh
    end
  end
  
  def handle_remove_player(buffer)
    player_id = buffer.read_short
    $game_map.players.delete(player_id)
    SceneManager.scene.remove_player(player_id)
    $windows[:party].refresh if $game_actors[1].party_members.has_key?(player_id)
  end
  
  def handle_player_movement(buffer)
    player_id = buffer.read_short
    x = buffer.read_short
    y = buffer.read_short
    d = buffer.read_byte
    if @player_id == player_id
      $game_player.move(x, y, d)
      $wait_player_move = false
      $windows[:hud].change_opacity
    else
      $game_map.players[player_id].move(x, y, d)
    end
  end
  
  def handle_map_message(buffer)
    player_id = buffer.read_short
    color_id = buffer.read_byte
    message = buffer.read_string
    # Se a scene não já foi inteiramente carregada
    return unless $windows.has_key?(:chat)
    index = message.index(': ')
    name = message[0, index]
    msg = message[index + 2..message.size]
    unless $game_player.blocked.include?(name)
      $windows[:chat].write_message(message, color_id)
      player = @player_id == player_id ? $game_player : $game_map.players[player_id]
      player.message = $windows[:chat].word_wrap(msg, 217) if $game_map.in_screen?(player)
    end
  end
  
  def handle_chat_message(buffer)
    color_id = buffer.read_byte
    message = buffer.read_string
    return unless $windows.has_key?(:chat)
    # Garante que o índice não seja nulo
    name = message[0, message.index(': ').to_i]
    $windows[:chat].write_message(message, color_id) unless $game_player.blocked.include?(name)
  end
  
  def handle_alert_message(buffer)
    type = buffer.read_byte
    case type
    when Enums::Alert::INVALID_NAME
      $windows[:chat].write_message(Vocab::InvalidName, Configs::ERROR_COLOR)
    when Enums::Alert::TELEPORTED
      $windows[:chat].write_message(Vocab::Teleported, Configs::SUCCESS_COLOR)
    when Enums::Alert::PULLED
      $windows[:chat].write_message(Vocab::Pulled, Configs::SUCCESS_COLOR)
    when Enums::Alert::ATTACK_ADMIN
      $error_msg = Vocab::AttackAdmin
    when Enums::Alert::BUSY
      $error_msg = Vocab::Busy
    when Enums::Alert::IN_PARTY
      $error_msg = Vocab::InParty
    when Enums::Alert::IN_GUILD
      $error_msg = Vocab::YouInGuild
    when Enums::Alert::GUILD_EXIST
      $error_msg = Vocab::GuildExist
    when Enums::Alert::NOT_GUILD_LEADER
      $error_msg = Vocab::NotGuildLeader
    when Enums::Alert::FULL_GUILD
      $error_msg = Vocab::FullGuild
    when Enums::Alert::NOT_PICK_UP_DROP
      $error_msg = Vocab::NotPickUpDrop
    when Enums::Alert::REQUEST_DECLINED
      $windows[:chat].write_message(Vocab::RequestDeclined, Configs::ERROR_COLOR)
    when Enums::Alert::TRADE_DECLINED
      $windows[:chat].write_message(Vocab::TradeDeclined, Configs::ERROR_COLOR)
    when Enums::Alert::TRADE_FINISHED
      $windows[:chat].write_message(Vocab::TradeFinished, Configs::SUCCESS_COLOR)
    when Enums::Alert::FULL_INV
      $error_msg = Vocab::FullInventory
    when Enums::Alert::FULL_TRADE
      $error_msg = Vocab::FullTrade
    when Enums::Alert::FULL_BANK
      $error_msg = Vocab::FullBank
    when Enums::Alert::MUTED
      $windows[:chat].write_message(Vocab::Muted, Configs::ERROR_COLOR)
    end
  end
  
  def handle_attack_player(buffer)
    attacker_id = buffer.read_short
    attacker_type = buffer.read_byte
    ani_index = buffer.read_byte
    player_id = buffer.read_short
    hp_damage = buffer.read_int
    mp_damage = buffer.read_int
    critical = buffer.read_boolean
    animation_id = buffer.read_short
    not_show_missed = buffer.read_boolean
    attacker = attacker_type == 1 ? $game_map.events[attacker_id] : attacker_id == @player_id ? $game_player : $game_map.players[attacker_id]
    attacker.animate_attack(ani_index)
    if @player_id == player_id
      $game_actors[1].hp += hp_damage
      $game_actors[1].mp += mp_damage
      if $game_actors[1].dead?
        $game_player.die
      else
        $game_player.change_damage(hp_damage, mp_damage, critical, animation_id, not_show_missed)
        $game_map.screen.start_shake(4, 4, 20) if critical
      end
      if $windows.has_key?(:hud)
        $windows[:hud].refresh
        $windows[:status].refresh if $windows[:status].visible
      end
    else
      $game_map.players[player_id].actor.hp += hp_damage
      $game_map.players[player_id].actor.mp += mp_damage
      $game_map.players[player_id].change_damage(hp_damage, mp_damage, critical, animation_id, not_show_missed) if $game_map.in_screen?($game_map.players[player_id]) && !$game_map.players[player_id].actor.dead?
      $windows[:target_hud].refresh if $game_map.players[player_id] == $game_player.target && !$game_map.players[player_id].actor.dead?
    end
  end
  
  def handle_attack_enemy(buffer)
    attacker_id = buffer.read_short
    attacker_type = buffer.read_byte
    ani_index = buffer.read_byte
    event_id = buffer.read_short
    hp_damage = buffer.read_int
    mp_damage = buffer.read_int
    critical = buffer.read_boolean
    animation_id = buffer.read_short
    attacker = attacker_type == 1 ? $game_map.events[attacker_id] : attacker_id == @player_id ? $game_player : $game_map.players[attacker_id]
    attacker.animate_attack(ani_index)
    $game_map.events[event_id].actor.hp += hp_damage
    $game_map.events[event_id].actor.mp += mp_damage
    $game_map.events[event_id].change_damage(hp_damage, mp_damage, critical, animation_id) if $game_map.in_screen?($game_map.events[event_id])
    $game_map.events[event_id].erase if $game_map.events[event_id].actor.dead?
    # Se o inimigo é o alvo e ele não morreu
    $windows[:target_hud].refresh if $game_map.events[event_id] == $game_player.target && $game_map.events[event_id].actor?
  end
  
  def handle_animation(buffer)
    attacker_id = buffer.read_short
    attacker_type = buffer.read_byte
    ani_index = buffer.read_byte
    character_id = buffer.read_short
    character_type = buffer.read_byte
    animation_id = buffer.read_short
    attacker = attacker_type == 1 ? $game_map.events[attacker_id] : attacker_id == @player_id ? $game_player : $game_map.players[attacker_id]
    attacker.animate_attack(ani_index)
    if character_type == Enums::Target::ENEMY
      $game_map.events[character_id].animation_id = animation_id if $game_map.in_screen?($game_map.events[character_id])
    elsif @player_id == character_id
      $game_player.animation_id = animation_id
    elsif $game_map.in_screen?($game_map.players[character_id])
      $game_map.players[character_id].animation_id = animation_id
    end
  end
  
  def handle_balloon(buffer)
    character_id = buffer.read_short
    character_type = buffer.read_byte
    balloon_id = buffer.read_byte
    if character_type == Enums::Target::ENEMY
      $game_map.events[character_id].balloon_id = balloon_id if $game_map.in_screen?($game_map.events[character_id])
    elsif @player_id == character_id
      $game_player.balloon_id = balloon_id
    elsif $game_map.in_screen?($game_map.players[character_id])
      $game_map.players[character_id].balloon_id = balloon_id
    end
  end
  
  def handle_enemy_revive(buffer)
    event_id = buffer.read_short
    $game_map.events[event_id].erased = false
    $game_map.events[event_id].refresh
    # Cancela a animação de ataque do inimigo que foi morto
    #por outro jogador enquanto a janela estava minimizada
    $game_map.events[event_id].animation_id = 0
  end
  
  def handle_event_data(buffer)
    event_id = buffer.read_short
    x = buffer.read_short
    y = buffer.read_short
    d = buffer.read_byte
    hp = buffer.read_int
    unless $game_map.events[event_id]
      msgbox("Os dados dos mapas do servidor estão desatualizados! O evento #{event_id} não existe mais neste mapa, embora ainda conste no servidor.")
      exit
    end
    # Evita alinhamento dos eventos fixos
    $game_map.events[event_id].moveto(x, y) unless $game_map.events[event_id].x == x && $game_map.events[event_id].y == y
    # Evita que a direção da página global do evento no
    #servidor prevaleça sobre a direção da página atual
    #do evento com movimento fixo
    $game_map.events[event_id].set_direction(d) unless $game_map.events[event_id].fixed_movement?
    if $game_map.events[event_id].actor
      $game_map.events[event_id].actor.hp = hp
      $game_map.events[event_id].erase if $game_map.events[event_id].actor.dead?
    end
  end
  
  def handle_event_movement(buffer)
    event_id = buffer.read_short
    x = buffer.read_short
    y = buffer.read_short
    d = buffer.read_byte
    $game_map.events[event_id].move(x, y, d)
  end
  
  def handle_add_drop(buffer)
    item_id = buffer.read_short
    kind = buffer.read_byte
    amount = buffer.read_short
    x = buffer.read_short
    y = buffer.read_short
    item = $game_party.item_object(kind, item_id)
    $game_map.drops << Game_Drop.new(item.name, item.icon_index, item.is_a?(RPG::Item) && item.key_item?, amount, x, y)
    SceneManager.scene.add_drop($game_map.drops.last)
  end
  
  def handle_remove_drop(buffer)
    drop_id = buffer.read_byte
    $game_map.drops.delete_at(drop_id)
    SceneManager.scene.remove_drop(drop_id)
  end
  
  def handle_add_projectile(buffer)
    start_x = buffer.read_short
    start_y = buffer.read_short
    finish_x = buffer.read_short
    finish_y = buffer.read_short
    target_x = buffer.read_short
    target_y = buffer.read_short
    projectile_type = buffer.read_byte
    projectile_id = buffer.read_byte
    if $game_map.in_screen?(start_x, start_y) || $game_map.in_screen?(finish_x, finish_y)
      projectile = projectile_type == Enums::Projectile::WEAPON ? Configs::RANGE_WEAPONS[projectile_id] : Configs::RANGE_SKILLS[projectile_id]
      $game_map.projectiles << Game_Projectile.new(start_x, start_y, finish_x, finish_y, target_x, target_y, projectile)
      SceneManager.scene.add_projectile($game_map.projectiles.last)
    end
  end
  
  def handle_player_vitals(buffer)
    player_id = buffer.read_short
    hp = buffer.read_int
    mp = buffer.read_int
    if @player_id == player_id
      dif_hp = hp - $game_actors[1].hp
      dif_mp = mp - $game_actors[1].mp
      $game_actors[1].hp = hp
      $game_actors[1].mp = mp
      $game_player.change_damage(dif_hp, dif_mp) unless dif_hp == 0 && dif_mp <= 0
      # Se a conexão estiver muito lenta e o personagem
      #recuperar HP ou MP antes da Scene_Map ser carregada
      if $windows.has_key?(:hud)
        $windows[:hud].refresh
        $windows[:status].refresh if $windows[:status].visible
      end
    else
      $game_map.players[player_id].actor.hp = hp
      $game_map.players[player_id].actor.mp = mp
      $windows[:target_hud].refresh if $game_map.players[player_id] == $game_player.target
      if $game_actors[1].party_members.has_key?(player_id)
        $game_actors[1].party_members[player_id] = $game_map.players[player_id]
        $windows[:party].refresh
      end
    end
  end
  
  def handle_player_exp(buffer)
    player_id = buffer.read_short
    exp = buffer.read_int
    if @player_id == player_id
      # Mostra apenas quando o herói ganha experiência e
      #não quando morre e a perde
      $game_actors[1].result.exp = exp if exp > 0
      # Aumenta ou diminui experiência
      $game_actors[1].change_exp($game_actors[1].exp + exp, true)
      $windows[:hud].refresh
    else
      $game_map.players[player_id].actor.result.exp = exp if exp > 0 && $game_map.in_screen?($game_map.players[player_id])
      $game_map.players[player_id].actor.change_exp($game_map.players[player_id].actor.exp + exp, false)
      if $game_actors[1].party_members.has_key?(player_id) && $game_actors[1].party_members[player_id].actor.level != $game_map.players[player_id].actor.level
        $game_actors[1].party_members[player_id] = $game_map.players[player_id]
        $windows[:party].refresh
      end
    end
  end
  
  def handle_player_state(buffer)
    state_id = buffer.read_short
    add_state = buffer.read_boolean
    if add_state
      $game_actors[1].add_state(state_id)
    else
      $game_actors[1].remove_state(state_id)
    end
    $windows[:states].visible = $game_actors[1].result.status_affected?
    $windows[:states].refresh if $windows[:states].visible
  end
  
  def handle_player_buff(buffer)
    param_id = buffer.read_byte
    buff_level = buffer.read_short
    if buff_level == 1
      $game_actors[1].add_buff(param_id, 0)
    elsif buff_level == -1
      $game_actors[1].add_debuff(param_id, 0)
    else
      $game_actors[1].remove_buff(param_id)
    end
    $windows[:states].visible = $game_actors[1].result.status_affected?
    $windows[:states].refresh if $windows[:states].visible
    # Se alterou o HP ou o MP máximo
    $windows[:hud].refresh if param_id < 2
    $windows[:status].refresh if $windows[:status].visible
  end
  
  def handle_player_item(buffer)
    item_id = buffer.read_short
    kind = buffer.read_byte
    amount = buffer.read_short
    drop_sound = buffer.read_boolean
    popup = buffer.read_boolean
    item = $game_party.item_object(kind, item_id)
    $game_party.gain_item(item, amount)
    $windows[:item].refresh if $windows[:item].visible
    $windows[:hotbar].refresh if $game_actors[1].hotbar.include?(item)
    $windows[:popup].show(item.name, item.icon_index, amount, item.is_a?(RPG::Item) && item.key_item?) if popup
    Sound.play_ok if drop_sound
  end
  
  def handle_player_gold(buffer)
    amount = buffer.read_int
    shop_sound = buffer.read_boolean
    popup = buffer.read_boolean
    $game_party.gain_gold(amount)
    $windows[:item].refresh_gold_bar if $windows[:item].visible
    $windows[:shop].refresh if $windows[:shop].visible
    $windows[:popup].show(Vocab.currency_unit, Configs::GOLD_ICON, amount) if popup
    Sound.play_shop if shop_sound
  end
  
  def handle_player_param(buffer)
    player_id = buffer.read_short
    param_id = buffer.read_byte
    value = buffer.read_short
    if @player_id == player_id
      $game_actors[1].add_param(param_id, value)
      $windows[:status].refresh if $windows[:status].visible
      # Se alterou o HP ou o MP máximo
      $windows[:hud].refresh if param_id < 2
    else
      $game_map.players[player_id].actor.add_param(param_id, value)
      $windows[:target_hud].refresh if param_id < 2 && $game_player.target == $game_map.players[player_id]
      if $game_actors[1].party_members.has_key?(player_id) && param_id == 0
        $game_actors[1].party_members[player_id] = $game_map.players[player_id]
        $windows[:party].refresh
      end
    end
  end
  
  def handle_player_equip(buffer)
    player_id = buffer.read_short
    slot_id = buffer.read_byte
    item_id = buffer.read_short
    if @player_id == player_id
      $game_actors[1].change_equip_by_id(slot_id, item_id)
      $windows[:equip].refresh
      # Se o equipamento que aumentava HP e/ou MP
      #máximo foi removido
      $windows[:hud].refresh
      # Se alterou algum parâmetro
      $windows[:status].refresh if $windows[:status].visible
      # Se ganhou ou perdeu alguma habilidade
      $windows[:skill].refresh if $windows[:skill].visible
      $windows[:hotbar].refresh
      Sound.play_equip
    else
      $game_map.players[player_id].actor.change_equip_by_id(slot_id, item_id)
      $windows[:target_hud].refresh if $game_player.target == $game_map.players[player_id]
      if $game_actors[1].party_members.has_key?(player_id)
        $game_actors[1].party_members[player_id] = $game_map.players[player_id]
        $windows[:party].refresh
      end
    end
  end
  
  def handle_player_skill(buffer)
    skill_id = buffer.read_short
    learn = buffer.read_boolean
    if learn
      $game_actors[1].learn_skill(skill_id)
    else
      $game_actors[1].forget_skill(skill_id)
    end
    $windows[:skill].refresh if $windows[:skill].visible
    # Se ganhou ou perdeu alguma habilidade que estava na hotbar
    $windows[:hotbar].refresh if $game_actors[1].hotbar.include?($data_skills[skill_id])
  end
  
  def handle_player_class(buffer)
    class_id = buffer.read_short
    $game_actors[1].change_class(class_id, true)
    $windows[:status].refresh if $windows[:status].visible
  end
  
  def handle_player_sex(buffer)
    player_id = buffer.read_short
    sex = buffer.read_byte
    player = @player_id == player_id ? $game_actors[1] : $game_map.players[player_id].actor
    player.sex = sex
    if $game_actors[1].party_members.has_key?(player_id)
      $game_actors[1].party_members[player_id] = $game_map.players[player_id]
      $windows[:party].refresh
    end
  end
  
  def handle_player_graphic(buffer)
    player_id = buffer.read_short
    character_name = buffer.read_string
    character_index = buffer.read_byte
    face_name = buffer.read_string
    face_index = buffer.read_byte
    if @player_id == player_id
      $game_actors[1].set_graphic(character_name, character_index, face_name, face_index)
      $game_player.refresh
      $windows[:hud].refresh
    else
      $game_map.players[player_id].actor.set_graphic(character_name, character_index, face_name, face_index)
      $game_map.players[player_id].refresh
      if $game_actors[1].party_members.has_key?(player_id)
        $game_actors[1].party_members[player_id] = $game_map.players[player_id]
        $windows[:party].refresh
      end
    end
  end
  
  def handle_player_points(buffer)
    $game_actors[1].points = buffer.read_short
    $windows[:status].refresh if $windows[:status].visible
  end
  
  def handle_player_hotbar(buffer)
    id = buffer.read_byte
    type = buffer.read_byte
    item_id = buffer.read_short
    $game_actors[1].change_hotbar(id, type, item_id)
    $windows[:hotbar].refresh
  end
  
  def handle_target(buffer)
    target_type = buffer.read_byte
    target_id = buffer.read_short
    $game_player.target = target_type == Enums::Target::PLAYER ? $game_map.players[target_id] :$game_map.events[target_id]
    # Se o inimigo não é um boss, que já tem uma HUD
    #própria fixada no centro da tela
    $windows[:target_hud].visible = ($game_player.has_target? && $game_player.target.actor? && !$game_player.target.boss?)
    $windows[:target_hud].refresh if $windows[:target_hud].visible
  end
  
  def handle_transfer_player(buffer)
    map_id = buffer.read_short
    x = buffer.read_short
    y = buffer.read_short
    d = buffer.read_byte
    $game_player.reserve_transfer(map_id, x, y, d)
    $game_player.perform_transfer
  end
  
  def handle_open_friends(buffer)
    size = buffer.read_byte
    online_friends = []
    size.times { online_friends << buffer.read_string }
    offline_friends = $game_actors[1].friends - online_friends
    $game_actors[1].friends = online_friends + offline_friends
    $game_actors[1].online_friends_size = size
    $windows[:friend].show
  end
  
  def handle_add_friend(buffer)
    name = buffer.read_string
    $game_actors[1].friends.insert($game_actors[1].online_friends_size, name)
    $game_actors[1].online_friends_size += 1
    $windows[:friend].refresh if $windows[:friend].visible
    $windows[:chat].write_message("#{name} #{Vocab::FriendAdded}", Configs::SUCCESS_COLOR)
  end
  
  def handle_remove_friend(buffer)
    index = buffer.read_byte
    $game_actors[1].friends.delete_at(index)
    $game_actors[1].online_friends_size -= 1 if index <= $game_actors[1].online_friends_size - 1
    $windows[:friend].refresh
  end
  
  def handle_open_create_guild
    $windows[:create_guild].show
  end
  
  def handle_open_guild(buffer)
    $game_guild.leader = buffer.read_string
    $game_guild.notice = buffer.read_string
    $game_guild.flag = []
    64.times { $game_guild.flag << buffer.read_byte }
    members_size = buffer.read_byte
    $game_guild.online_size = buffer.read_byte
    $game_guild.members = []
    members_size.times { $game_guild.members << buffer.read_string }
    $windows[:guild].show
  end
  
  def handle_guild_leader(buffer)
    $game_guild.leader = buffer.read_string
    $windows[:guild].refresh
    $windows[:guild].disable_buttons
  end
  
  def handle_guild_notice(buffer)
    $game_guild.notice = buffer.read_string
    $windows[:guild].refresh
  end
  
  def handle_guild_name(buffer)
    name = buffer.read_string
    player_id = buffer.read_short
    if @player_id == player_id
      $game_actors[1].guild = name
      # Se o membro foi expulso da guilda ou ela foi
      #deletada e estava com a janela aberta
      if name.empty?
        $windows[:guild].hide
        $windows[:guild].disable_buttons
      end
    else
      $game_map.players[player_id].actor.guild = name
    end
  end
  
  def handle_remove_guild_member(buffer)
    player_name = buffer.read_string
    $game_guild.members.delete(player_name)
    $windows[:guild].refresh
  end
  
  def handle_join_party(buffer)
    player_id = buffer.read_short
    $game_actors[1].party_members[player_id] = Game_NetPlayer.new(player_id)
    $game_actors[1].party_members[player_id].actor.name = buffer.read_string
    $game_actors[1].party_members[player_id].actor.set_graphic(buffer.read_string, buffer.read_byte, '', 0)
    $game_actors[1].party_members[player_id].actor.sex = buffer.read_byte
    Configs::MAX_EQUIPS.times { |slot_id| $game_actors[1].party_members[player_id].actor.change_equip_by_id(slot_id, buffer.read_short) }
    $game_actors[1].party_members[player_id].actor.add_param(0, buffer.read_int)
    $game_actors[1].party_members[player_id].actor.hp = buffer.read_int
    $game_actors[1].party_members[player_id].actor.change_exp(buffer.read_int, false)
    $windows[:chat].write_message("#{$game_actors[1].party_members[player_id].actor.name} #{Vocab::PartyMemberJoined}", Configs::SUCCESS_COLOR)
    $windows[:party].show
  end
  
  def handle_leave_party(buffer)
    player_id = buffer.read_short
    $windows[:chat].write_message("#{$game_actors[1].party_members[player_id].actor.name} #{Vocab::PartyMemberLeave}", Configs::ERROR_COLOR)
    $game_actors[1].party_members.delete(player_id)
    $windows[:party].refresh
  end
  
  def handle_dissolve_party
    $windows[:chat].write_message(Vocab::DissolvedParty, Configs::ERROR_COLOR)
    $game_actors[1].party_members.clear
    $windows[:party].hide
  end
  
  def handle_open_bank(buffer)
    $game_bank.gain_gold(buffer.read_int)
    size = buffer.read_byte
    size.times { $game_bank.gain_item($data_items[buffer.read_short], buffer.read_short) }
    size = buffer.read_byte
    size.times { $game_bank.gain_item($data_weapons[buffer.read_short], buffer.read_short) }
    size = buffer.read_byte
    size.times { $game_bank.gain_item($data_armors[buffer.read_short], buffer.read_short) }
    $game_bank.open
  end
  
  def handle_bank_item(buffer)
    item_id = buffer.read_short
    kind = buffer.read_byte
    amount = buffer.read_short
    item = $game_party.item_object(kind, item_id)
    $game_bank.gain_item(item, amount)
    $windows[:bank].tab_page.index = kind - 1
    $windows[:bank].refresh
  end
  
  def handle_bank_gold(buffer)
    amount = buffer.read_int
    $game_bank.gain_gold(amount)
    $windows[:bank].refresh_gold_bar
  end
  
  def handle_close_window
    if $windows[:bank].visible
      $game_bank.close
    elsif $windows[:shop].visible
      $windows[:shop].hide
      $windows[:equip].hide
      $windows[:amount].hide
    elsif $windows[:trade].visible
      $game_trade.close
    end
    $windows[:teleport].hide
    $windows[:teleportinfo].hide
    $windows[:create_guild].hide
  end
  
  def handle_open_shop(buffer)
    event_id = buffer.read_short
    index = buffer.read_short
    list = $game_map.events[event_id].list
    goods = [list[index].parameters]
    while list[index + 1].code == 605
      index += 1
      goods << list[index].parameters
    end
    $windows[:shop].show(goods, goods[0][4])
    $windows[:equip].show
  end
  
  def handle_open_teleport(buffer)
    teleport_id = buffer.read_byte
    $windows[:teleport].show(teleport_id)
  end
  
  def handle_event_command(buffer)
    event_id = buffer.read_short
    initial_index = buffer.read_short
    final_index = buffer.read_short
    # Se é um evento com condição de início processo paralelo,
    #os comandos são executados no interpretador do próprio
    #evento, que não trava o movimento do jogador
    if event_id > 0 && $game_map.events[event_id].trigger == 4
      $game_map.events[event_id].interpreter.setup($game_map.events[event_id].list[initial_index..final_index] + [$game_map.events[event_id].list.last], event_id)
    elsif event_id > 0
      $game_map.interpreter.setup($game_map.events[event_id].list[initial_index..final_index] + [$game_map.events[event_id].list.last], event_id)
    else
      $game_map.interpreter.setup($data_common_events[event_id.abs].list[initial_index..final_index] + [$data_common_events[event_id.abs].list.last], event_id)
    end
  end
  
  def handle_request(buffer)
    type = buffer.read_byte
    player_name = buffer.read_string
    guild_name = buffer.read_string
    case type
    when Enums::Request::TRADE
      $windows[:choice].show("#{player_name} #{Vocab::TradeRequest}", Enums::Choice::REQUEST)
    when Enums::Request::FINISH_TRADE
      $windows[:choice].show("#{player_name} #{Vocab::TradeComplete}", Enums::Choice::FINISH_TRADE)
    when Enums::Request::PARTY
      $windows[:choice].show("#{player_name} #{Vocab::PartyRequest}", Enums::Choice::REQUEST)
    when Enums::Request::FRIEND
      $windows[:choice].show("#{player_name} #{Vocab::FriendRequest}", Enums::Choice::REQUEST)
    when Enums::Request::GUILD
      $windows[:choice].show("#{player_name} #{sprintf(Vocab::GuildRequest, guild_name)}", Enums::Choice::REQUEST)
    end
  end
  
  def handle_accept_request(buffer)
    type = buffer.read_byte
    case type
    when Enums::Request::TRADE
      $game_trade.open
    when Enums::Request::FINISH_TRADE
      $game_trade.close
    end
  end
  
  def handle_trade_item(buffer)
    player_id = buffer.read_short
    item_id = buffer.read_short
    kind = buffer.read_byte
    amount = buffer.read_short
    item = $game_party.item_object(kind, item_id)
    if @player_id == player_id
      $game_trade.gain_my_item(item, amount)
      $windows[:item].refresh
      $windows[:my_trade].refresh
    else
      $game_trade.gain_his_item(item, amount)
      $windows[:his_trade].refresh
    end
    $windows[:choice].hide if $windows[:choice].finish_trade?
  end
  
  def handle_trade_gold(buffer)
    player_id = buffer.read_short
    amount = buffer.read_int
    if @player_id == player_id
      $game_trade.gain_my_gold(amount)
      $windows[:item].refresh_gold_bar
      $windows[:my_trade].refresh_gold_bar
    else
      $game_trade.gain_his_gold(amount)
      $windows[:his_trade].refresh_gold_bar
    end
    $windows[:choice].hide if $windows[:choice].finish_trade?
  end
  
  def handle_add_quest(buffer)
    quest_id = buffer.read_byte
    $game_actors[1].quests[quest_id] = Game_Quest.new(quest_id)
    $windows[:chat].write_message("#{Vocab::StartQuest} #{$game_actors[1].quests[quest_id].name}", Configs::SUCCESS_COLOR)
    $windows[:quest].refresh if $windows[:quest].visible
    $game_map.need_refresh = true
  end
  
  def handle_finish_quest(buffer)
    quest_id = buffer.read_byte
    $game_actors[1].quests[quest_id].state = Enums::Quest::FINISHED
    $windows[:chat].write_message("#{Vocab::FinishQuest} #{$game_actors[1].quests[quest_id].name}", Configs::SUCCESS_COLOR)
    if $game_actors[1].quests[quest_id].repeat?
      $windows[:quest_info].hide if $windows[:quest_info].quest == $game_actors[1].quests[quest_id]
      $game_actors[1].quests.delete(quest_id)
    end
    $windows[:quest].refresh if $windows[:quest].visible
  end
  
  def handle_vip_days(buffer)
    @vip_time = buffer.read_time
  end
  
  def handle_logout(buffer)
    handle_actor(buffer)
    @in_game = false
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
    $data_system.title_bgm.play
    SceneManager.goto(Scene_Character)
  end
  
  def handle_admin_command(buffer)
    command = buffer.read_byte
    message = buffer.read_string
    case command
    when Enums::Command::BAN_IP
      $alert_msg = Vocab::IPBanned
    when Enums::Command::BAN_ACC
      $alert_msg = Vocab::AccBanned
    when Enums::Command::KICK
      $alert_msg = Vocab::Kicked
    when Enums::Command::MSG
      $admin_msg = message
    end
  end
  
  def handle_switch(buffer)
    switch_id = buffer.read_short
    value = buffer.read_boolean
    # Muda o switche e chama o need_refresh
    $game_switches[switch_id] = value
  end
  
  def handle_variable(buffer)
    variable_id = buffer.read_short
    value = buffer.read_short
    $game_variables[variable_id] = value
  end
  
  def handle_player_self_switch(buffer)
    map_id = buffer.read_short
    event_id = buffer.read_short
    ch = buffer.read_string
    value = buffer.read_boolean
    key = [map_id, event_id, ch]
    $game_self_switches[key] = value
  end
  
  def handle_global_switches(buffer)
    (Configs::MAX_PLAYER_SWITCHES...Configs::MAX_PLAYER_SWITCHES + 100).each do |switch_id|
      $game_switches[switch_id] = buffer.read_boolean
    end
  end
  
end
