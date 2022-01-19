#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Este script lida com o grupo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Party

	attr_accessor :party_id
	
	def party_members_in_map
		$network.parties[@party_id].select { |member| member.map_id == @map_id }
	end

	def party_share(exp, gold, enemy_id)
		party_members = party_members_in_map
		# Primeiro ganha o ouro, depois ganha o item da missão e o exibe na Sprite_Popup
		party_share_gold(gold, party_members)
		party_share_exp(exp, enemy_id, party_members)
	end

	def party_share_exp(exp, enemy_id, party_members)
		# Se o número de membros do grupo é superior à experiência ou o
		#jogador é o único membro do grupo no mapa
		if party_members.size > exp || party_members.size == 1
			# Converte eventual resultado decimal do bônus de experiência em inteiro
			gain_exp((exp * vip_exp_bonus).to_i)
			add_kills_count(enemy_id)
    	return
		end
		exp_share = exp / party_members.size + (exp * PARTY_BONUS[party_members.size] / 100)
		dif_exp = exp - (exp / party_members.size) * party_members.size
		party_members.each do |member|
			member.gain_exp(member == self ? (exp_share * member.vip_exp_bonus + dif_exp).to_i : (exp_share * member.vip_exp_bonus).to_i)
			member.add_kills_count(enemy_id)
		end
	end

	def party_share_gold(gold, party_members)
		if party_members.size > gold || party_members.size == 1
			gain_gold((gold * gold_rate * vip_gold_bonus).to_i, false, true)
			return
		end
		gold_share = gold / party_members.size + (gold * PARTY_BONUS[party_members.size] / 100)
		party_members.each { |member| member.gain_gold((gold_share * member.gold_rate * member.vip_gold_bonus).to_i, false, true) }
	end
	
	def item_party_recovery(item)
		unless in_party?
			item_recover(item)
			return
		end
		party_members_in_map.each { |member| member.item_recover(item) if in_range?(member, item.range) }
  end
  
	def accept_party
		return if in_party?
		if $network.clients[@request.id].in_party?
			return if $network.parties[$network.clients[@request.id].party_id].size >= Configs::MAX_PARTY_MEMBERS
    	@party_id = $network.clients[@request.id].party_id
  	else
			create_party
		end
		$network.parties[@party_id].each do |member|
			$network.send_join_party(member, self)
			$network.send_join_party(self, member)
		end
		$network.parties[@party_id] << self
	end
	
	def create_party
		@party_id = $network.find_empty_party_id
		$network.clients[@request.id].party_id = @party_id
		$network.parties[@party_id] = [$network.clients[@request.id]]
	end

	def leave_party
		return unless in_party?
		$network.send_dissolve_party(self)
		$network.parties[@party_id].delete(self)
		if $network.parties[@party_id].size == 1
			dissolve_party($network.parties[@party_id].first)
		else
			$network.send_leave_party(self)
		end
		@party_id = -1
	end

	def dissolve_party(party_member)
		$network.parties[@party_id] = nil
		$network.party_ids_available << @party_id
		$network.send_dissolve_party(party_member)
		party_member.party_id = -1
	end

end
