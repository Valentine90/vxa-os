#==============================================================================
# ** Database
#------------------------------------------------------------------------------
#  Este módulo lida com o banco de dados de contas, jogadores, bancos, guildas
# e lista de banidos.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Database

	def self.sql_client
		if DATABASE_PATH.empty?
			Sequel.connect("mysql2://#{DATABASE_USER}:#{DATABASE_PASS}@#{DATABASE_HOST}:#{DATABASE_PORT}/#{DATABASE_NAME}")
		else
			Sequel.connect("sqlite://Data/#{DATABASE_PATH}.db")
		end
	end

	def self.create_account(user, pass, email)
		s_client = sql_client
		# Salva o valor 0 em cash para que esta coluna, cujo tipo é text, não fique vazia
		s_client[:accounts].insert(:username => user, :password => pass, :email => email, 
		  :vip_time => Time.now.to_i, :creation_date => Time.now.to_i, :cash => 0)
		account_id_db = s_client[:accounts].select(:id).where(:username => user).single_value
		s_client[:banks].insert(:account_id => account_id_db)
		s_client.disconnect
	end

	def self.load_account(user)
		s_client = sql_client
		result = s_client[:accounts].where(:username => user)#Sequel.ilike(:username, "#{user}%"))
		account = Account.new
		account.id_db = result.get(:id)
		account.pass = result.get(:password)
		account.group = result.get(:group)
		account.vip_time = [Time.at(result.get(:vip_time)), Time.now].max
		account.friends = s_client[:account_friends].select(:name).where(:account_id => account.id_db).map(:name)
		account.actors = {}
		actors = s_client[:actors].where(:account_id => account.id_db)
		actors.each { |row| account.actors[row[:slot_id]] = load_player(row, s_client) }
		s_client.disconnect
		account
	end

	def self.save_account(client, s_client)
		# Carrega vip_time da conta no banco de dados, pois o jogador pode ter
		#comprado vip na loja do site durante o jogo
		vip_time = [s_client[:accounts].select(:vip_time).where(:id => client.account_id_db).single_value, Time.now.to_i].max
		s_client[:accounts].where(:id => client.account_id_db).update(:vip_time => vip_time + client.added_vip_time)
		# Atualiza o tempo VIP e reseta o tempo VIP adicionado caso o jogador
		#vá para seleção de personagens e depois volte para o jogo
		client.vip_time = Time.at(vip_time) + client.added_vip_time
		client.added_vip_time = 0
		friends = s_client[:account_friends].select(:name).where(:account_id => client.account_id_db).map(:name)
		(friends - client.friends).each do |name|
			s_client[:account_friends].where(:account_id => client.account_id_db, :name => name).delete
		end
		(client.friends - friends).each do |name|
			s_client[:account_friends].insert(:account_id => client.account_id_db, :name => name)
		end
	end

	def self.account_exist?(user)
		s_client = sql_client
		account = s_client[:accounts].select(:id).where(:username => user)#Sequel.ilike(:username, "#{user}%"))
		s_client.disconnect
		!account.empty?
	end
	
	def self.create_player(client, actor_id, name, character_index, class_id, sex, params, points)
		actor = Actor.new
		actor.name = name
		actor.character_name = $data_classes[class_id].graphics[sex][character_index][0]
		actor.character_index = $data_classes[class_id].graphics[sex][character_index][1]
		actor.face_name = $data_classes[class_id].graphics[sex + 2] ? $data_classes[class_id].graphics[sex + 2][character_index][0] : ''
		actor.face_index = $data_classes[class_id].graphics[sex + 2] ? $data_classes[class_id].graphics[sex + 2][character_index][1] : 0
		actor.class_id = class_id
		actor.sex = sex
		actor.level = $data_actors[class_id].initial_level
		actor.exp = $data_classes[class_id].exp_for_level(actor.level)
		maxhp = params[Enums::Param::MAXHP] * 10 + $data_classes[class_id].params[Enums::Param::MAXHP, actor.level]
		maxmp = params[Enums::Param::MAXMP] * 10 + $data_classes[class_id].params[Enums::Param::MAXMP, actor.level]
		actor.hp = maxhp
		actor.mp = maxmp
		actor.param_base = [maxhp, maxmp]
		(Enums::Param::ATK..Enums::Param::LUK).each { |param_id| actor.param_base << $data_classes[class_id].params[param_id, actor.level] + params[param_id] }
		actor.equips = $data_actors[class_id].equips + [0] * (Configs::MAX_EQUIPS - 5)
		actor.points = points
		actor.guild_name = ''
		actor.revive_map_id = actor.map_id = $data_system.start_map_id
		actor.revive_x = actor.x = $data_system.start_x
		actor.revive_y = actor.y = $data_system.start_y
		actor.direction = Enums::Dir::DOWN
		actor.gold = 0
		actor.items = {}
		actor.weapons = {}
		actor.armors = {}
		actor.skills = []
		$data_classes[class_id].learnings.each { |learning| actor.skills << learning.skill_id if learning.level <= actor.level }
		actor.quests = {}
		# Preenche a matriz com objetos mutáveis separados
		actor.hotbar = Array.new(Configs::MAX_HOTBAR) { Hotbar.new(0, 0) }
		actor.switches = Array.new(Configs::MAX_PLAYER_SWITCHES, false)
		actor.variables = Array.new(Configs::MAX_PLAYER_VARIABLES, 0)
		actor.self_switches = {}
		s_client = sql_client
		s_client[:actors].insert(:slot_id => actor_id, :account_id => client.account_id_db, :name => actor.name,
			:character_name => actor.character_name, :character_index => actor.character_index, :face_name => actor.face_name,
		  :face_index => actor.face_index, :class_id => actor.class_id, :sex => actor.sex, :level => actor.level,
		  :exp => actor.exp, :hp => actor.hp, :mp => actor.mp, :mhp => actor.param_base[0], :mmp => actor.param_base[1],
			:atk => actor.param_base[2], :def => actor.param_base[3], :int => actor.param_base[4], :res => actor.param_base[5],
			:agi => actor.param_base[6], :luk => actor.param_base[7], :points => actor.points,
			:revive_map_id => actor.revive_map_id, :revive_x => actor.revive_x, :revive_y => actor.revive_y,
			:map_id => actor.map_id, :x => actor.x, :y => actor.y, :direction => actor.direction, 
			:creation_date => Time.now.to_i, :last_login => Time.now.to_i)
		actor.id_db = s_client[:actors].select(:id).where(:name => actor.name).single_value
		actor.equips.each_with_index { |equip_id, slot_id| s_client[:actor_equips].insert(:actor_id => actor.id_db, :slot_id => slot_id, :equip_id => equip_id) }
		actor.skills.each { |skill| s_client[:actor_skills].insert(:actor_id => actor.id_db, :skill_id => skill) }
		Configs::MAX_HOTBAR.times { |slot_id| s_client[:actor_hotbars].insert(:actor_id => actor.id_db, :slot_id => slot_id) }
		Configs::MAX_PLAYER_SWITCHES.times { |switch_id| s_client[:actor_switches].insert(:actor_id => actor.id_db, :switch_id => switch_id + 1) }
		Configs::MAX_PLAYER_VARIABLES.times { |variable_id| s_client[:actor_variables].insert(:actor_id => actor.id_db, :variable_id => variable_id + 1) }
		s_client.disconnect
		client.actors[actor_id] = actor
	end

	def self.load_some_player_data(name)
		s_client = sql_client
		# O ilike pesquisa de maneira não sensível a maiúsculas e minúsculas no SQLite
		actor = s_client[:actors].select(:account_id, :name).where(:name => name)#Sequel.ilike(:name, "#{name}%"))
		s_client.disconnect
		actor.map([:account_id, :name]).first
	end

	def self.load_player(row, s_client)
		actor = Actor.new
		actor.id_db = row[:id]
		actor.name = row[:name]
		actor.character_name = row[:character_name]
		actor.character_index = row[:character_index]
		actor.face_name = row[:face_name]
		actor.face_index = row[:face_index]
		actor.class_id = row[:class_id]
		actor.sex = row[:sex]
		actor.level = row[:level]
		actor.exp = row[:exp]
		actor.hp = row[:hp]
		actor.mp = row[:mp]
		actor.param_base = [row[:mhp], row[:mmp], row[:atk], row[:def], row[:int], row[:res], row[:agi], row[:luk]]
		actor.points = row[:points]
		actor.guild_name = $network.find_guild_name(row[:guild_id])
		actor.revive_map_id = row[:revive_map_id]
		actor.revive_x = row[:revive_x]
		actor.revive_y = row[:revive_y]
		map_id = row[:map_id]
		# Se o mapa existe
		actor.map_id = $network.maps.has_key?(map_id) ? map_id : actor.revive_map_id
		actor.x = row[:x]
		actor.y = row[:y]
		actor.direction = row[:direction]
		actor.gold = row[:gold]
		actor.skills = s_client[:actor_skills].select(:skill_id).where(:actor_id => actor.id_db).map(:skill_id)
		# O SQLite não possui uma classe de armazenamento booleana separada, por isso
		#os valores booleanos são armazenados como inteiros 1 (true) e 0 (false)
		actor.switches = s_client[:actor_switches].select(:value).where(:actor_id => actor.id_db).map { |r| r[:value] == 1 }
		actor.variables = s_client[:actor_variables].select(:value).where(:actor_id => actor.id_db).map(:value)
		actor.self_switches = {}
		s_client[:actor_self_switches].where(:actor_id => actor.id_db).each { |r| actor.self_switches[[r[:map_id], r[:event_id], r[:ch]]] = (r[:value] == 1) }
		load_player_equips(actor, s_client)
		load_player_items(actor, s_client)
		load_player_weapons(actor, s_client)
		load_player_armors(actor, s_client)
		load_player_quests(actor, s_client)
		load_player_hotbar(actor, s_client)
		actor
	end
	
	def self.load_player_equips(actor, s_client)
		actor.equips = []
		equips = s_client[:actor_equips].select(:equip_id, :slot_id).where(:actor_id => actor.id_db)
		equips.each do |row|
			# Se o equipamento não existe no banco de dados
			row[:equip_id] = 0 if row[:slot_id] == Enums::Equip::WEAPON && !$data_weapons[row[:equip_id]] ||
			  row[:slot_id] > Enums::Equip::WEAPON && !$data_armors[row[:equip_id]]
			actor.equips << row[:equip_id]
		end
	end

	def self.load_player_items(actor, s_client)
		actor.items = {}
		items = s_client[:actor_items].select(:item_id, :amount).where(:actor_id => actor.id_db)
		# Se o item existe no banco de dados
		items.each { |row| actor.items[row[:item_id]] = row[:amount] if $data_items[row[:item_id]] }
	end

	def self.load_player_weapons(actor, s_client)
		actor.weapons = {}
		weapons = s_client[:actor_weapons].select(:weapon_id, :amount).where(:actor_id => actor.id_db)
		weapons.each { |row| actor.weapons[row[:weapon_id]] = row[:amount] if $data_weapons[row[:weapon_id]] }
	end

	def self.load_player_armors(actor, s_client)
		actor.armors = {}
		armors = s_client[:actor_armors].select(:armor_id, :amount).where(:actor_id => actor.id_db)
		armors.each { |row| actor.armors[row[:armor_id]] = row[:amount] if $data_armors[row[:armor_id]] }
	end

	def self.load_player_quests(actor, s_client)
		actor.quests = {}
		quests = s_client[:actor_quests].where(:actor_id => actor.id_db)
		quests.each { |row| actor.quests[row[:quest_id]] = Game_Quest.new(row[:quest_id], row[:state], row[:kills]) }
	end

	def self.load_player_hotbar(actor, s_client)
		actor.hotbar = []
		hotbar = s_client[:actor_hotbars].select(:item_id, :type).where(:actor_id => actor.id_db)
		hotbar.each do |row|
			row[:type] = row[:item_id] = 0 if row[:type] == Enums::Hotbar::ITEM && !$data_items[row[:item_id]] || 
			  row[:type] == Enums::Hotbar::SKILL && !$data_skills[row[:item_id]]
			actor.hotbar << Hotbar.new(row[:type], row[:item_id])
		end
	end

	def self.save_player(client)
		s_client = sql_client
		s_client[:actors].where(:id => client.id_db).update(:character_name => client.character_name,
			:character_index => client.character_index, :face_name => client.face_name, :face_index => client.face_index,
			:class_id => client.class_id, :sex => client.sex, :level => client.level, :exp => client.exp, :hp => client.hp,
			:mp => client.mp, :mhp => client.param_base[0], :mmp => client.param_base[1], :atk => client.param_base[2],
			:def => client.param_base[3], :int => client.param_base[4], :res => client.param_base[5],
			:agi => client.param_base[6], :luk => client.param_base[7], :points => client.points,
			:guild_id => $network.find_guild_id_db(client.guild_name), :revive_map_id => client.revive_map_id,
			:revive_x => client.revive_x, :revive_y => client.revive_y, :map_id => client.map_id, :x => client.x,
			:y => client.y, :direction => client.direction, :gold => client.gold, :last_login => Time.now.to_i)
		client.equips.each_with_index { |equip_id, slot_id| s_client[:actor_equips].where(:actor_id => client.id_db, :slot_id => slot_id).update(:equip_id => equip_id) }
		client.hotbar.each_with_index { |hotbar, slot_id| s_client[:actor_hotbars].where(:actor_id => client.id_db, :slot_id => slot_id).update(:type => hotbar.type, :item_id => hotbar.item_id) }
		client.switches.data.each_with_index { |value, switch_id| s_client[:actor_switches].where(:actor_id => client.id_db, :switch_id => switch_id + 1).update(:value => value ? 1 : 0) }
		client.variables.data.each_with_index { |value, variable_id| s_client[:actor_variables].where(:actor_id => client.id_db, :variable_id => variable_id + 1).update(:value => value) }
		save_items(client, client.items, s_client, 'item')
		save_items(client, client.weapons, s_client, 'weapon')
		save_items(client, client.armors, s_client, 'armor')
		save_player_skills(client, s_client)
		save_player_quests(client, s_client)
		save_player_self_switches(client, s_client)
		save_account(client, s_client)
		save_bank(client, s_client)
		s_client.disconnect
	end
	
	def self.save_items(client, actor_items, s_client, item)
		if actor_items.object_id == client.items.object_id || actor_items.object_id == client.weapons.object_id ||
		 actor_items.object_id == client.armors.object_id
			id_db = client.id_db
			object_id = :actor_id
			table = "actor_#{item}s".to_sym
		else
			id_db = client.bank_id_db
			object_id = :bank_id
			table = "bank_#{item}s".to_sym
		end
		items = s_client[table].select("#{item}_id".to_sym, :amount).where(object_id => id_db).as_hash("#{item}_id".to_sym, :amount)
		actor_items.each do |item_id, amount|
			if !items.has_key?(item_id)
				s_client[table].insert(object_id => id_db, "#{item}_id".to_sym => item_id, :amount => amount)
				next
			elsif amount != items[item_id]
				s_client[table].where(object_id => id_db, "#{item}_id".to_sym => item_id).update(:amount => amount)
			end
			items.delete(item_id)
		end
		items.each_key { |item_id| s_client[table].where(object_id => id_db, "#{item}_id".to_sym => item_id).delete }
	end

	def self.save_player_skills(client, s_client)
		skills = s_client[:actor_skills].select(:skill_id).where(:actor_id => client.id_db).map(:skill_id)
		(skills - client.skills).each do |skill_id|
			s_client[:actor_skills].where(:actor_id => client.id_db, :skill_id => skill_id).delete
		end
		(client.skills - skills).each do |skill_id|
			s_client[:actor_skills].insert(:actor_id => client.id_db, :skill_id => skill_id)
		end
	end

	def self.save_player_quests(client, s_client)
		quests = s_client[:actor_quests].select(:quest_id).where(:actor_id => client.id_db).map(:quest_id)
		client.quests.each do |quest_id, quest|
			if quests.include?(quest_id)
				s_client[:actor_quests].where(:actor_id => client.id_db, :quest_id => quest_id).update(:state => quest.state, :kills => quest.kills)
				quests.delete(quest_id)
			else
				# Salva todos os dados da nova missão, inclusive state e kills, já que ela
				#pode ter sido finalizada logo após ter sido iniciada pelo jogador
				s_client[:actor_quests].insert(:actor_id => client.id_db, :quest_id => quest_id, :state => quest.state, :kills => quest.kills)
			end
		end
		quests.each { |quest_id| s_client[:actor_quests].where(:actor_id => client.id_db, :quest_id => quest_id).delete }
	end

	def self.save_player_self_switches(client, s_client)
		self_switches = s_client[:actor_self_switches].where(:actor_id => client.id_db).select_hash([:map_id, :event_id, :ch], :value)
		client.self_switches.data.each do |key, value|
			if self_switches.has_key?(key) && value != self_switches[key]
				s_client[:actor_self_switches].where(:actor_id => client.id_db, :map_id => key[0], :event_id => key[1],
				  :ch => key[2]).update(:value => value ? 1 : 0)
			elsif !self_switches.has_key?(key)
				s_client[:actor_self_switches].insert(:actor_id => client.id_db, :map_id => key[0], :event_id => key[1],
				  :ch => key[2], :value => value ? 1 : 0)
			end
		end
	end

	def self.player_exist?(name)
		s_client = sql_client
		# Embora não seja necessário pesquisar o nome do jogador de maneira não sensível
		#a maiúsculas e minúsculas na criação de personagem em razão do titleize, é
		#necessário fazer uma busca case-insensitive ao banir jogador off-line
		player = s_client[:actors].select(:id).where(:name => name)#Sequel.ilike(:name, "#{name}%"))
		s_client.disconnect
		!player.empty?
	end

	def self.remove_player(actor_id_db)
		s_client = sql_client
		s_client[:actors].where(:id => actor_id_db).delete
		s_client[:actor_equips].where(:actor_id => actor_id_db).delete
		s_client[:actor_items].where(:actor_id => actor_id_db).delete
		s_client[:actor_weapons].where(:actor_id => actor_id_db).delete
		s_client[:actor_armors].where(:actor_id => actor_id_db).delete
		s_client[:actor_skills].where(:actor_id => actor_id_db).delete
		s_client[:actor_quests].where(:actor_id => actor_id_db).delete
		s_client[:actor_hotbars].where(:actor_id => actor_id_db).delete
		s_client[:actor_switches].where(:actor_id => actor_id_db).delete
		s_client[:actor_variables].where(:actor_id => actor_id_db).delete
		s_client[:actor_self_switches].where(:actor_id => actor_id_db).delete
		s_client.disconnect
	end

	def self.load_bank(client)
		s_client = sql_client
		result = s_client[:banks].where(:account_id => client.account_id_db)
		client.bank_id_db = result.get(:id)
		client.bank_gold = result.get(:gold)
		items = s_client[:bank_items].select(:item_id, :amount).where(:bank_id => client.bank_id_db)
		client.bank_items = items.as_hash(:item_id, :amount)
		weapons = s_client[:bank_weapons].select(:weapon_id, :amount).where(:bank_id => client.bank_id_db)
		client.bank_weapons = weapons.as_hash(:weapon_id, :amount)
		armors = s_client[:bank_armors].select(:armor_id, :amount).where(:bank_id => client.bank_id_db)
		client.bank_armors = armors.as_hash(:armor_id, :amount)
		s_client.disconnect
	end

	def self.save_bank(client, s_client)
		s_client[:banks].where(:account_id => client.account_id_db).update(:gold => client.bank_gold)
		save_items(client, client.bank_items, s_client, 'item')
		save_items(client, client.bank_weapons, s_client, 'weapon')
		save_items(client, client.bank_armors, s_client, 'armor')
	end

	def self.load_distributor(client)
		s_client = sql_client
		items = s_client[:distributor].where(:account_id => client.account_id_db)
		# Carrega os itens comprados na loja do site de uma tabela específica, em vez de
		#carregá-los diretamente do banco, para evitar que o item seja deletado erroneamente
		#após fechar o banco, quando o jogador comprar no site enquanto estiver com o banco aberto
		items.each do |row|
			container = client.bank_item_container(row[:kind])
			container[row[:item_id]] = [client.bank_item_number(container[row[:item_id]]) + row[:amount], Configs::MAX_ITEMS].min
		end
		# Deleta do distribuidor do banco de dados todos os itens vinculados à conta
		items.delete
		s_client.disconnect
	end

	def self.create_guild(name)
		s_client = sql_client
		s_client[:guilds].insert(:name => name, :leader => $network.guilds[name].leader,
		  :flag => $network.guilds[name].flag.join(','), :creation_date => Time.now.to_i)
		$network.guilds[name].id_db = s_client[:guilds].select(:id).where(:name => name).single_value
		s_client.disconnect
	end

	def self.load_guilds
		s_client = sql_client
		s_client[:guilds].each do |row|
			name = row[:name]
			$network.guilds[name] = Guild.new
			$network.guilds[name].id_db = row[:id]
			$network.guilds[name].leader = row[:leader]
			$network.guilds[name].notice = row[:notice]
			$network.guilds[name].flag = row[:flag].split(',').collect { |color_id| color_id.to_i }
			$network.guilds[name].members = s_client[:actors].select(:name).where(:guild_id => row[:id]).map(:name)
		end
		s_client.disconnect
	end

	def self.save_guild(guild)
		s_client = sql_client
		s_client[:guilds].where(:id => guild.id_db).update(:leader => guild.leader, :notice => guild.notice)
		s_client.disconnect
	end

	def self.remove_guild(guild)
		s_client = sql_client
		s_client[:guilds].where(:id => guild.id_db).delete
		s_client[:actors].where(:guild_id => guild.id_db).update(:guild_id => 0)
		s_client.disconnect
	end

	def self.remove_guild_member(member_name)
		s_client = sql_client
		s_client[:actors].where(:name => member_name).update(:guild_id => 0)
		s_client.disconnect
	end

	def self.load_banlist
		s_client = sql_client
		s_client[:ban_list].each do |row|
			key = row[:account_id] > 0 ? row[:account_id] : row[:ip]
			$network.ban_list[key] = row[:time]
		end
		s_client.disconnect
	end

	def self.save_banlist
		s_client = sql_client
		ban_list = {}
		s_client[:ban_list].each do |row|
			key = row[:account_id] > 0 ? row[:account_id] : row[:ip]
			ban_list[key] = row[:time]
		end
		ban_list.each do |key, time|
			next if $network.ban_list.has_key?(key)
			s_client[:ban_list].where(:ip => key).delete if key.is_a?(String)
			s_client[:ban_list].where(:account_id => key).delete if key.is_a?(Integer)
		end
		$network.ban_list.each do |key, time|
			next if ban_list.has_key?(key)
			s_client[:ban_list].insert(:ip => key, :time => time, :ban_date => Time.now.to_i) if key.is_a?(String)
			s_client[:ban_list].insert(:account_id => key, :time => time, :ban_date => Time.now.to_i) if key.is_a?(Integer)
		end
		s_client.disconnect
	end

	def self.unban(client, player_name)
		s_client = sql_client
		account_id_db = s_client[:actors].select(:account_id).where(:name => player_name).single_value#Sequel.ilike(:name, "#{player_name}%")).single_value
		s_client.disconnect
		# O ID da conta é diferente de nulo se o nome do jogador existe no banco de dados
		if account_id_db
			$network.ban_list.delete(account_id_db)
			$network.global_chat_message("#{player_name} #{NotBanned}")
			$network.log.add(client.group, :blue, "#{client.user} removeu o banimento de #{player_name}.")
		end
	end

	def self.change_whos_online(id_db, command)
		s_client = sql_client
		s_client[:actors].where(:id => id_db).update(:online => (command == :insert ? 1 : 0))
		s_client.disconnect
	end

end
