#==============================================================================
# ** Game_General
#------------------------------------------------------------------------------
#  Este script lida com funções especiais do servidor. Ele é utilizado,
# inclusive, para executar comandos do painel de administração
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

	def find_guild_member(guild, name)
		guild.members.find { |member| member.casecmp(name).zero? }
	end
	
	def member_in_guild?(guild, name)
		find_guild_member(guild, name) != nil
	end

	def find_guild_id_db(name)
		name.empty? ? 0 : @guilds[name].id_db
	end
	
	def find_guild_name(guild_id_db)
		return '' if guild_id_db == 0
		guild = @guilds.find { |name, guild| guild.id_db == guild_id_db }
		# O dup em vez de clone clona a key da guilda, sem, no entanto, copiar o status congelado da
		#chave, permitindo que a guilda do jogador possa ser apagada se, posteriormente, ele sair dela
		guild ? guild.first.dup : ''
	end

	def titleize(str)
		str.split.each(&:capitalize!).join(' ')
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
		!client.connected? || client.logged?
	end

	def create_account_hacking_attempt?(client, user, pass, email)
		return true unless client.connected?
		return true if client.logged?
		return true if user.size < Configs::MIN_CHARACTERS || user.size > Configs::MAX_CHARACTERS
		# A quantidade máxima de caracteres é 32, pois a senha é criptografada no formato
		#de hash MD5, com valor fixo de hash de 128 bits expresso em 32 caracteres
		return true if pass.size < Configs::MIN_CHARACTERS || pass.size > 32
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
			@blocked_ips[client.ip].time = Time.now + IP_BLOCKING_TIME
			send_failed_login(client, Enums::Login::IP_BLOCKED)
			# Desconecta depois que enviar a mensagem acima, se o usuário
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
			@switches[str.to_i] = (int1 == 1)
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
					player_message(player, sprintf(FullInventory, client.name), Configs::ERROR_COLOR)
					@log.add(player.group, :blue, "#{player.user} tentou dar #{amount} #{item.name} para #{name}, mas o inventário deste estava cheio.")
					return
				else
					client.gain_item(item, amount, false, true)
					player_message(player, "#{sprintf(GaveItem, amount, item.name)} #{client.name}.", Configs::SUCCESS_COLOR)
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
			# Carrega o ID da conta junto com o nome do jogador que será banido. O nome será
			#mostrado no bate-papo global grafado com letras maiúsculas e minúsculas
			account_id_db, name = Database.load_some_player_data(name)
			@ban_list[account_id_db] = time
			global_message("#{name} #{Banned}")
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
		global_message("#{player.name} #{Banned}")
		@log.add(client.group, :blue, "#{client.user} baniu #{player.name} por #{days} dia(s).")
	end

	def kick_banned_ip(banned_ip)
		@clients.each do |client|
			next if client&.ip != banned_ip || client.admin?
			send_admin_command(client, Enums::Command::BAN_IP)
			client.close_connection_after_writing
		end
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
		global_message(message, Configs::ADM_MSG_COLOR)
		@log.add(player.group, :blue, "#{player.user} enviou a mensagem: #{message}.")
	end

	def whos_online(player)
		names = []
		@clients.each { |client| names << "#{client.name} [#{client.level}]" if client&.in_game? }
		if names.size > 1
			# Envia no máximo 40 nomes para evitar spawn
			send_whos_online(player, sprintf(Connected, names.size, names.take(40).join(', ')))
		else
			send_whos_online(player, NobodyConnected)
		end
	end
	
end
