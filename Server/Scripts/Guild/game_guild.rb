#==============================================================================
# ** Game_Guild
#------------------------------------------------------------------------------
#  Este script lida com a guilda.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Guild
	
  def open_guild(client)
		online_members = @guilds[client.guild_name].members.select { |name| find_player(name) }
		offline_members = @guilds[client.guild_name].members - online_members
		@guilds[client.guild_name].members = online_members + offline_members
		send_open_guild(client, online_members.size)
  end

  def create_guild(client, name, flag)
		if @guilds.has_key?(name)
			alert_message(client, Enums::Alert::GUILD_EXIST)
			client.close_create_guild
			return
		end
		# Impede que o nome da guilda seja alterado se, posteriormente,
		#o líder passar o cargo para outro membro e sair dela
		client.guild_name = name.clone
		@guilds[name] = Guild.new
		# Impede que o nome do líder seja alterado
		#quando @name dele ficar vazia no leave_game
		@guilds[name].leader = client.name.clone
		@guilds[name].flag = flag
		@guilds[name].members = [@guilds[name].leader]
		@guilds[name].notice = ''
		Database.create_guild(name)
		send_guild_name(client)
		player_chat_message(client, sprintf(NewGuild, name), Configs::SUCCESS_COLOR)
		client.creating_guild = false
		client.event_interpreter.fiber.resume
  end

  def change_guild_leader(client, name)
		member = find_guild_member(@guilds[client.guild_name], name)
		if !member || @guilds[client.guild_name].leader == member
			$network.alert_message(client, Enums::Alert::INVALID_NAME)
			return
		end
		@guilds[client.guild_name].leader = member
		guild_chat_message(client, "#{member} #{ChangeLeader}", Configs::GUILD_COLOR)
		Database.save_guild(@guilds[client.guild_name])
		send_guild_leader(client)
	end
	
	def change_guild_notice(client, notice)
		@guilds[client.guild_name].notice = notice
		guild_chat_message(client, "#{ChangeNotice} #{notice}", Configs::GUILD_COLOR)
		Database.save_guild(@guilds[client.guild_name])
		send_guild_notice(client)
	end

	def remove_guild_member(client, member_name)
		player = find_player(member_name)
    if player
			player.leave_guild
    else
			@guilds[client.guild_name].members.delete(member_name)
			Database.remove_guild_member(member_name)
    end
    send_remove_guild_member(client, member_name)
  end

  def remove_guild(guild_name)
		message = sprintf(RemoveGuild, guild_name)
		@clients.each do |player|
			next unless player&.in_game? && player.guild_name == guild_name
			player.guild_name.clear
			send_guild_name(player)
			player_chat_message(player, message, Configs::ERROR_COLOR)
		end
		Database.remove_guild(@guilds[guild_name])
		@guilds.delete(guild_name)
  end

end
