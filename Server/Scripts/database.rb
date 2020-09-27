#==============================================================================
# ** Database
#------------------------------------------------------------------------------
#  Este módulo lida com o banco de dados de contas, jogadores e banco.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Database
	
	def self.create_account(user, pass, email)
		writer = Binary_Writer.new
		writer.write_string(pass)
		writer.write_string(email)
		writer.write_byte(Enums::Group::STANDARD)
		writer.write_time(Time.now)
		writer.write_byte(0)
		# Salva o arquivo em modo binário
		file = File.open("Data/Accounts/#{user}.bin", mode: 'wb')
		file.write(writer.to_s)
		file.close
	end

	def self.load_account(user)
		account = Account.new
		reader = Binary_Reader.new(File.read("Data/Accounts/#{user}.bin", mode: 'rb'))
		account.pass = reader.read_string
		account.email = reader.read_string
		account.group = reader.read_byte
		account.vip_time = reader.read_time
		account.friends = []
		size = reader.read_byte
		size.times { account.friends << reader.read_string }
		account.actors = {}
		until reader.eof?
			account.actors[reader.read_byte] = load_player(reader.read_string)
		end
		account
	end

	def self.save_account(client)
		writer = Binary_Writer.new
		writer.write_string(client.pass)
		writer.write_string(client.email)
		writer.write_byte(client.group)
		writer.write_time(client.vip_time)
		writer.write_byte(client.friends.size)
		client.friends.each { |name| writer.write_string(name) }
		client.actors.each do |actor_id, actor|
			writer.write_byte(actor_id)
			writer.write_string(actor.name)
		end
		file = File.open("Data/Accounts/#{client.user}.bin", mode: 'wb')
		file.write(writer.to_s)
		file.close
	end

	def self.account_exist?(user)
		File.exist?("Data/Accounts/#{user}.bin")
	end
	
	def self.create_player(client, actor_id, name, character_index, class_id, sex, params, points)
		actor = Actor.new
		actor.user = client.user
		actor.name = name
		actor.character_name = $data_classes[class_id].graphics[sex][character_index][0]
		actor.character_index = $data_classes[class_id].graphics[sex][character_index][1]
		actor.face_name = $data_classes[class_id].graphics[sex + 2] ? $data_classes[class_id].graphics[sex + 2][character_index][0] : ''
		actor.face_index = $data_classes[class_id].graphics[sex + 2] ? $data_classes[class_id].graphics[sex + 2][character_index][1] : 0
		actor.class_id = class_id
		actor.sex = sex
		initial_level = $data_actors[class_id].initial_level
		actor.level = initial_level
		actor.exp = $data_classes[class_id].exp_for_level(initial_level)
		maxhp = params[Enums::Param::MAXHP] * 10 + $data_classes[class_id].params[Enums::Param::MAXHP, initial_level]
		maxmp = params[Enums::Param::MAXMP] * 10 + $data_classes[class_id].params[Enums::Param::MAXMP, initial_level]
		actor.hp = maxhp
		actor.mp = maxmp
		actor.param_base = [maxhp, maxmp]
		(2...8).each { |param_id| actor.param_base << params[param_id] + $data_classes[class_id].params[param_id, initial_level] }
		actor.equips = $data_actors[class_id].equips + [0] * (Configs::MAX_EQUIPS - 5)
		actor.points = points
		actor.guild = ''
		actor.revive_map_id = actor.map_id = $data_system.start_map_id
		actor.revive_x = actor.x = $data_system.start_x
		actor.revive_y = actor.y = $data_system.start_y
		actor.direction = Enums::Dir::DOWN
		actor.gold = 0
		actor.items = {}
		actor.weapons = {}
		actor.armors = {}
		actor.skills = []
		$data_classes[class_id].learnings.each { |learning| actor.skills << learning.skill_id if learning.level <= initial_level  }
		actor.quests = {}
		# Preenche a matriz com objetos mutáveis separados
		actor.hotbar = Array.new(Configs::MAX_HOTBAR) { Hotbar.new(0, 0) }
		actor.switches = Array.new(Configs::MAX_PLAYER_SWITCHES, false)
		actor.variables = Array.new(Configs::MAX_PLAYER_VARIABLES, 0)
		actor.self_switches = {}
		client.actors[actor_id] = actor
		save_player(actor)
	end

	def self.load_player(name)
		actor = Actor.new
		reader = Binary_Reader.new(File.read("Data/Players/#{name}.bin", mode: 'rb'))
		actor.name = name
		actor.user = reader.read_string
		actor.character_name = reader.read_string
		actor.character_index = reader.read_byte
		actor.face_name = reader.read_string
		actor.face_index = reader.read_byte
		actor.class_id = reader.read_short
		actor.sex = reader.read_byte
		actor.level = reader.read_short
		actor.exp = reader.read_int
		actor.hp = reader.read_int
		actor.mp = reader.read_int
		actor.param_base = []
		8.times { actor.param_base << reader.read_int }
		actor.equips = []
		Configs::MAX_EQUIPS.times do |slot_id|
			equip_id = reader.read_short
			# Se o equipamento ainda existir no banco de dados
			equip_id = 0 if slot_id == Enums::Equip::WEAPON && !$data_weapons[equip_id] || slot_id > Enums::Equip::WEAPON && !$data_armors[equip_id]
			actor.equips << equip_id
		end
		actor.points = reader.read_short
		actor.guild = reader.read_string
		actor.revive_map_id = reader.read_short
		actor.revive_x = reader.read_short
		actor.revive_y = reader.read_short
		map_id = reader.read_short
		# Se o mapa ainda existir
		actor.map_id = $server.maps.has_key?(map_id) ? map_id : actor.revive_map_id
		actor.x = reader.read_short
		actor.y = reader.read_short
		actor.direction = reader.read_byte
		actor.gold = reader.read_int
		actor.items = {}
		size = reader.read_byte
		size.times do
			item_id = reader.read_short
			value = reader.read_short
			# Se o item ainda existir no banco de dados
			actor.items[item_id] = value if $data_items[item_id]
		end
		actor.weapons = {}
		size = reader.read_byte
		size.times do
			weapon_id = reader.read_short
			value = reader.read_short
			actor.weapons[weapon_id] = value if $data_weapons[weapon_id]
		end
		actor.armors = {}
		size = reader.read_byte
		size.times do
			armor_id = reader.read_short
			value = reader.read_short
			actor.armors[armor_id] = value if $data_armors[armor_id]
		end
		actor.skills = []
		size = reader.read_byte
		size.times { actor.skills << reader.read_short }
		actor.quests = {}
		size = reader.read_byte
		size.times do
			quest_id = reader.read_byte
			actor.quests[quest_id] = Game_Quest.new(quest_id, reader.read_byte, reader.read_short)
		end
		actor.hotbar = []
		Configs::MAX_HOTBAR.times do
			type = reader.read_byte
			item_id = reader.read_short
			type = item_id = 0 if type == Enums::Hotbar::ITEM && !$data_items[item_id] || type == Enums::Hotbar::SKILL && !$data_skills[item_id]
			actor.hotbar << Hotbar.new(type, item_id)
		end
		actor.switches = []
		Configs::MAX_PLAYER_SWITCHES.times { actor.switches << reader.read_boolean }
		actor.variables = []
		Configs::MAX_PLAYER_VARIABLES.times { actor.variables << reader.read_short }
		actor.self_switches = {}
		size = reader.read_short
		size.times do
			key = [reader.read_short, reader.read_short, reader.read_string]
			actor.self_switches[key] = reader.read_boolean
		end
		actor
	end
	
	def self.save_player(actor)
		writer = Binary_Writer.new
		writer.write_string(actor.user)
		writer.write_string(actor.character_name)
		writer.write_byte(actor.character_index)
		writer.write_string(actor.face_name)
		writer.write_byte(actor.face_index)
		writer.write_short(actor.class_id)
		writer.write_byte(actor.sex)
		writer.write_short(actor.level)
		writer.write_int(actor.exp)
		writer.write_int(actor.hp)
		writer.write_int(actor.mp)
		actor.param_base.each { |param| writer.write_int(param) }
		actor.equips.each { |equip| writer.write_short(equip) }
		writer.write_short(actor.points)
		writer.write_string(actor.guild)
		writer.write_short(actor.revive_map_id)
		writer.write_short(actor.revive_x)
		writer.write_short(actor.revive_y)
		writer.write_short(actor.map_id)
		writer.write_short(actor.x)
		writer.write_short(actor.y)
		writer.write_byte(actor.direction)
		writer.write_int(actor.gold)
		writer.write_byte(actor.items.size)
		actor.items.each do |item_id, amount|
			writer.write_short(item_id)
			writer.write_short(amount)
		end
		writer.write_byte(actor.weapons.size)
		actor.weapons.each do |weapon_id, amount|
			writer.write_short(weapon_id)
			writer.write_short(amount)
		end
		writer.write_byte(actor.armors.size)
		actor.armors.each do |armor_id, amount|
			writer.write_short(armor_id)
			writer.write_short(amount)
		end
		writer.write_byte(actor.skills.size)
		actor.skills.each { |skill| writer.write_short(skill) }
		writer.write_byte(actor.quests.size)
		actor.quests.each do |quest_id, quest|
			writer.write_byte(quest_id)
			writer.write_byte(quest.state)
			writer.write_short(quest.kills)
		end
		actor.hotbar.each do |hotbar|
			writer.write_byte(hotbar.type)
			writer.write_short(hotbar.item_id)
		end
		actor.switches.each { |switch| writer.write_boolean(switch) }
		actor.variables.each { |variable| writer.write_short(variable) }
		writer.write_short(actor.self_switches.size)
		actor.self_switches.each do |key, value|
			writer.write_short(key[0])
			writer.write_short(key[1])
			writer.write_string(key[2])
			writer.write_boolean(value)
		end
		file = File.open("Data/Players/#{actor.name}.bin", mode: 'wb')
		file.write(writer.to_s)
		file.close
	end

	def self.player_exist?(name)
		File.exist?("Data/Players/#{name}.bin")
	end

	def self.remove_player(name)
		File.delete("Data/Players/#{name}.bin")
	end

	def self.load_bank(client)
		return unless File.exist?("Data/Banks/#{client.user}.bin")
		reader = Binary_Reader.new(File.read("Data/Banks/#{client.user}.bin", mode: 'rb'))
		client.bank_gold = reader.read_int
		size = reader.read_byte
		size.times { client.bank_items[reader.read_short] = reader.read_short }
		size = reader.read_byte
		size.times { client.bank_weapons[reader.read_short] = reader.read_short }
		size = reader.read_byte
		size.times { client.bank_armors[reader.read_short] = reader.read_short }
	end

	def self.save_bank(client)
		writer = Binary_Writer.new
		writer.write_int(client.bank_gold)
		writer.write_byte(client.bank_items.size)
		client.bank_items.each do |item_id, amount|
			writer.write_short(item_id)
			writer.write_short(amount)
		end
		writer.write_byte(client.bank_weapons.size)
		client.bank_weapons.each do |weapon_id, amount|
			writer.write_short(weapon_id)
			writer.write_short(amount)
		end
		writer.write_byte(client.bank_armors.size)
		client.bank_armors.each do |armor_id, amount|
			writer.write_short(armor_id)
			writer.write_short(amount)
		end
		file = File.open("Data/Banks/#{client.user}.bin", mode: 'wb')
		file.write(writer.to_s)
		file.close
	end

end
