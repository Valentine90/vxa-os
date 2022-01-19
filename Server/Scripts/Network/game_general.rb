#==============================================================================
# ** Game_General
#------------------------------------------------------------------------------
#  Este script lida com funções gerais do servidor.
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
