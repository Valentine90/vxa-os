#==============================================================================
# ** Send_Data
#------------------------------------------------------------------------------
#  Este script envia as mensagens para o servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Send_Data
  
  def send_login(user, pass)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LOGIN)
    buffer.write_string(user)
    buffer.write_string(VXAOS::md5(pass))
    buffer.write_short(Configs::GAME_VERSION)
    @socket.send(buffer.to_s)
  end
  
  def send_create_account(user, pass, email)
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_ACCOUNT)
    buffer.write_string(user)
    buffer.write_string(VXAOS::md5(pass))
    buffer.write_string(email)
    buffer.write_short(Configs::GAME_VERSION)
    @socket.send(buffer.to_s)
  end
  
  def send_create_actor(actor_id, name, character_index, class_id, sex, params)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_ACTOR)
    buffer.write_byte(actor_id)
    buffer.write_string(name)
    buffer.write_byte(character_index)
    buffer.write_short(class_id)
    buffer.write_byte(sex)
    params.each { |param| buffer.write_byte(param) }
    @socket.send(buffer.to_s)
  end
  
  def send_remove_actor(actor_id, pass)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_ACTOR)
    buffer.write_byte(actor_id)
    buffer.write_string(VXAOS::md5(pass))
    @socket.send(buffer.to_s)
  end
  
  def send_use_actor(actor_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_ACTOR)
    buffer.write_byte(actor_id)
    @socket.send(buffer.to_s)
  end
  
  def send_player_movement(direction)
    # Se o jogador foi desconectado, mas ainda não saiu
    #da cena do mapa e tentou andar no momento imeditamente
    #posterior ao encerramento da conexão
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_MOVE)
    buffer.write_byte(direction)
    @socket.send(buffer.to_s)
  end
  
  def send_chat_message(message, talk_type, player_name = '')
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHAT_MSG)
    buffer.write_string(message)
    buffer.write_byte(talk_type)
    buffer.write_string(player_name)
    @socket.send(buffer.to_s)
  end
  
  def send_player_attack
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_ATTACK)
    @socket.send(buffer.to_s)
  end
  
  def send_use_item(item_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_ITEM)
    buffer.write_short(item_id)
    @socket.send(buffer.to_s)
  end
  
  def send_use_skill(skill_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_SKILL)
    buffer.write_short(skill_id)
    @socket.send(buffer.to_s)
  end
  
  def send_balloon(balloon_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BALLOON)
    buffer.write_byte(balloon_id)
    @socket.send(buffer.to_s)
  end
  
  def send_use_hotbar(id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::USE_HOTBAR)
    buffer.write_byte(id)
    @socket.send(buffer.to_s)
  end
  
  def send_add_drop(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADD_DROP)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_remove_drop(drop_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_DROP)
    buffer.write_byte(drop_id)
    @socket.send(buffer.to_s)
  end
  
  def send_add_param(param_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_PARAM)
    buffer.write_byte(param_id)
    @socket.send(buffer.to_s)
  end
  
  def send_player_equip(item_id, slot_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_EQUIP)
    buffer.write_byte(slot_id)
    buffer.write_short(item_id)
    @socket.send(buffer.to_s)
  end
  
  def send_player_hotbar(id, type, item_id)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::PLAYER_HOTBAR)
    buffer.write_byte(id)
    buffer.write_byte(type)
    buffer.write_short(item_id)
    @socket.send(buffer.to_s)
  end
  
  def send_target(target_id, type)
    # Se o alvo está sendo selecionado após
    #chamar a cena do login
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TARGET)
    buffer.write_byte(type)
    buffer.write_short(target_id)
    @socket.send(buffer.to_s)
  end
  
  def send_open_friend_window
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_FRIENDS)
    @socket.send(buffer.to_s)
  end
  
  def send_remove_friend(index)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_FRIEND)
    buffer.write_byte(index)
    @socket.send(buffer.to_s)
  end
  
  def send_create_guild(name, flag)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CREATE_GUILD)
    buffer.write_string(name)
    flag.each { |color_id| buffer.write_byte(color_id) }
    @socket.send(buffer.to_s)
  end
  
  def send_open_guild_window
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::OPEN_GUILD)
    @socket.send(buffer.to_s)
  end
  
  def send_guild_leader(name)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_LEADER)
    buffer.write_string(name)
    @socket.send(buffer.to_s)
  end
  
  def send_guild_notice(notice)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::GUILD_NOTICE)
    buffer.write_string(notice)
    @socket.send(buffer.to_s)
  end
  
  def send_remove_guild_member(name)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REMOVE_GUILD_MEMBER)
    buffer.write_string(name)
    @socket.send(buffer.to_s)
  end
  
  def send_leave_guild
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LEAVE_GUILD)
    @socket.send(buffer.to_s)
  end
  
  def send_leave_party
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LEAVE_PARTY)
    @socket.send(buffer.to_s)
  end
  
  def send_choice(index)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHOICE)
    # Envia um valor entre 0 a 99.999.999 (8 dígitos do
    #comando de evento Armazenar Número)
    buffer.write_int(index)
    @socket.send(buffer.to_s)
  end
  
  def send_bank_item(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BANK_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_bank_gold(amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BANK_GOLD)
    buffer.write_int(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_close_window
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CLOSE_WINDOW)
    @socket.send(buffer.to_s)
  end
  
  def send_buy_item(index, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::BUY_ITEM)
    buffer.write_byte(index)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_sell_item(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::SELL_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_choice_telepot(index)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::CHOICE_TELEPORT)
    buffer.write_byte(index)
    @socket.send(buffer.to_s)
  end
  
  def send_next_event_command
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::NEXT_COMMAND)
    @socket.send(buffer.to_s)
  end
  
  def send_request(type, player_id = -1)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::REQUEST)
    buffer.write_byte(type)
    buffer.write_short(player_id)
    @socket.send(buffer.to_s)
  end
  
  def send_accept_request
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ACCEPT_REQUEST)
    @socket.send(buffer.to_s)
  end
  
  def send_decline_request
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::DECLINE_REQUEST)
    @socket.send(buffer.to_s)
  end
  
  def send_trade_item(item_id, kind, amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRADE_ITEM)
    buffer.write_short(item_id)
    buffer.write_byte(kind)
    buffer.write_short(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_trade_gold(amount)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::TRADE_GOLD)
    buffer.write_int(amount)
    @socket.send(buffer.to_s)
  end
  
  def send_logout
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::LOGOUT)
    @socket.send(buffer.to_s)
  end
  
  def send_admin_command(command, str1, str2 = 0, str3 = 0, str4 = 0)
    return unless @socket
    buffer = Buffer_Writer.new
    buffer.write_byte(Enums::Packet::ADMIN_COMMAND)
    buffer.write_byte(command)
    buffer.write_string(str1)
    buffer.write_int(str2)
    buffer.write_int(str3)
    buffer.write_short(str4)
    @socket.send(buffer.to_s)
  end
  
end
