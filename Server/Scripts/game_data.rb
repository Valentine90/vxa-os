#==============================================================================
# ** Game_Data
#------------------------------------------------------------------------------
#  Este módulo lida com o banco de dados.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Data

  def load_game_data
		load_enemies
		load_states
		load_animations
		load_actors
		load_classes
		load_skills
		load_items
		load_weapons
		load_armors
		load_tilesets
		load_maps
		load_common_events
		load_system
		load_motd
		load_banlist
		load_global_switches
		load_guilds
		puts(Time.now.strftime("Servidor iniciado às %-kh%Mmin."))
  end
  
	def load_enemies
		puts('Carregando inimigos...')
		enemies = load_data('Enemies.rvdata2')
		# Só carrega os dados que serão usados
		(1...enemies.size).each do |enemy_id|
			$data_enemies[enemy_id] = RPG::Enemy.new
			$data_enemies[enemy_id].name = enemies[enemy_id].name
			$data_enemies[enemy_id].params = enemies[enemy_id].params
			$data_enemies[enemy_id].gold = enemies[enemy_id].gold
			$data_enemies[enemy_id].exp = enemies[enemy_id].exp
			$data_enemies[enemy_id].drop_items = enemies[enemy_id].drop_items
			$data_enemies[enemy_id].actions = enemies[enemy_id].actions
			$data_enemies[enemy_id].features = enemies[enemy_id].features
			$data_enemies[enemy_id].sight = Note.read_number('Sight', enemies[enemy_id].note)
			revive_time = Note.read_number('ReviveTime', enemies[enemy_id].note)
			$data_enemies[enemy_id].revive_time = revive_time > 0 ? revive_time : REVIVE_TIME
			$data_enemies[enemy_id].disable_switch_id = Note.read_number('SwitchID', enemies[enemy_id].note)
			$data_enemies[enemy_id].disable_variable_id = Note.read_number('VariableID', enemies[enemy_id].note)
			# Obtém o índice da animação de ataque ou um valor nulo, diferentemente do read_number
			#que retorna 0 se não existir nenhum valor no banco de dados
			ani_index = enemies[enemy_id].note[/AniIndex=(.*)/, 1]
			$data_enemies[enemy_id].ani_index = ani_index ? ani_index.to_i : nil
			$data_enemies[enemy_id].escape = Note.read_boolean('Escape', enemies[enemy_id].note)
		end
	end

	def load_states
		puts('Carregando estados...')
		states = load_data('States.rvdata2')
		(1...states.size).each do |state_id|
			$data_states[state_id] = RPG::State.new
			$data_states[state_id].id = state_id
			$data_states[state_id].features = states[state_id].features
			$data_states[state_id].restriction = states[state_id].restriction
			$data_states[state_id].remove_by_restriction = states[state_id].remove_by_restriction
			$data_states[state_id].remove_by_damage = states[state_id].remove_by_damage
			$data_states[state_id].chance_by_damage = states[state_id].chance_by_damage
		end
	end

	def load_animations
		puts('Carregando animações...')
		animations = load_data('Animations.rvdata2')
		(1...animations.size).each do |animation_id|
			$data_animations[animation_id] = RPG::Animation.new
			# Carrega a quantidade máxima de frames da animação para possibilitar a execução
			#da opção Esperar até o fim do comando de evento Mostrar Animação
			$data_animations[animation_id].frame_max = animations[animation_id].frame_max
		end
	end

	def load_actors
		puts('Carregando heróis...')
		actors = load_data('Actors.rvdata2')
		(1...actors.size).each do |actor_id|
			$data_actors[actor_id] = RPG::Actor.new
			$data_actors[actor_id].initial_level = actors[actor_id].initial_level
			$data_actors[actor_id].equips = actors[actor_id].equips
			$data_actors[actor_id].features = actors[actor_id].features
		end
	end

	def load_classes
		puts('Carregando classes...')
		classes = load_data('Classes.rvdata2')
		(1...classes.size).each do |class_id|
			$data_classes[class_id] = RPG::Class.new
			$data_classes[class_id].exp_params = classes[class_id].exp_params
			$data_classes[class_id].learnings = classes[class_id].learnings
			$data_classes[class_id].params = classes[class_id].params
			$data_classes[class_id].features = classes[class_id].features
			$data_classes[class_id].graphics = Note.read_graphics(classes[class_id].note)
		end
	end

	def load_skills
		puts('Carregando habilidades...')
		skills = load_data('Skills.rvdata2')
		(1...skills.size).each do |skill_id|
			$data_skills[skill_id] = RPG::Skill.new
			$data_skills[skill_id].id = skill_id
			$data_skills[skill_id].name = skills[skill_id].name
			$data_skills[skill_id].scope = skills[skill_id].scope
			$data_skills[skill_id].stype_id = skills[skill_id].stype_id
			$data_skills[skill_id].mp_cost = skills[skill_id].mp_cost
			$data_skills[skill_id].damage = skills[skill_id].damage
			$data_skills[skill_id].animation_id = skills[skill_id].animation_id
			$data_skills[skill_id].effects = skills[skill_id].effects
			$data_skills[skill_id].required_wtype_id1 = skills[skill_id].required_wtype_id1
			$data_skills[skill_id].required_wtype_id2 = skills[skill_id].required_wtype_id2
			$data_skills[skill_id].range = Note.read_number('Range', skills[skill_id].note)
			$data_skills[skill_id].aoe = Note.read_number('AOE', skills[skill_id].note)
			# Obtém o índice da animação de ataque ou um valor nulo, diferentemente do read_number
			#que retorna 0 se não existir nenhum valor no banco de dados
			ani_index = skills[skill_id].note[/AniIndex=(.*)/, 1]
			$data_skills[skill_id].ani_index = ani_index ? ani_index.to_i : 8
		end
	end

	def load_items
		puts('Carregando itens...')
		items = load_data('Items.rvdata2')
		(1...items.size).each do |item_id|
			$data_items[item_id] = RPG::Item.new
			$data_items[item_id].id = item_id
			$data_items[item_id].name = items[item_id].name
			$data_items[item_id].scope = items[item_id].scope
			$data_items[item_id].price = items[item_id].price
			$data_items[item_id].consumable = items[item_id].consumable
			$data_items[item_id].damage = items[item_id].damage
			$data_items[item_id].animation_id = items[item_id].animation_id
			$data_items[item_id].effects = items[item_id].effects
			$data_items[item_id].range = Note.read_number('Range', items[item_id].note)
			$data_items[item_id].aoe = Note.read_number('AOE', items[item_id].note)
			$data_items[item_id].level = Note.read_number('Level', items[item_id].note)
			ani_index = items[item_id].note[/AniIndex=(.*)/, 1]
			$data_items[item_id].ani_index = ani_index ? ani_index.to_i : 8
			$data_items[item_id].soulbound = Note.read_boolean('Soulbound', items[item_id].note)
		end
	end

	def load_weapons
		puts('Carregando armas...')
		weapons = load_data('Weapons.rvdata2')
		(1...weapons.size).each do |weapon_id|
			$data_weapons[weapon_id] = RPG::Weapon.new
			$data_weapons[weapon_id].id = weapon_id
			$data_weapons[weapon_id].name = weapons[weapon_id].name
			$data_weapons[weapon_id].etype_id = weapons[weapon_id].etype_id
			$data_weapons[weapon_id].wtype_id = weapons[weapon_id].wtype_id
			$data_weapons[weapon_id].params = weapons[weapon_id].params
			$data_weapons[weapon_id].animation_id = weapons[weapon_id].animation_id
			$data_weapons[weapon_id].price = weapons[weapon_id].price
			$data_weapons[weapon_id].features = weapons[weapon_id].features
			$data_weapons[weapon_id].level = Note.read_number('Level', weapons[weapon_id].note)
			ani_index = weapons[weapon_id].note[/AniIndex=(.*)/, 1]
			$data_weapons[weapon_id].ani_index = ani_index ? ani_index.to_i : nil
			$data_weapons[weapon_id].vip = Note.read_boolean('VIP', weapons[weapon_id].note)
			$data_weapons[weapon_id].soulbound = Note.read_boolean('Soulbound', weapons[weapon_id].note)
		end
	end

	def load_armors
		puts('Carregando armaduras...')
		armors = load_data('Armors.rvdata2')
		(1...armors.size).each do |armor_id|
			$data_armors[armor_id] = RPG::Armor.new
			$data_armors[armor_id].id = armor_id
			$data_armors[armor_id].name = armors[armor_id].name
			etype_id = Note.read_number('Type', armors[armor_id].note)
			$data_armors[armor_id].etype_id = etype_id > 0 ? etype_id : armors[armor_id].etype_id
			$data_armors[armor_id].atype_id = armors[armor_id].atype_id
			$data_armors[armor_id].params = armors[armor_id].params
			$data_armors[armor_id].price = armors[armor_id].price
			$data_armors[armor_id].features = armors[armor_id].features
			$data_armors[armor_id].level = Note.read_number('Level', armors[armor_id].note)
			$data_armors[armor_id].vip = Note.read_boolean('VIP', armors[armor_id].note)
			$data_armors[armor_id].soulbound = Note.read_boolean('Soulbound', armors[armor_id].note)
			$data_armors[armor_id].sex = armors[armor_id].note.include?('Sex=') ? Note.read_number('Sex', armors[armor_id].note) : 2
		end
	end

	def load_tilesets
		puts('Carregando tilesets...')
		tilesets = load_data('Tilesets.rvdata2')
		(1...tilesets.size).each do |tileset_id|
			$data_tilesets[tileset_id] = RPG::Tileset.new
			$data_tilesets[tileset_id].flags = tilesets[tileset_id].flags
		end
	end

	def load_maps
		puts('Carregando mapas...')
		mapinfos = load_data('MapInfos.rvdata2')
		mapinfos.each_key do |map_id|
			map = load_data(sprintf('Map%03d.rvdata2', map_id))
			@maps[map_id] = Game_Map.new(map_id, map)
			map.events.each do |event_id, event|
				next if event.name == 'notupdate' || event.name == 'notglobal'
				@maps[map_id].events[event_id] = Game_Event.new(event_id, event, map_id)
			end
			@maps[map_id].refresh_tile_events
		end
	end

	def load_common_events
		puts('Carregando eventos comuns...')
		common_events = load_data('CommonEvents.rvdata2')
		(1...common_events.size).each do |common_event|
			$data_common_events[common_event] = RPG::CommonEvent.new
			$data_common_events[common_event].id = common_events[common_event].id
			$data_common_events[common_event].trigger = common_events[common_event].trigger
			$data_common_events[common_event].switch_id = common_events[common_event].switch_id
			$data_common_events[common_event].list = common_events[common_event].list
		end
	end

	def load_system
		puts('Carregando sistema...')
		system = load_data('System.rvdata2')
		$data_system = RPG::System.new
		$data_system.opt_floor_death = system.opt_floor_death
		$data_system.start_map_id = system.start_map_id
		$data_system.start_x = system.start_x
		$data_system.start_y = system.start_y
	end

	def load_motd
		puts('Carregando mensagem do dia...')
		@motd = File.open('motd.txt', 'r:bom|UTF-8', &:read)
	end

	def load_banlist
		puts('Carregando lista de banidos...')
		begin
			Database.load_banlist
		rescue
			puts('O banco de dados SQL está off-line!'.colorize(:red))
			puts('A lista de banidos não foi carregada!'.colorize(:red))
		end
	end

	def load_global_switches
		return unless File.exist?('Data/switches.dat')
		puts('Carregando switches globais...')
		file = File.open('Data/switches.dat', 'rb')
		@switches = Marshal.load(file)
		file.close
	end

	def load_guilds
		puts('Carregando guildas...')
		begin
			Database.load_guilds
		rescue
			puts('As guildas não foram carregadas!'.colorize(:red))
		end
	end
  
	def save_game_data
		puts(Time.now.strftime("Salvando todos os dados às %-kh%Mmin...").colorize(:green))
		save_motd
		save_global_switches
		save_all_players_online
		Database.save_banlist
		@log.save_all
	end

	def save_motd
		file = File.open('motd.txt', 'w')
		file.write(@motd)
		file.close
	end

	def save_global_switches
		file = File.open('Data/switches.dat', 'wb')
		file.write(Marshal.dump(@switches))
		file.close
	end
	
	def save_all_players_online
		@clients.each { |client| Database.save_player(client) if client&.in_game? }
	end

end
