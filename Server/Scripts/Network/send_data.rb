#==============================================================================
# ** Send_Data
#------------------------------------------------------------------------------
#  Este script envia as mensagens para o cliente.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Send_Data

	def send_data_to_map(map_id, data)
		@clients.each { |client| client.send_data(data) if client&.in_game? && client.map_id == map_id }
	end

	def send_data_to_all(data)
		@clients.each { |client| client.send_data(data) if client&.in_game? }
	end

	def send_data_to_party(party_id, data)
		@parties[party_id].each { |member| member.send_data(data) }
	end

	def send_data_to_guild(guild_name, data)
		@clients.each { |client| client.send_data(data) if client&.in_game? && client.guild_name == guild_name }
	end

	def send_login(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::LOGIN)
		buffer.write_byte(client.group)
		buffer.write_time(client.vip_time)
		buffer.write_byte(client.actors.size)
		client.actors.each do |actor_id, actor|
			buffer.write_byte(actor_id)
			buffer.write_string(actor.name)
			buffer.write_string(actor.character_name)
			buffer.write_byte(actor.character_index)
			buffer.write_string(actor.face_name)
			buffer.write_byte(actor.face_index)
			buffer.write_byte(actor.sex)
			actor.equips.each { |equip| buffer.write_short(equip) }
		end
		client.send_data(buffer.to_s)
	end

	def send_failed_login(client, type)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::FAIL_LOGIN)
		buffer.write_byte(type)
		client.send_data(buffer.to_s)
	end

	def send_create_account(client, type)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CREATE_ACCOUNT)
		buffer.write_byte(type)
		client.send_data(buffer.to_s)
	end

	def send_create_actor(client, actor_id, actor)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ACTOR)
		buffer.write_byte(actor_id)
		buffer.write_string(actor.name)
		buffer.write_string(actor.character_name)
		buffer.write_byte(actor.character_index)
		buffer.write_string(actor.face_name)
		buffer.write_byte(actor.face_index)
		buffer.write_byte(actor.sex)
		actor.equips.each { |equip| buffer.write_short(equip) }
		client.send_data(buffer.to_s)
	end

	def send_failed_create_actor(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::FAIL_CREATE_ACTOR)
		client.send_data(buffer.to_s)
	end

	def send_remove_actor(client, actor_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::REMOVE_ACTOR)
		buffer.write_byte(actor_id)
		client.send_data(buffer.to_s)
	end

	def send_use_actor(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::USE_ACTOR)
		buffer.write_short(client.id)
		buffer.write_string(client.name)
		buffer.write_string(client.character_name)
		buffer.write_byte(client.character_index)
		buffer.write_string(client.face_name)
		buffer.write_byte(client.face_index)
		buffer.write_short(client.class_id)
		buffer.write_byte(client.sex)
		# Envia os equipamentos, que podem aumentar o HP e/ou MP máximos, antes de
		#o cliente calcular o limite máximo dos parâmetros ao recebê-los
		client.equips.each { |equip| buffer.write_short(equip) }
		client.param_base.each { |param| buffer.write_int(param) }
		buffer.write_int(client.hp)
		buffer.write_int(client.mp)
		buffer.write_int(client.exp)
		buffer.write_short(client.points)
		buffer.write_string(client.guild_name)
		buffer.write_int(client.gold)
		buffer.write_byte(client.actor.items.size)
		client.actor.items.each do |item_id, amount|
			buffer.write_short(item_id)
			buffer.write_short(amount)
		end
		buffer.write_byte(client.actor.weapons.size)
		client.actor.weapons.each do |weapon_id, amount|
			buffer.write_short(weapon_id)
			buffer.write_short(amount)
		end
		buffer.write_byte(client.actor.armors.size)
		client.actor.armors.each do |armor_id, amount|
			buffer.write_short(armor_id)
			buffer.write_short(amount)
		end
		buffer.write_byte(client.skills.size)
		client.skills.each { |skill| buffer.write_short(skill) }
		buffer.write_byte(client.friends.size)
		client.friends.each { |friend| buffer.write_string(friend) }
		buffer.write_byte(client.quests.size)
		client.quests.each do |quest_id, quest|
			buffer.write_byte(quest_id)
			buffer.write_byte(quest.state)
		end
		client.hotbar.each do |hotbar|
			buffer.write_byte(hotbar.type)
			buffer.write_short(hotbar.item_id)
		end
		client.switches.data.each { |switch| buffer.write_boolean(switch) }
		client.variables.data.each { |variable| buffer.write_short(variable) }
		buffer.write_short(client.self_switches.data.size)
		client.self_switches.data.each do |key, value|
			buffer.write_short(key[0])
			buffer.write_short(key[1])
			buffer.write_string(key[2])
			buffer.write_boolean(value)
		end
		buffer.write_short(client.map_id)
		buffer.write_short(client.x)
		buffer.write_short(client.y)
		buffer.write_byte(client.direction)
		client.send_data(buffer.to_s)
	end

	def send_motd(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::MOTD)
		buffer.write_string(@motd)
		client.send_data(buffer.to_s)
	end

	def send_player_data(client, map_id)
		return if @maps[map_id].zero_players?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_DATA)
		buffer.write_short(client.id)
		buffer.write_byte(client.group)
		buffer.write_string(client.name)
		buffer.write_string(client.character_name)
		buffer.write_byte(client.character_index)
		buffer.write_byte(client.sex)
		client.equips.each { |equip| buffer.write_short(equip) }
		buffer.write_int(client.param_base[Enums::Param::MAXHP])
		buffer.write_int(client.hp)
		# Envia o nível do jogador que será calculado a partir da experiência
		buffer.write_int(client.exp)
		buffer.write_string(client.guild_name)
		buffer.write_short(client.x)
		buffer.write_short(client.y)
		buffer.write_byte(client.direction)
		send_data_to_map(map_id, buffer.to_s)
	end
	
	def send_map_players(player)
		return if @maps[player.map_id].zero_players?
		@clients.each do |client|
			next if !client&.in_game? || client.map_id != player.map_id || client == player
			buffer = Buffer_Writer.new
			buffer.write_byte(Enums::Packet::PLAYER_DATA)
			buffer.write_short(client.id)
			buffer.write_byte(client.group)
			buffer.write_string(client.name)
			buffer.write_string(client.character_name)
			buffer.write_byte(client.character_index)
			buffer.write_byte(client.sex)
			client.equips.each { |equip| buffer.write_short(equip) }
			buffer.write_int(client.param_base[Enums::Param::MAXHP])
			buffer.write_int(client.hp)
			buffer.write_int(client.exp)
			buffer.write_string(client.guild_name)
			buffer.write_short(client.x)
			buffer.write_short(client.y)
			buffer.write_byte(client.direction)
			player.send_data(buffer.to_s)
		end
	end

	def send_remove_player(client_id, map_id)
		return if @maps[map_id].zero_players?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::REMOVE_PLAYER)
		buffer.write_short(client_id)
		send_data_to_map(map_id, buffer.to_s)
	end
	
	def send_player_movement(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_MOVE)
		buffer.write_short(client.id)
		buffer.write_short(client.x)
		buffer.write_short(client.y)
		buffer.write_byte(client.direction)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def player_chat_message(client, message, color_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CHAT_MSG)
		buffer.write_byte(color_id)
		buffer.write_string(message)
		client.send_data(buffer.to_s)
	end

	def map_chat_message(map_id, message, player_id, color_id = Enums::Chat::MAP)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::MAP_MSG)
		buffer.write_short(player_id)
		buffer.write_byte(color_id)
		buffer.write_string(message)
		send_data_to_map(map_id, buffer.to_s)
	end

	def global_chat_message(message, color_id = Enums::Chat::GLOBAL)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CHAT_MSG)
		buffer.write_byte(color_id)
		buffer.write_string(message)
		send_data_to_all(buffer.to_s)
	end

	def party_chat_message(client, message)
		return unless client.in_party?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CHAT_MSG)
		buffer.write_byte(Enums::Chat::PARTY)
		buffer.write_string(message)
		send_data_to_party(client.party_id, buffer.to_s)
	end

	def guild_chat_message(client, message, color_id = Enums::Chat::GUILD)
		return unless client.in_guild?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CHAT_MSG)
		buffer.write_byte(color_id)
		buffer.write_string(message)
		send_data_to_guild(client.guild_name, buffer.to_s)
	end

	def private_chat_message(client, message, name)
		return if client.name.casecmp(name).zero?
		player = find_player(name)
		unless player
			alert_message(client, Enums::Alert::INVALID_NAME)
			return
		end
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CHAT_MSG)
		buffer.write_byte(Enums::Chat::PRIVATE)
		buffer.write_string(message)
		player.send_data(buffer.to_s)
		client.send_data(buffer.to_s)
	end

	def alert_message(client, type)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ALERT_MSG)
		buffer.write_byte(type)
		client.send_data(buffer.to_s)
	end
	
	def send_whos_online(client, message)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CHAT_MSG)
		buffer.write_byte(Enums::Chat::GLOBAL)
		buffer.write_string(message)
		client.send_data(buffer.to_s)
	end

	def send_attack_player(map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, player_id, animation_id, not_show_missed)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ATTACK_PLAYER)
		buffer.write_short(attacker_id)
		buffer.write_byte(attacker_type)
		buffer.write_byte(ani_index)
		buffer.write_short(player_id)
		buffer.write_int(hp_damage)
		buffer.write_int(mp_damage)
		buffer.write_boolean(critical)
		buffer.write_short(animation_id)
		buffer.write_boolean(not_show_missed)
		send_data_to_map(map_id, buffer.to_s)
	end

	def send_attack_enemy(map_id, hp_damage, mp_damage, critical, attacker_id, attacker_type, ani_index, event_id, animation_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ATTACK_ENEMY)
		buffer.write_short(attacker_id)
		buffer.write_byte(attacker_type)
		buffer.write_byte(ani_index)
		buffer.write_short(event_id)
		buffer.write_int(hp_damage)
		buffer.write_int(mp_damage)
		buffer.write_boolean(critical)
		buffer.write_short(animation_id)
		send_data_to_map(map_id, buffer.to_s)
	end

	def send_animation(character, animation_id, attacker_id, attacker_type, ani_index, character_type)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ANIMATION)
		buffer.write_short(attacker_id)
		buffer.write_byte(attacker_type)
		buffer.write_byte(ani_index)
		buffer.write_short(character.id)
		buffer.write_byte(character_type)
		buffer.write_short(animation_id)
		send_data_to_map(character.map_id, buffer.to_s)
	end

	def send_balloon(character, character_type, balloon_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::BALLOON)
		buffer.write_short(character.id)
		buffer.write_byte(character_type)
		buffer.write_byte(balloon_id)
		send_data_to_map(character.map_id, buffer.to_s)
	end

	def send_enemy_balloon(client, event_id, balloon_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::BALLOON)
		buffer.write_short(event_id)
		buffer.write_byte(Enums::Target::ENEMY)
		buffer.write_byte(balloon_id)
		client.send_data(buffer.to_s)
	end

	def send_enemy_revive(event)
		return if @maps[event.map_id].zero_players?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ENEMY_REVIVE)
		buffer.write_short(event.id)
		send_data_to_map(event.map_id, buffer.to_s)
	end

	def send_map_events(client)
		@maps[client.map_id].events.each do |event_id, event|
			buffer = Buffer_Writer.new
			buffer.write_byte(Enums::Packet::EVENT_DATA)
			buffer.write_short(event_id)
			buffer.write_short(event.x)
			buffer.write_short(event.y)
			buffer.write_byte(event.direction)
			buffer.write_int(event.hp)
			client.send_data(buffer.to_s)
		end
	end

	def send_event_movement(event)
		return if @maps[event.map_id].zero_players?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::EVENT_MOVE)
		buffer.write_short(event.id)
		buffer.write_short(event.x)
		buffer.write_short(event.y)
		buffer.write_byte(event.direction)
		send_data_to_map(event.map_id, buffer.to_s)
	end

	def send_map_drops(client)
		@maps[client.map_id].drops.each do |drop|
			buffer = Buffer_Writer.new
			buffer.write_byte(Enums::Packet::ADD_DROP)
			buffer.write_short(drop.item_id)
			buffer.write_byte(drop.kind)
			buffer.write_short(drop.amount)
			buffer.write_short(drop.x)
			buffer.write_short(drop.y)
			client.send_data(buffer.to_s)
		end
	end

	def send_add_drop(map_id, item_id, kind, amount, x, y)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ADD_DROP)
		buffer.write_short(item_id)
		buffer.write_byte(kind)
		buffer.write_short(amount)
		buffer.write_short(x)
		buffer.write_short(y)
		send_data_to_map(map_id, buffer.to_s)
	end

	def send_remove_drop(map_id, drop_id)
		return if @maps[map_id].zero_players?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::REMOVE_DROP)
		buffer.write_byte(drop_id)
		send_data_to_map(map_id, buffer.to_s)
	end

	def send_add_projectile(client, finish_x, finish_y, target, projectile_type, projectile_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ADD_PROJECTILE)
		buffer.write_short(client.x)
		buffer.write_short(client.y)
		buffer.write_short(finish_x)
		buffer.write_short(finish_y)
		buffer.write_short(target.x)
		buffer.write_short(target.y)
		buffer.write_byte(projectile_type)
		buffer.write_byte(projectile_id)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_vitals(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_VITALS)
		buffer.write_short(client.id)
		buffer.write_int(client.hp)
		buffer.write_int(client.mp)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_exp(client, exp)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_EXP)
		buffer.write_short(client.id)
		buffer.write_int(exp)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_state(client, state_id, add_state = true)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_STATE)
		buffer.write_short(state_id)
		buffer.write_boolean(add_state)
		client.send_data(buffer.to_s)
	end

	def send_player_buff(client, param_id, buff_level)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_BUFF)
		buffer.write_byte(param_id)
		# Escreve short, e não byte, pois buff_level pode ser 1, -1 ou 0
		buffer.write_short(buff_level)
		client.send_data(buffer.to_s)
	end

	def send_player_switch(client, switch_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::SWITCH)
		buffer.write_short(switch_id)
		buffer.write_boolean(client.switches[switch_id])
		client.send_data(buffer.to_s)
	end

	def send_player_variable(client, variable_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::VARIABLE)
		buffer.write_short(variable_id)
		buffer.write_short(client.variables[variable_id])
		client.send_data(buffer.to_s)
	end

	def send_player_self_switch(client, key)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::SELF_SWITCH)
		buffer.write_short(key[0])
		buffer.write_short(key[1])
		buffer.write_string(key[2])
		buffer.write_boolean(client.self_switches[key])
		client.send_data(buffer.to_s)
	end

	def send_player_item(client, item_id, kind, amount, drop_sound, popup)
    buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_ITEM)
		buffer.write_short(item_id)
		buffer.write_byte(kind)
		buffer.write_short(amount)
		buffer.write_boolean(drop_sound)
		buffer.write_boolean(popup)
		client.send_data(buffer.to_s)
	end

	def send_player_gold(client, amount, shop_sound, popup)
    buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_GOLD)
		buffer.write_int(amount)
		buffer.write_boolean(shop_sound)
		buffer.write_boolean(popup)
		client.send_data(buffer.to_s)
	end

	def send_player_param(client, param_id, value)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_PARAM)
		buffer.write_short(client.id)
		buffer.write_byte(param_id)
		buffer.write_short(value)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_equip(client, slot_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_EQUIP)
		buffer.write_short(client.id)
		buffer.write_byte(slot_id)
		buffer.write_short(client.equips[slot_id])
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_skill(client, skill_id, learn = true)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_SKILL)
		buffer.write_short(skill_id)
		buffer.write_boolean(learn)
		client.send_data(buffer.to_s)
	end

	def send_player_class(client, class_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_CLASS)
		buffer.write_short(class_id)
		client.send_data(buffer.to_s)
	end

	def send_player_sex(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_SEX)
		buffer.write_short(client.id)
		buffer.write_byte(client.sex)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_graphic(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_GRAPHIC)
		buffer.write_short(client.id)
		buffer.write_string(client.character_name)
		buffer.write_byte(client.character_index)
		buffer.write_string(client.face_name)
		buffer.write_byte(client.face_index)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_player_points(client, points)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_POINTS)
		buffer.write_short(points)
		client.send_data(buffer.to_s)
	end

	def send_player_hotbar(client, id)
    buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::PLAYER_HOTBAR)
		buffer.write_byte(id)
    buffer.write_byte(client.hotbar[id].type)
    buffer.write_short(client.hotbar[id].item_id)
    client.send_data(buffer.to_s)
	end

	def send_target(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::TARGET)
		buffer.write_byte(client.target.type)
		buffer.write_short(client.target.id)
		client.send_data(buffer.to_s)
	end

	def send_transfer_player(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::TRANSFER)
		buffer.write_short(client.map_id)
		buffer.write_short(client.x)
		buffer.write_short(client.y)
		buffer.write_byte(client.direction)
		client.send_data(buffer.to_s)
	end

	def send_open_friends(client, online_friends)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::OPEN_FRIENDS)
		buffer.write_byte(online_friends.size)
		online_friends.each { |name| buffer.write_string(name) }
		client.send_data(buffer.to_s)
	end

	def send_add_friend(client, friend_name)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ADD_FRIEND)
		buffer.write_string(friend_name)
		client.send_data(buffer.to_s)
	end
	
	def send_remove_friend(client, index)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::REMOVE_FRIEND)
		buffer.write_byte(index)
		client.send_data(buffer.to_s)
	end

	def send_open_create_guild(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::OPEN_CREATE_GUILD)
		client.send_data(buffer.to_s)
	end

	def send_open_guild(client, online_members_size)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::OPEN_GUILD)
		buffer.write_string(@guilds[client.guild_name].leader)
		buffer.write_string(@guilds[client.guild_name].notice)
		@guilds[client.guild_name].flag.each { |color_id| buffer.write_byte(color_id) }
		buffer.write_byte(@guilds[client.guild_name].members.size)
		buffer.write_byte(online_members_size)
		@guilds[client.guild_name].members.each { |name| buffer.write_string(name) }
		client.send_data(buffer.to_s)
	end

	def send_guild_leader(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::GUILD_LEADER)
		buffer.write_string(@guilds[client.guild_name].leader)
		client.send_data(buffer.to_s)
	end

	def send_guild_notice(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::GUILD_NOTICE)
		buffer.write_string(@guilds[client.guild_name].notice)
		client.send_data(buffer.to_s)
	end

	def send_guild_name(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::GUILD_NAME)
		buffer.write_string(client.guild_name)
		buffer.write_short(client.id)
		send_data_to_map(client.map_id, buffer.to_s)
	end

	def send_remove_guild_member(client, name)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::REMOVE_GUILD_MEMBER)
		buffer.write_string(name)
		client.send_data(buffer.to_s)
	end

	def send_join_party(client, player)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::JOIN_PARTY)
		buffer.write_short(player.id)
		buffer.write_string(player.name)
		buffer.write_string(player.character_name)
		buffer.write_byte(player.character_index)
		buffer.write_byte(player.sex)
		player.equips.each { |equip| buffer.write_short(equip) }
		buffer.write_int(player.param_base[Enums::Param::MAXHP])
		buffer.write_int(player.hp)
		buffer.write_int(player.exp)
		client.send_data(buffer.to_s)
	end

	def send_leave_party(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::LEAVE_PARTY)
		buffer.write_short(client.id)
		send_data_to_party(client.party_id, buffer.to_s)
	end

	def send_dissolve_party(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::DISSOLVE_PARTY)
		client.send_data(buffer.to_s)
	end

	def send_open_bank(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::OPEN_BANK)
		buffer.write_int(client.bank_gold)
		buffer.write_byte(client.bank_items.size)
		client.bank_items.each do |item_id, amount|
			buffer.write_short(item_id)
			buffer.write_short(amount)
		end
		buffer.write_byte(client.bank_weapons.size)
		client.bank_weapons.each do |weapon_id, amount|
			buffer.write_short(weapon_id)
			buffer.write_short(amount)
		end
		buffer.write_byte(client.bank_armors.size)
		client.bank_armors.each do |armor_id, amount|
			buffer.write_short(armor_id)
			buffer.write_short(amount)
		end
		client.send_data(buffer.to_s)
	end

	def send_bank_item(client, item_id, kind, amount)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::BANK_ITEM)
		buffer.write_short(item_id)
		buffer.write_byte(kind)
		buffer.write_short(amount)
		client.send_data(buffer.to_s)
	end

	def send_bank_gold(client, amount)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::BANK_GOLD)
		buffer.write_int(amount)
		client.send_data(buffer.to_s)
	end

	def send_close_window(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::CLOSE_WINDOW)
		client.send_data(buffer.to_s)
	end

	def send_open_shop(client, event_id, index)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::OPEN_SHOP)
		buffer.write_short(event_id)
		buffer.write_short(index)
		client.send_data(buffer.to_s)
	end

	def send_open_teleport(client, teleport_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::OPEN_TELEPORT)
		buffer.write_byte(teleport_id)
		client.send_data(buffer.to_s)
	end

	def send_event_command(client, event_id, initial_index, final_index)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::EVENT_COMMAND)
		buffer.write_short(event_id)
		buffer.write_short(initial_index)
		buffer.write_short(final_index)
		client.send_data(buffer.to_s)
	end

	def send_parallel_process_command(event, initial_index, final_index)
		return if @maps[event.map_id].zero_players?
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::EVENT_COMMAND)
		buffer.write_short(event.id)
		buffer.write_short(initial_index)
		buffer.write_short(final_index)
		send_data_to_map(event.map_id, buffer.to_s)
	end

	def send_request(client, type, player)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::REQUEST)
		buffer.write_byte(type)
		buffer.write_string(player.name)
		buffer.write_string(player.guild_name)
		client.send_data(buffer.to_s)
	end

	def send_accept_request(client, type)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ACCEPT_REQUEST)
		buffer.write_byte(type)
		client.send_data(buffer.to_s)
	end

	def send_trade_item(client, player_id, item_id, kind, amount)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::TRADE_ITEM)
		buffer.write_short(player_id)
		buffer.write_short(item_id)
		buffer.write_byte(kind)
		buffer.write_short(amount)
		client.send_data(buffer.to_s)
	end

	def send_trade_gold(client, player_id, amount)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::TRADE_GOLD)
		buffer.write_short(player_id)
		buffer.write_int(amount)
		client.send_data(buffer.to_s)
	end

	def send_add_quest(client, quest_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ADD_QUEST)
		buffer.write_byte(quest_id)
		client.send_data(buffer.to_s)
	end

	def send_finish_quest(client, quest_id)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::FINISH_QUEST)
		buffer.write_byte(quest_id)
		client.send_data(buffer.to_s)
	end

	def send_vip_days(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::VIP_DAYS)
		buffer.write_time(client.vip_time + client.added_vip_time)
		client.send_data(buffer.to_s)
	end

	def send_logout(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::LOGOUT)
		buffer.write_byte(client.actor_id)
		buffer.write_string(client.name)
		buffer.write_string(client.character_name)
		buffer.write_byte(client.character_index)
		buffer.write_string(client.face_name)
		buffer.write_byte(client.face_index)
		buffer.write_byte(client.sex)
		client.equips.each { |equip| buffer.write_short(equip) }
		client.send_data(buffer.to_s)
	end
	
	def send_admin_command(client, command, alert_msg = '')
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::ADMIN_COMMAND)
		buffer.write_byte(command)
		buffer.write_string(alert_msg)
		client.send_data(buffer.to_s)
	end

	def send_global_switch(switch_id, value)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::SWITCH)
		buffer.write_short(switch_id)
		buffer.write_boolean(value)
		send_data_to_all(buffer.to_s)
	end

	def send_global_switches(client)
		buffer = Buffer_Writer.new
		buffer.write_byte(Enums::Packet::NET_SWITCHES)
		100.times { |switch_id| buffer.write_boolean(@switches[switch_id + Configs::MAX_PLAYER_SWITCHES + 1]) }
		client.send_data(buffer.to_s)
	end
	
end
