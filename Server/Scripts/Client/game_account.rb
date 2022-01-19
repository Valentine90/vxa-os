#==============================================================================
# ** Game_Account
#------------------------------------------------------------------------------
#  Este script lida com a conta.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Account

  attr_reader   :id
	attr_reader   :ip
	attr_reader   :actor_id
	attr_reader   :id_db
	attr_writer   :handshake
	attr_writer   :inactivity_time
	attr_accessor :account_id_db
  attr_accessor :user
  attr_accessor :pass
	attr_accessor :group
	attr_accessor :added_vip_time
	attr_accessor :vip_time
	attr_accessor :actors
	attr_accessor :friends
	attr_accessor :online_friends_size

  def init_account
		@id = -1
		@user = ''
		@pass = ''
		@group = 0
		# Define o tempo vip adicionado como 0, pois esta variável também é chamada
		#antes de o jogador entrar no jogo, no método vip?, que, por sua vez, é
		#chamado no método max_classes ao criar personagem
		@added_vip_time = 0
		@actor_id = -1
		@actors = {}
		@vip_time = nil
		@handshake = false
		@hand_time = Time.now + AUTHENTICATION_TIME
		@ip = Socket.unpack_sockaddr_in(get_peername)[1]
  end

	def connected?
		@id >= 0
	end

	def logged?
		!@user.empty?
	end

	def in_game?
		@actor_id >= 0
	end
	
	def standard?
		@group == Enums::Group::STANDARD
	end
	
	def admin?
		@group == Enums::Group::ADMIN
	end

	def monitor?
		@group == Enums::Group::MONITOR
	end

	def vip?
		@vip_time + @added_vip_time > Time.now
	end

  def max_classes
    vip? ? Configs::MAX_VIP_CLASSES : Configs::MAX_DEFAULT_CLASSES
  end

	def actor
		@actors[@actor_id]
	end

	def add_vip_days(days)
		@added_vip_time += days * 86400
		$network.player_chat_message(self, sprintf(AddVIPDays, days), Configs::SUCCESS_COLOR)
		$network.send_vip_days(self)
	end

	def accept_friend
		return unless $network.clients[@request.id]&.in_game?
		$network.clients[@request.id].add_friend(self)
		add_friend($network.clients[@request.id])
	end

	def add_friend(friend)
		return if @friends.size >= Configs::MAX_FRIENDS
		return if @friends.include?(friend.name)
		# Impede que o nome do amigo na lista de amigos seja
		#alterado quando @name dele ficar vazia no leave_game
		@friends.insert(@online_friends_size, friend.name.clone)
		@online_friends_size += 1
		$network.send_add_friend(self, friend.name)
	end

	def remove_actor_guild(guild_name, name)
		return if guild_name.empty?
		if $network.guilds[guild_name].leader == name
			$network.remove_guild(guild_name)
		else
			$network.guilds[guild_name].members.delete(name)
		end
	end
	
	def post_init
		if $network.full_clients?
			$network.send_failed_login(self, Enums::Login::SERVER_FULL)
			puts("Cliente com IP #{@ip} tentou se conectar!")
			close_connection_after_writing
		elsif $network.banned?(@ip)
			$network.send_failed_login(self, Enums::Login::IP_BANNED)
			puts("Cliente com IP banido #{@ip} tentou se conectar!")
			close_connection_after_writing
		else
			@id = $network.find_empty_client_id
			$network.connect_client(self)
		end
	end

	def unbind
		if in_game?
			# Carrega o gráfico original fora do leave_game, assim como no def handle_logout,
			#que envia o send_logout antes de desconectar o jogador do jogo
			load_original_graphic
			leave_game
		end
		puts("#{@user} saiu.") if logged?
		$network.disconnect_client(@id) if connected?
	end

	def receive_data(data)
		# Limita a quantidade de bytes recebidos do cliente para evitar um
		#eventual aumento excessivo (intencional) de memória RAM do buffer
		return if data.size > 1024
		buffer = Buffer_Reader.new(data)
		count = 0
		until buffer.eof? || count == 25
			$network.handle_messages(self, buffer)
			count += 1
		end
	end

	def load_data(actor_id)
		# Impede que o nome do personagem na lista de personagens seja
		#alterado quando @name ficar vazia no leave_game
		@name = @actors[actor_id].name.clone
		@id_db = @actors[actor_id].id_db
		@character_name = @actors[actor_id].character_name
		@character_index = @actors[actor_id].character_index
		@face_name = @actors[actor_id].face_name
		@face_index = @actors[actor_id].face_index
		@class_id = @actors[actor_id].class_id
		@sex = @actors[actor_id].sex
		@level = @actors[actor_id].level
		@exp = @actors[actor_id].exp
		@hp = @actors[actor_id].hp
		@mp = @actors[actor_id].mp
		@param_base = @actors[actor_id].param_base
		@equips = @actors[actor_id].equips
		@points = @actors[actor_id].points
		# Se a guilda não foi deletada nem recriada com outros membros enquanto outro personagem
		#da mesma conta estava conectado, antes de o usuário voltar pra seleção de personagens
		@guild_name = $network.guilds.has_key?(@actors[actor_id].guild_name) && $network.member_in_guild?($network.guilds[@actors[actor_id].guild_name], @name) ? @actors[actor_id].guild_name : ''
		@revive_map_id = @actors[actor_id].revive_map_id
		@revive_x = @actors[actor_id].revive_x
		@revive_y = @actors[actor_id].revive_y
		@map_id = @actors[actor_id].map_id
		@x = @actors[actor_id].x
		@y = @actors[actor_id].y
		@direction = @actors[actor_id].direction
		@gold = @actors[actor_id].gold
		@items = @actors[actor_id].items
		@weapons = @actors[actor_id].weapons
		@armors = @actors[actor_id].armors
		@skills = @actors[actor_id].skills
		@quests = @actors[actor_id].quests
		@hotbar = @actors[actor_id].hotbar
		@switches = Game_Switches.new(self, @actors[actor_id].switches)
		@variables = Game_Variables.new(self, @actors[actor_id].variables)
		@self_switches = Game_SelfSwitches.new(self, @actors[actor_id].self_switches)
	end

	def join_game(actor_id)
		@actor_id = actor_id
		@recover_time = Time.now + RECOVER_TIME
		@global_antispam_time = Time.now
		@weapon_attack_time = Time.now
		@item_attack_time = Time.now
		@muted_time = Time.now
		@stop_count = Time.now
		@original_character_name = ''
		@original_face_name = ''
		@original_character_index = 0
		@original_face_index = 0
		@online_friends_size = 0
		@teleport_id = -1
		@party_id = -1
		@common_events = {}
		@parallel_events_waiting = {}
		@creating_guild = false
		@in_bank = false
		@message_interpreter = nil
		@waiting_event = nil
		@shop_goods = nil
		@choice = nil
		clear_target
		clear_request
		clear_states
		clear_buffs
	end
	
	def leave_game
		Database.save_player(self)
		# Retira da lista de clientes no jogo
		@actor_id = -1
		@event_interpreter.finalize if @event_interpreter.running?
		$network.maps[@map_id].total_players -= 1
		Database.change_whos_online(@id_db, :delete)
		$network.send_remove_player(@id, @map_id)
		clear_target_players(Enums::Target::PLAYER)
		@name.clear
		close_trade
		leave_party
	end
	
	def update_current_actor
		actor.character_name = @character_name
		actor.character_index = @character_index
		actor.face_name = @face_name
		actor.face_index = @face_index
		actor.class_id = @class_id
		actor.sex = @sex
		actor.level = @level
		actor.exp = @exp
		actor.hp = @hp
		actor.mp = @mp
		actor.param_base = @param_base
		actor.equips = @equips
		actor.points = @points
		actor.guild_name = @guild_name
		actor.revive_map_id = @revive_map_id
		actor.revive_x = @revive_x
		actor.revive_y = @revive_y
		actor.map_id = @map_id
		actor.x = @x
		actor.y = @y
		actor.direction = @direction
		actor.gold = @gold
		actor.items = @items
		actor.weapons = @weapons
		actor.armors = @armors
		actor.skills = @skills
		actor.quests = @quests
		actor.hotbar = @hotbar
		actor.switches = @switches.data
		actor.variables = @variables.data
		actor.self_switches = @self_switches.data
	end

	def update_menu
		close_connection if !@handshake && Time.now > @hand_time
		reached_inactivity if logged? && Time.now > @inactivity_time
	end

	def reached_inactivity
		$network.send_failed_login(self, Enums::Login::INACTIVITY)
		close_connection_after_writing
	end

end
