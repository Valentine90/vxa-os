#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  Esta é a superclasse de Game_Client e Game_Event.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Character

	FEATURE_ELEMENT_RATE  = 11
	FEATURE_DEBUFF_RATE   = 12
	FEATURE_STATE_RATE    = 13
	FEATURE_STATE_RESIST  = 14
	FEATURE_PARAM         = 21
	FEATURE_XPARAM        = 22
	FEATURE_SPARAM        = 23
	FEATURE_ATK_ELEMENT   = 31
	FEATURE_ATK_STATE     = 32
	FEATURE_STYPE_ADD     = 41
	FEATURE_STYPE_SEAL    = 42
	FEATURE_SKILL_ADD     = 43
	FEATURE_SKILL_SEAL    = 44
	FEATURE_EQUIP_WTYPE   = 51
	FEATURE_EQUIP_ATYPE   = 52
	FEATURE_EQUIP_FIX     = 53
	FEATURE_EQUIP_SEAL    = 54
	FEATURE_SLOT_TYPE     = 55
	FEATURE_SPECIAL_FLAG  = 62
	FEATURE_PARTY_ABILITY = 64

	FLAG_ID_GUARD = 1

	# Evita um erro no make_damage_value quando o inimigo ataca e permite
	#a leitura das variáveis do jogador
	attr_reader   :variables
	attr_accessor :direction

	def mhp; param(0);  end
	def mmp; param(1);  end
	def atk; param(2);  end
	def def; param(3);  end
	def mat; param(4);  end
	def mdf; param(5);  end
	def agi; param(6);  end
	def luk; param(7);  end
	def hit; xparam(0); end
	def eva; xparam(1); end
	def cri; xparam(2); end
	def cev; xparam(3); end
	def mev; xparam(4); end
	def grd; sparam(1); end
	def rec; sparam(2); end
	def pha; sparam(3); end
  def pdr; sparam(6); end
  def mdr; sparam(7); end
	def fdr; sparam(8); end

  def clear_states
		@states = []
	end

  def clear_buffs
    @buffs = Array.new(8, 0)
  end

  def state?(state_id)
    @states.include?(state_id)
	end

  def death_state?
  	state?(death_state_id)
  end
	
	def add_state(state_id)
		return if !state_addable?(state_id) || state?(state_id)
		add_new_state(state_id)
	end

	def state_addable?(state_id)
		!death_state? && $data_states[state_id] && !state_resist?(state_id) && !state_restrict?(state_id)
	end

  def state_restrict?(state_id)
    $data_states[state_id].remove_by_restriction && restriction > 0
  end

	def add_new_state(state_id)
		die if state_id == death_state_id
		@states << state_id
		on_restrict if restriction > 0
	end

	def on_restrict
		states.each { |state| remove_state(state.id) if state.remove_by_restriction }
	end

	def remove_state(state_id)
		return unless state?(state_id)
		@states.delete(state_id)
	end

	def add_buff(param_id)
		return if death_state?
		@buffs[param_id] += 1 unless buff_max?(param_id)
		erase_buff(param_id) if debuff?(param_id)
		refresh
	end

	def add_debuff(param_id)
		return if death_state?
		@buffs[param_id] -= 1 unless debuff_max?(param_id)
		erase_buff(param_id) if buff?(param_id)
		refresh
	end

	def remove_buff(param_id)
		return if death_state? || @buffs[param_id] == 0
		erase_buff(param_id)
		refresh
	end

	def erase_buff(param_id)
		@buffs[param_id] = 0
	end

	def buff?(param_id)
		@buffs[param_id] > 0
	end

	def debuff?(param_id)
		@buffs[param_id] < 0
	end

	def buff_max?(param_id)
		@buffs[param_id] == 2
	end

	def debuff_max?(param_id)
		@buffs[param_id] == -2
	end

  def remove_states_by_damage
    states.each { |state| remove_state(state.id) if state.remove_by_damage && rand(100) < state.chance_by_damage }
  end

  def states
    @states.collect { |id| $data_states[id] }
  end

  def all_features
    feature_objects.inject([]) { |r, obj| r + obj.features }
  end

  def features(code)
    all_features.select { |ft| ft.code == code }
	end
	
  def features_with_id(code, id)
    all_features.select { |ft| ft.code == code && ft.data_id == id }
  end

  def features_pi(code, id)
    features_with_id(code, id).inject(1.0) { |r, ft| r *= ft.value }
	end
	
  def features_sum(code, id)
    features_with_id(code, id).inject(0.0) { |r, ft| r += ft.value }
  end

  def features_set(code)
    features(code).inject([]) { |r, ft| r |= [ft.data_id] }
	end

	def add_param(param_id, value)
		@param_base[param_id] += value
	end

	def param_plus(param_id)
		0
	end
	
	def param_min(param_id)
		param_id == Enums::Param::MAXMP ? 0 : 1
	end

  def param_rate(param_id)
    features_pi(FEATURE_PARAM, param_id)
	end
	
  def param_buff_rate(param_id)
    @buffs[param_id] * 0.25 + 1.0
  end

	def param(param_id)
		value = @param_base[param_id] + param_plus(param_id)
		value *= param_rate(param_id) * param_buff_rate(param_id)
		[[value, Configs::MAX_PARAMS].min, param_min(param_id)].max.to_i
	end

  def xparam(xparam_id)
    features_sum(FEATURE_XPARAM, xparam_id)
  end

  def sparam(sparam_id)
    features_pi(FEATURE_SPARAM, sparam_id)
	end
	
  def element_rate(element_id)
    features_pi(FEATURE_ELEMENT_RATE, element_id)
	end

	def debuff_rate(param_id)
		features_pi(FEATURE_DEBUFF_RATE, param_id)
	end

  def state_rate(state_id)
    features_pi(FEATURE_STATE_RATE, state_id)
  end

  def state_resist_set
    features_set(FEATURE_STATE_RESIST)
  end

  def state_resist?(state_id)
  	state_resist_set.include?(state_id)
  end
	
  def atk_elements
    features_set(FEATURE_ATK_ELEMENT)
	end
	
  def atk_states
    features_set(FEATURE_ATK_STATE)
	end
	
  def atk_states_rate(state_id)
    features_sum(FEATURE_ATK_STATE, state_id)
	end
	
	def added_skill_types
		features_set(FEATURE_STYPE_ADD)
	end

  def skill_type_sealed?(stype_id)
    features_set(FEATURE_STYPE_SEAL).include?(stype_id)
	end
	
	def added_skills
		features_set(FEATURE_SKILL_ADD)
	end

  def skill_sealed?(skill_id)
    features_set(FEATURE_SKILL_SEAL).include?(skill_id)
	end

	def equip_wtype_ok?(wtype_id)
		features_set(FEATURE_EQUIP_WTYPE).include?(wtype_id)
	end

	def equip_atype_ok?(atype_id)
		features_set(FEATURE_EQUIP_ATYPE).include?(atype_id)
	end
	
	def equip_type_fixed?(etype_id)
		features_set(FEATURE_EQUIP_FIX).include?(etype_id)
	end

	def equip_type_sealed?(etype_id)
		features_set(FEATURE_EQUIP_SEAL).include?(etype_id)
	end
	
  def slot_type
  	features_set(FEATURE_SLOT_TYPE).max || 0
	end
	
	def dual_wield?
		slot_type == 1
	end

  def special_flag(flag_id)
    features(FEATURE_SPECIAL_FLAG).any? { |ft| ft.data_id == flag_id }
	end

  def party_ability(ability_id)
    features(FEATURE_PARTY_ABILITY).any? { |ft| ft.data_id == ability_id }
  end
	
  def guard?
    special_flag(FLAG_ID_GUARD) && restriction < 4
  end

	def hp=(hp)
		@hp = [[hp, mhp].min, 0].max
		# Se o inimigo morreu
		die if dead?
	end

	def mp=(mp)
		@mp = [[mp, mmp].min, 0].max
	end

	def hp_rate
		@hp.to_f / mhp
	end

	def mp_rate
		mmp > 0 ? @mp.to_f / mmp : 0
	end

	def refresh
		@hp = [[@hp, mhp].min, 0].max
		@mp = [[@mp, mmp].min, 0].max
	end

	def dead?
		@hp <= 0
	end

	def pos?(x, y)
		@x == x && @y == y
	end

	def pos_nt?(x, y)
		pos?(x, y) && !@through
	end

	def normal_priority?
		@priority_type == 1
	end

	def reverse_dir(d)
		10 - d
	end

	def passable?(x, y, d)
		x2 = $network.maps[@map_id].round_x_with_direction(x, d)
		y2 = $network.maps[@map_id].round_y_with_direction(y, d)
		return false unless $network.maps[@map_id].valid?(x2, y2)
		return true if @through
		return false unless $network.maps[@map_id].passable?(x2, y2, reverse_dir(d))
		return false if collide_with_characters?(x2, y2)
		return true
	end

  def diagonal_passable?(x, y, horz, vert)
    x2 = $network.maps[@map_id].round_x_with_direction(x, horz)
    y2 = $network.maps[@map_id].round_y_with_direction(y, vert)
    (passable?(x, y, vert) && passable?(x, y2, horz)) ||
    (passable?(x, y, horz) && passable?(x2, y, vert))
  end
	
	def collide_with_characters?(x, y)
		collide_with_events?(x, y)
	end

	def collide_with_events?(x, y)
		$network.maps[@map_id].events_xy_nt(x, y).any? { |event| event.normal_priority? && !event.erased? }
	end

	def collide_with_players?(x, y)
		$network.clients.any? { |client| client&.in_game? && client.map_id == @map_id && client.pos_nt?(x, y) }
	end

	def moveto(x, y)
		@x = x
		@y = y
		send_movement
	end

	def tile?
		@tile_id > 0 && @priority_type == 0
	end

	def check_event_trigger_touch_front
		x2 = $network.maps[@map_id].round_x_with_direction(@x, @direction)
		y2 = $network.maps[@map_id].round_y_with_direction(@y, @direction)
		check_event_trigger_touch(x2, y2)
	end

	def move_straight(d, turn_ok = true)
		@move_succeed = passable?(@x, @y, d)
		if @move_succeed
			@direction = d
			@x = $network.maps[@map_id].round_x_with_direction(@x, d)
			@y = $network.maps[@map_id].round_y_with_direction(@y, d)
			# Muda a direção para 8, se o jogador, após a mudança acima de suas
			#coordendas @x e @y, estiver em uma escada
			@direction = 8 if $network.maps[@map_id].ladder?(@x, @y)
			send_movement
		elsif turn_ok
			@direction = d
			send_movement
			check_event_trigger_touch_front
		end
	end

	def move_diagonal(d)
    if d < 7
      horz = d + 3
      vert = 2
    else
      horz = d - 3
      vert = 8
    end
    @move_succeed = diagonal_passable?(x, y, horz, vert)
    if @move_succeed
      @x = $network.maps[@map_id].round_x_with_direction(@x, horz)
			@y = $network.maps[@map_id].round_y_with_direction(@y, vert)
			@direction = 8 if $network.maps[@map_id].ladder?(@x, @y)
    end
    @direction = horz if @direction == reverse_dir(horz)
		@direction = vert if @direction == reverse_dir(vert)
		send_movement
  end
	
	def restriction
		states.collect(&:restriction).push(0).max
	end

	def skill_learn?(skill_id)
		true
	end

	def skill_wtype_ok?(skill)
		true
	end

	def added_skill_type?(skill)
		true
	end

	def usable_item_conditions_met?(item)
		restriction < 4 && item.occasion < 3
	end

	def skill_conditions_met?(skill)
		(skill_learn?(skill.id) || added_skills.include?(skill.id)) && usable_item_conditions_met?(skill) &&
		mp >= skill.mp_cost && skill_wtype_ok?(skill) && !skill_sealed?(skill.id) &&
		!skill_type_sealed?(skill.stype_id) && added_skill_type?(skill)
	end

	def item_conditions_met?(item)
		usable_item_conditions_met?(item) && has_item?(item)
	end

	def usable?(item)
		return skill_conditions_met?(item) if item.is_a?(RPG::Skill)
		return item_conditions_met?(item) if item.is_a?(RPG::Item)
		return false
	end

	def attack_skill_id
		1
	end

	def guard_skill_id
		2
	end

  def death_state_id
    1
  end

  def distance_x_from(x)
    @x - x
  end

  def distance_y_from(y)
    @y - y
	end

	def swap(character)
		new_x = character.x
		new_y = character.y
		character.moveto(@x, @y)
		moveto(new_x, new_y)
	end

end
