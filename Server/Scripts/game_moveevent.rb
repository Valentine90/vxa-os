#==============================================================================
# ** Game_MoveEvent
#------------------------------------------------------------------------------
#  Esta classe lida com o movimento do evento.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_MoveEvent

	def move_random
		move_straight(rand(4) * 2 + 2, false)
  end
  
	def move_toward_character(character)
		return if in_front?(character)
		sx = distance_x_from(character.x)
		sy = distance_y_from(character.y)
		if sx.abs > sy.abs
			move_straight(sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT)
			move_straight(sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN) if !@move_succeed && sy != 0
		else
			move_straight(sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN)
			move_straight(sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT) if !@move_succeed && sx != 0
		end
	end

	def move_away_from_character(character)
		sx = distance_x_from(character.x)
		sy = distance_y_from(character.y)
		if sx.abs > sy.abs
			move_straight(sx > 0 ? Enums::Dir::RIGHT : Enums::Dir::LEFT)
			move_straight(sy > 0 ? Enums::Dir::DOWN : Enums::Dir::UP) if !@move_succeed && sy != 0
		else
			move_straight(sy > 0 ? Enums::Dir::DOWN : Enums::Dir::UP)
			move_straight(sx > 0 ? Enums::Dir::RIGHT : Enums::Dir::LEFT) if !@move_succeed && sx != 0
		end
	end

	def turn_toward_character(character)
		sx = distance_x_from(character.x)
		sy = distance_y_from(character.y)
		if sx.abs > sy.abs
			@direction = sx > 0 ? Enums::Dir::LEFT : Enums::Dir::RIGHT
			send_movement
		elsif sy != 0
			@direction = sy > 0 ? Enums::Dir::UP : Enums::Dir::DOWN
			send_movement
		end
	end

end
