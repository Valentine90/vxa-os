#==============================================================================
# ** Game_Commands
#------------------------------------------------------------------------------
#  Este script lida com os comandos do painel de administração.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Commands

  def admin_commands(client, command, str, int1, int2, int3)
    case command
    when Enums::Command::KICK
      kick_player(client, str)
    when Enums::Command::TELEPORT
      teleport_player(client, str, int1, int2, int3)
    when Enums::Command::GO
      go_to_player(client, str)
    when Enums::Command::PULL
      pull_player(client, str)
    when Enums::Command::ITEM
      give_item(client, $data_items[int1], str, int2)
    when Enums::Command::WEAPON
      give_item(client, $data_weapons[int1], str, int2)
    when Enums::Command::ARMOR
      give_item(client, $data_armors[int1], str, int2)
    when Enums::Command::GOLD
      give_gold(client, str, int2)
    when Enums::Command::BAN_IP, Enums::Command::BAN_ACC
      ban(client, command, str, int1)
    when Enums::Command::UNBAN
      Database.unban(client, str)
    when Enums::Command::SWITCH
      change_global_switch(str.to_i, int1 == 1)
    when Enums::Command::MOTD
      change_motd(client, str)
    when Enums::Command::MUTE
      mute_player(client, str)
    when Enums::Command::MSG
      admin_message(client, str)
    end
  end

  def monitor_commands(client, command, name)
    case command
    when Enums::Command::GO
      go_to_player(client, name)
    when Enums::Command::PULL
      pull_player(client, name)
    when Enums::Command::MUTE
      mute_player(client, name)
    end
  end

  def kick_player(client, name)
    player = find_player(name)
    if !player || player.admin?
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end
    global_chat_message("#{player.name} #{Kicked}")
    send_admin_command(player, Enums::Command::KICK)
    player.close_connection_after_writing
    @log.add(client.group, :blue, "#{client.user} expulsou #{player.name}.")
  end

  def teleport_player(player, name, map_id, x, y)
    @clients.each do |client|
      next unless client
      if name == 'all' && client.in_game?
        client.transfer(map_id, x, y, client.direction)
        alert_message(client, Enums::Alert::TELEPORTED)
      elsif client.name.casecmp(name).zero?
        client.transfer(map_id, x, y, client.direction)
        alert_message(client, Enums::Alert::TELEPORTED)
        player_chat_message(player, "#{sprintf(Teleported, client.name, x, y)} #{map_id}.", Configs::SUCCESS_COLOR) if client != player
        break
      end
    end
    @log.add(player.group, :blue, "#{player.user} teletransportou #{name} para as coordenadas #{x} e #{y} do mapa #{map_id}.")
  end

  def go_to_player(client, name)
    player = find_player(name)
    unless player
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end
    client.transfer(player.map_id, player.x, player.y, client.direction)
    @log.add(client.group, :blue, "#{client.user} foi até #{name}, nas coordenadas #{client.x} e #{client.y} do mapa #{client.map_id}.")
  end

  def pull_player(player, name)
    @clients.each do |client|
      next unless client
      if name == 'all' && client.in_game? && client != player
        client.transfer(player.map_id, player.x, player.y, client.direction)
        alert_message(client, Enums::Alert::PULLED)
      elsif client.name.casecmp(name).zero?
        client.transfer(player.map_id, player.x, player.y, client.direction)
        alert_message(client, Enums::Alert::PULLED)
        break
      end
    end
    @log.add(player.group, :blue, "#{player.user} puxou #{name} para as coordenadas #{player.x} e #{player.y} do mapa #{player.map_id}.")
  end

  def give_item(player, item, name, amount)
    @clients.each do |client|
      next unless client
      if name == 'all' && client.in_game?
        client.gain_item(item, amount, false, true) unless client.full_inventory?(item) && amount > 0
      elsif client.name.casecmp(name).zero?
        if client.full_inventory?(item) && amount > 0
          player_chat_message(player, sprintf(FullInventory, client.name), Configs::ERROR_COLOR)
          @log.add(player.group, :blue, "#{player.user} tentou dar #{amount} #{item.name} para #{name}, mas o inventário deste estava cheio.")
          return
        else
          client.gain_item(item, amount, false, true)
          player_chat_message(player, "#{sprintf(GaveItem, amount, item.name)} #{client.name}.", Configs::SUCCESS_COLOR)
          break
        end
      end
    end
    @log.add(player.group, :blue, "#{player.user} deu #{amount} #{item.name} para #{name}.")
  end

  def give_gold(player, name, amount)
    @clients.each do |client|
      next unless client
      if name == 'all' && client.in_game?
        client.gain_gold(amount, false, true)
      elsif client.name.casecmp(name).zero?
        client.gain_gold(amount, false, true)
        player_chat_message(player, "#{sprintf(GaveGold, amount)} #{client.name}.", Configs::SUCCESS_COLOR)
        break
      end
    end
    @log.add(player.group, :blue, "#{player.user} deu #{amount} moeda(s) de ouro para #{name}.")
  end

  def ban(client, type, name, days)
    player = find_player(name)
    time = days * 86400 + Time.now.to_i
    if !player && type == Enums::Command::BAN_ACC && Database.player_exist?(name)
      # Carrega o ID da conta junto com o nome do jogador que será banido. O nome será
      #mostrado no bate-papo global grafado com letras maiúsculas e minúsculas
      account_id_db, name = Database.load_some_player_data(name)
      @ban_list[account_id_db] = time
      global_chat_message("#{name} #{Banned}")
      @log.add(client.group, :blue, "#{client.user} baniu #{name} por #{days} dia(s).")
      return
    elsif !player || player.admin?
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    elsif type == Enums::Command::BAN_ACC
      @ban_list[player.account_id_db] = time
      send_admin_command(player, type)
      player.close_connection_after_writing
    else
      @ban_list[player.ip] = time
      kick_banned_ip(player.ip)
    end
    global_chat_message("#{player.name} #{Banned}")
    @log.add(client.group, :blue, "#{client.user} baniu #{player.name} por #{days} dia(s).")
  end

  def kick_banned_ip(banned_ip)
    @clients.each do |client|
      next if client&.ip != banned_ip || client.admin?
      send_admin_command(client, Enums::Command::BAN_IP)
      client.close_connection_after_writing
    end
  end

  def change_global_switch(switch_id, value)
    return unless switch_id > Configs::MAX_PLAYER_SWITCHES
    @switches[switch_id] = value
  end

  def change_motd(client, motd)
    @motd = motd
    global_chat_message(motd)
    @log.add(client.group, :blue, "#{client.user} mudou a mensagem do dia para: #{motd}.")
  end

  def mute_player(client, name)
    player = find_player(name)
    if !player || player.admin?
      alert_message(client, Enums::Alert::INVALID_NAME)
      return
    end
    player.muted_time = Time.now + 30
    alert_message(player, Enums::Alert::MUTED)
    @log.add(client.group, :blue, "#{client.user} silenciou #{name} por 30 segundos.")
  end

  def admin_message(player, message)
    @clients.each { |client| send_admin_command(client, Enums::Command::MSG, message) if client&.in_game? }
    global_chat_message(message, Configs::ADM_MSG_COLOR)
    @log.add(player.group, :blue, "#{player.user} enviou a mensagem: #{message}.")
  end

end
