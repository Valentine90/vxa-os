#==============================================================================
# ** Game_Guild
#------------------------------------------------------------------------------
#  Este script lida com a guilda.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Guild
	
  def open_guild(client)
		online_members = @guilds[client.guild].members.select { |name| find_player(name) }
		offline_members = @guilds[client.guild].members - online_members
		@guilds[client.guild].members = online_members + offline_members
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
		client.guild = name.clone
		@guilds[name] = Guild.new
		# Impede que o nome do líder seja alterado
		#quando @name dele ficar vazia no leave_game
		@guilds[name].leader = client.name.clone
		@guilds[name].flag = flag
		@guilds[name].members = [@guilds[name].leader]
		@guilds[name].notice = ''
		save_guild(name)
		send_guild_name(client)
		player_message(client, sprintf(NewGuild, name), Configs::SUCCESS_COLOR)
		client.creating_guild = false
		client.event_interpreter.fiber.resume
  end

  def change_guild_leader(client, name)
		member = find_guild_member(@guilds[client.guild], name)
		if member && @guilds[client.guild].leader != member
			@guilds[client.guild].leader = member
			guild_message(client, "#{member} #{ChangeLeader}", Configs::GUILD_COLOR)
			save_guild(client.guild)
			send_guild_leader(client)
		else
			$server.alert_message(client, Enums::Alert::INVALID_NAME)
		end
	end
	
	def change_guild_notice(client, notice)
		@guilds[client.guild].notice = notice
		guild_message(client, "#{ChangeNotice} #{notice}", Configs::GUILD_COLOR)
		save_guild(client.guild)
		send_guild_notice(client)
	end

	def remove_guild_member(client, member_name)
		player = find_player(member_name)
    if player
			player.leave_guild
    else
      @guilds[client.guild].members.delete(member_name)
      save_guild(client.guild)
    end
    send_remove_guild_member(client, member_name)
  end

  def remove_guild(guild_name)
		message = sprintf(RemoveGuild, guild_name)
		@clients.each do |player|
			if player&.in_game? && player.guild == guild_name
				player.guild.clear
				send_guild_name(player)
				player_message(player, message, Configs::ERROR_COLOR)
			end
		end
		@guilds.delete(guild_name)
    File.delete("Data/Guilds/#{guild_name}.bin")
  end

end
