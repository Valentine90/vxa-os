#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  Esta classe lida com o evento.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Event

	include Game_Character, Game_Battler, Game_Enemy, Game_MoveEvent

	attr_reader   :id
	attr_reader   :hp
	# Permite a alteração de self.mp, nos casos em que seu valor seja acrescido ou
	#diminuído, a partir da leitura do valor original de mp
	attr_reader   :mp
	attr_reader   :target
	attr_reader   :tile_id
	attr_reader   :map_id
	attr_reader   :x
	attr_reader   :y
	attr_reader   :direction
	attr_writer   :parallel_process_waiting
	
	def initialize(id, event, map_id)
		@id = id
		@map_id = map_id
		@x = event.x
		@y = event.y
		@pages = event.pages
		@target = Target.new
		@move_succeed = true
		@move_route_forcing = false
		@parallel_process_waiting = nil
		@locked = []
		clear_enemy
		clear_target
		clear_states
		clear_buffs
		refresh
	end

	def enemy?
		@enemy_id > 0
	end

	def in_battle?
		@target.id >= 0
	end
	
	def erased?
		enemy? && dead?
	end

	def enemy
		$data_enemies[@enemy_id]
	end

	def lock(client)
		@prelock_direction = @direction if @locked.empty?
		turn_toward_character(client)
		@locked << client.id
	end

	def unlock(client_id)
		return unless @locked.include?(client_id)
		@locked.delete(client_id)
		if @locked.empty?
			@direction = @prelock_direction
			send_movement
		end
	end

	def clear_enemy
		@action_time = Time.now + Configs::ATTACK_TIME
		@revive_time = Time.now
		@escape = false
		@hp = 0
		@sight = 10
	end

	def refresh
		new_page = find_global_proper_page
		# Executa o clear_page_settings se não tiver página e a atualização
		#estiver ocorrendo ao instânciar a classe
		setup_page(new_page) if !new_page || new_page != @page
		@stop_count = Time.now + rand(@stop_count_threshold)
	end

	def setup_page(new_page)
		@page = new_page
		if @page
			setup_page_settings
		else
			clear_page_settings
		end
	end
	
	def clear_page_settings
		@character_index = 0
		@tile_id = 0
		@direction = Enums::Dir::DOWN
		@move_type = 0
		@move_frequency = 3
		@through = true
		@trigger = nil
		@list = nil
		@interpreter = nil
		@enemy_id = 0
		@stop_count_threshold = 1
		@battle_stop_count_threshold = 1
		clear_enemy
		clear_target
	end

	def setup_page_settings
		@character_index = @page.graphic.character_index
		@tile_id = @page.graphic.tile_id
		@direction = @page.graphic.direction
		@move_type = @page.move_type
		@move_frequency = @page.move_frequency
		@move_route = @page.move_route
		@move_route_index = 0
		@move_route_forcing = false
		@through = @page.through
		@priority_type = @page.priority_type
		@trigger = @page.trigger
		@list = @page.list
		@interpreter = @trigger == 4 ? Game_Interpreter.new : nil
		@enemy_id, @frequency_battle, @region_id = battle_parameters
		@stop_count_threshold = stop_count_threshold / 40
		@battle_stop_count_threshold = battle_stop_count_threshold / 40
		if enemy?
			setup_enemy_settings
		# Se o inimigo agora é um evento
		else
			clear_enemy
			clear_target
		end
	end

	def setup_enemy_settings
		@param_base = $data_enemies[@enemy_id].params
		@sight = $data_enemies[@enemy_id].sight
		@escape = $data_enemies[@enemy_id].escape
		@hp = mhp
		@mp = mmp
	end

	def battle_parameters
		if @list[0].code == 108 && @list[0].parameters[0].start_with?('Enemy')
			enemy_id = @list[0].parameters[0].split('=')[1].to_i
			frequency = @list[1].code == 408 ? @list[1].parameters[0].split('=')[1].to_i : @move_frequency
			region_id = @list[2] && @list[2].code == 408 ? @list[2].parameters[0].split('=')[1].to_i : 1
			return enemy_id, frequency, region_id
		end
		return 0, 0, 0
	end

	def collide_with_characters?(x, y)
		super || collide_with_players?(x, y)
	end
	
	def stop_count_threshold
		30 * (5 - @move_frequency)
	end

	def battle_stop_count_threshold
		30 * (5 - @frequency_battle)
	end
	
	def find_proper_page(client)
		@pages.reverse.find { |page| conditions_met?(client, page) }
	end

	def conditions_met?(client, page)
		c = page.condition
		if c.switch1_valid
			return false unless client.switches[c.switch1_id] || $network.switches[c.switch1_id] && c.switch1_id > Configs::MAX_PLAYER_SWITCHES
		end
		if c.switch2_valid
			return false unless client.switches[c.switch2_id] || $network.switches[c.switch2_id] && c.switch2_id > Configs::MAX_PLAYER_SWITCHES
		end
		if c.variable_valid
			return false if client.variables[c.variable_id] < c.variable_value
		end
		if c.self_switch_valid
			key = [client.map_id, @id, c.self_switch_ch]
			return false unless client.self_switches[key]
		end
		if c.item_valid
			return false unless client.actor.items[c.item_id]
		end
		return page
	end

	def find_global_proper_page
		@pages.reverse.find { |page| global_conditions_met?(page) }
	end

	def global_conditions_met?(page)
		c = page.condition
		if c.switch1_valid
			return false unless $network.switches[c.switch1_id] && c.switch1_id > Configs::MAX_PLAYER_SWITCHES
		end
		if c.switch2_valid
			return false unless $network.switches[c.switch2_id] && c.switch2_id > Configs::MAX_PLAYER_SWITCHES
		end
		return true
	end

	def check_event_trigger_touch(x, y)
		return unless @trigger == 2
		$network.clients.each do |client|
			next unless client&.in_game? || client.map_id == @map_id || client.pos?(x, y) || normal_priority? || !client.event_interpreter.running?
			start(client)
			break
		end
	end

	def update
		update_self_movement unless @move_route_forcing
		update_enemy if enemy?
		update_parallel_process
	end
	
	def update_self_movement
		return if erased? || @stop_count > Time.now || !@locked.empty?
		@stop_count = Time.now + (in_battle? ? @battle_stop_count_threshold : @stop_count_threshold)
		if @move_type == Enums::Move::FIXED && enemy?
			select_target
		elsif @move_type == Enums::Move::RANDOM && !in_battle?
			move_random
		elsif @move_type == Enums::Move::TOWARD_PLAYER || in_battle?
			move_type_toward_player
		end
	end
	
	def select_target
		return if $network.maps[@map_id].zero_players?
		target = get_target
		target = find_target unless near_the_player?(target)
		if target
			@target.id = target.id
		else
			clear_target
		end
	end

	def move_type_toward_player
		if $network.maps[@map_id].zero_players?
			# Se o alvo, único jogador do mapa, saiu do jogo ou do mapa
			clear_target
			move_random
			return
		end
		target = get_target
		target = find_target unless near_the_player?(target)
		unless target
			clear_target
			move_random
			return
		end
		@target.id = target.id
		if @escape && @hp < mhp / 3
			move_away_from_character(target)
		else
			move_toward_character(target)
		end
	end

	def near_the_player?(target)
		# Aumenta o alcance para seguir jogadores que atacam com armas de longa distância
		target && valid_target?(target) && in_range?(target, @sight + 5)
	end

	def send_movement
		$network.send_event_movement(self)
	end

	def find_target
		target = $network.clients.find { |client| client&.in_game? && client.map_id == @map_id && in_range?(client, @sight) }
		$network.send_enemy_balloon(target, @id, ENEMY_ATTACK_BALLOON_ID) if target && ENEMY_ATTACK_BALLOON_ID > 0
		target
	end

	def update_parallel_process
		return unless @interpreter
		if @parallel_process_waiting && Time.now >= @parallel_process_waiting.time
			# Limpa o processo paralelo de espera, o qual poderá ser eventualmente preenchido,
			#após a execução do resume, se houver outro Esperar no restante da lista
			@parallel_process_waiting = nil
			@interpreter.fiber.resume
		elsif !@parallel_process_waiting
			@interpreter.setup(nil, @list, @id, self)
		end
	end

	def empty?(list)
		!list || list.size <= 1
	end

	def trigger_in?(triggers)
		triggers.include?(@trigger)
	end

	def start(client)
		page = find_proper_page(client)
		return if !page || empty?(page.list)
		lock(client) if trigger_in?([0, 1, 2])
		client.event_interpreter.setup(client, page.list, @id)
	end

end
