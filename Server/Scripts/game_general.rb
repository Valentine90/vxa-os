#==============================================================================
# ** Game_General
#------------------------------------------------------------------------------
#  Este script lida com funções especiais do servidor. Ele é utilizado
# especialmente para executar comandos do painel de administração
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_General
	
	def full_clients?
		@client_high_id == MAX_CONNECTIONS && @client_ids_available.empty?
	end

	def find_player(name)
		@clients.find { |client| client && client.name.casecmp(name).zero? }
	end
	
	def member_in_guild?(guild, name)
		guild.members.any? { |member| member == name }
	end

	def find_guild_member(guild, name)
		guild.members.find { |member| member.casecmp(name).zero? }
	end

	def adjust_name(str)
		str.split.each { |s| s.capitalize! }.join(' ')
	end

  def invalid_email?(email)
    email !~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	end

  def invalid_user?(user)
    user =~ /[\/\\"*<>|]/
  end
	
  def invalid_name?(name)
    name =~ /[^A-Za-z0-9 ]/
	end
	
	def multi_accounts?(user, ip)
		result = @clients.find { |client| client && client.user.casecmp(user).zero? }
		if result && result.ip == ip
			result.leave_game if result.in_game?
			result.close_connection
			result = false
		end
		result
	end

	def login_hacking_attempt?(client)
		return !client.connected? || client.logged?
	end

	def create_account_hacking_attempt?(client, user, pass, email)
		return true unless client.connected?
		return true if client.logged?
		return true if user.size < Configs::MIN_CHARACTERS || user.size > Configs::MAX_CHARACTERS
		# Se a senha não tem a quantidade mínima de caracteres, independentemente da
		#quantidade máxima de caracteres
		return true if pass.size < Configs::MIN_CHARACTERS
		return true if invalid_user?(user)
		return true if invalid_email?(email)
		return true if email.size > 40
		return false
	end

  def illegal_name?(name)
    Configs::FORBIDDEN_NAMES.any? { |word| name =~ /#{word}/i }
	end
	
	def requested_unavailable?(client, requested)
		return true if client.id == requested.id
		return true unless requested&.in_game?
		return true unless requested.map_id == client.map_id
		return true unless client.in_range?(requested, 10)
		return false
	end

	def pick_up_drop?(drop, client)
		return true if drop.name.empty?
		return true if drop.name == client.name
		return true if drop.party_id > -1 && drop.party_id == client.party_id
		return true if Time.now >= drop.pick_up_time
		return false
	end
	
	def banned?(key)
		key.downcase!
		result = @ban_list.has_key?(key)
		if result && Time.now.to_i > @ban_list[key]
			@ban_list.delete(key)
			result = false
		end
		result
	end

	def ip_blocked?(ip)
  	result = @blocked_ips.has_key?(ip) && @blocked_ips[ip].attempts == MAX_ATTEMPS
  	if result && Time.now > @blocked_ips[ip].time
    	@blocked_ips.delete(ip)
    	result = false
  	end
  	result
	end
	
	def add_attempt(client)
		@blocked_ips[client.ip] = IP_Blocked.new(0) if !@blocked_ips.has_key?(client.ip) || Time.now > @blocked_ips[client.ip].time
		@blocked_ips[client.ip].attempts += 1
		if @blocked_ips[client.ip].attempts == MAX_ATTEMPS
			@blocked_ips[client.ip].time = Time.now + MAX_IP_TIME_BLOCKED
			send_failed_login(client, Enums::Login::IP_BLOCKED)
			# Desconecta depois que enviar a mensagem acima se o usuário
			#estiver errando a senha ao excluir um personagem
			client.close_connection_after_writing if client.logged?
		else
			@blocked_ips[client.ip].time = Time.now + 60
		end
	end

	def chat_filter(message)
		CHAT_FILTER.each { |word| message.sub!(/#{word}/i, '*' * word.size) }
		message
	end
	
	def admin_commands(client, command, str1, str2, str3, str4)
		case command
		when Enums::Command::KICK
			kick_player(client, str1)
		when Enums::Command::TELEPORT
			teleport_player(client, str1, str2, str3, str4)
		when Enums::Command::GO
			go_to_player(client, str1)
		when Enums::Command::PULL
			pull_player(client, str1)
		when Enums::Command::ITEM
			give_item(client, $data_items, str1, str2, str3)
		when Enums::Command::WEAPON
			give_item(client, $data_weapons, str1, str2, str3)
		when Enums::Command::ARMOR
			give_item(client, $data_armors, str1, str2, str3)
		when Enums::Command::GOLD
			give_gold(client, str1, str3.to_i)
		when Enums::Command::BAN_IP, Enums::Command::BAN_ACC
			ban(client, command, str1, str2)
		when Enums::Command::UNBAN
			unban(client, str1)
		when Enums::Command::SWITCH
			change_global_switch(str1.to_i, str2 == 1)
		when Enums::Command::MOTD
			change_motd(client, str1)
		when Enums::Command::MUTE
			mute_player(client, str1)
		when Enums::Command::MSG
			admin_message(client, str1)
		end
	end

	def monitor_commands(client, command, str1, str2, str3, str4)
		case command
		when Enums::Command::GO
			go_to_player(client, str1)
		when Enums::Command::PULL
			pull_player(client, str1)
		when Enums::Command::MUTE
			mute_player(client, str1)
		end
	end

	def kick_player(client, name)
		player = find_player(name)
		if !player || player.admin?
			alert_message(client, Enums::Alert::INVALID_NAME)
			return
		end
		global_message("#{player.name} #{Kicked}")
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
				player_message(player, "#{sprintf(Teleported, client.name, x, y)} #{map_id}.", Configs::SUCCESS_COLOR) if client != player
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
		@log.add(client.group, :blue, "#{client.user} foi até #{name}.")
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
		@log.add(player.group, :blue, "#{player.user} puxou #{name}.")
	end

	def give_item(player, items, name, item_id, amount)
		@clients.each do |client|
			next unless client
			if name == 'all' && client.in_game?
				client.gain_item(items[item_id], amount, false, true) unless client.full_inventory?(items[item_id]) && amount > 0
			elsif client.name.casecmp(name).zero?
				if client.full_inventory?(items[item_id]) && amount > 0
					player_message(player, sprintf(FullInventory, client.name), Configs::ERROR_COLOR)
					@log.add(player.group, :blue, "#{player.user} tentou dar #{amount} #{items[item_id].name} para #{name}, mas o inventário deste estava cheio.")
					return
				else
					client.gain_item(items[item_id], amount, false, true)
					player_message(player, "#{sprintf(GaveItem, amount, items[item_id].name)} #{client.name}.", Configs::SUCCESS_COLOR)
					break
				end
			end
		end
		@log.add(player.group, :blue, "#{player.user} deu #{amount} #{items[item_id].name} para #{name}.")
	end

	def give_gold(player, name, amount)
		@clients.each do |client|
			next unless client
			if name == 'all' && client.in_game?
				client.gain_gold(amount, false, true)
			elsif client.name.casecmp(name).zero?
				client.gain_gold(amount, false, true)
				player_message(player, "#{sprintf(GaveGold, amount)} #{client.name}.", Configs::SUCCESS_COLOR)
				break
			end
		end
		@log.add(player.group, :blue, "#{player.user} deu #{amount} moeda(s) de ouro para #{name}.")
	end

	def ban(client, type, name, days)
		player = find_player(name)
		time = days * 86400 + Time.now.to_i
		if !player && type == Enums::Command::BAN_ACC && Database.player_exist?(name)
			player = Database.load_player(name)
			@ban_list[player.user.downcase] = time
			global_message("#{player.name} #{Banned}")
			@log.add(client.group, :blue, "#{client.user} baniu #{player.name} por #{days} dia(s).")
			return
		elsif !player || player.admin?
			alert_message(client, Enums::Alert::INVALID_NAME)
			return
		end
		global_message("#{player.name} #{Banned}")
		if type == Enums::Command::BAN_ACC
			@ban_list[player.user.downcase] = time
			send_admin_command(player, type)
			player.close_connection_after_writing
		else
			@ban_list[player.ip] = time
			kick_banned_ip(player.ip)
		end
		@log.add(client.group, :blue, "#{client.user} baniu #{player.name} por #{days} dia(s).")
	end

	def kick_banned_ip(banned_ip)
		@clients.each do |client|
			next if client&.ip != banned_ip || client.admin?
			send_admin_command(client, Enums::Command::BAN_IP)
			client.close_connection_after_writing
		end
	end

	def unban(client, user)
		@ban_list.delete(user)
		@log.add(client.group, :blue, "#{client.user} desbaniu #{user}.")
	end

	def change_global_switch(switch_id, value)
		@switches[switch_id - Configs::MAX_PLAYER_SWITCHES] = value
		send_global_switch(switch_id, value)
		# Atualiza enemy_id dos eventos
		@maps.each_value(&:refresh)
	end

	def change_motd(client, motd)
		@motd = motd
		global_message(motd)
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
		global_message(message, 17)
		@log.add(player.group, :blue, "#{player.user} enviou a mensagem: #{message}.")
	end

	def whos_online(player)
		names = []
		@clients.each { |client| names << "#{client.name} [#{client.level}]" if client&.in_game? }
		if names.size > 1
			# Envia no máximo 50 nomes para evitar spawn
			send_whos_online(player, sprintf(Connected, names.size, names.take(50).join(', ')))
		else
			send_whos_online(player, NobodyConnected)
		end
	end
	
end
