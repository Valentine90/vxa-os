#==============================================================================
# ** Enums
#------------------------------------------------------------------------------
#  Este módulo lida com as enumerações.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Enums

	# Equipamentos
	Equip = enum %w(
		WEAPON
		SHIELD
		HELMET
		ARMOR
		ACESSORY
		AMULET
		COVER
		GLOVE
		BOOT
	)
	
	# Parâmetros
	Param = enum %w(
		MAXHP
		MAXMP
		ATK
		DEF
		MAT
		MDF
		AGI
		LUK
	)

	# Escopos dos itens
	module Item
		SCOPE_ENEMY              = 1
		SCOPE_ALL_ALLIES         = 8
		SCOPE_ALLIES_KNOCKED_OUT = 10
		SCOPE_USER               = 11
	end

	# Movimentos dos eventos
	Move = enum %w(
		FIXED
		RANDOM
		TOWARD_PLAYER
		CUSTOM
	)

end
