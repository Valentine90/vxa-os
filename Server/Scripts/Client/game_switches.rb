#==============================================================================
# ** Game_Switches
#------------------------------------------------------------------------------
#  Esta classe gerencia as switches, as variáveis e as switches locais.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Switches

  attr_reader   :data

  def initialize(client, data)
    @client = client
    @data = data
  end

  def [](switch_id)
    @data[switch_id - 1]
  end

  def []=(switch_id, value)
    @data[switch_id - 1] = value
    $network.send_player_switch(@client, switch_id)
  end

end

#==============================================================================
# ** Game_Variables
#==============================================================================
class Game_Variables

  attr_reader   :data

  def initialize(client, data)
    @client = client
    @data = data
  end

  def [](variable_id)
    @data[variable_id - 1]
  end

  def []=(variable_id, value)
    @data[variable_id - 1] = value
    $network.send_player_variable(@client, variable_id)
  end

end

#==============================================================================
# ** Game_SelfSwitches
#==============================================================================
class Game_SelfSwitches

  attr_reader   :data

  def initialize(client, data)
    @client = client
    @data = data
  end

  def [](key)
    @data[key] == true
  end

  def []=(key, value)
    @data[key] = value
    $network.send_player_self_switch(@client, key)
  end

end

#==============================================================================
# ** Game_GlobalSwitches
#==============================================================================
class Game_GlobalSwitches

  attr_reader   :data

  def initialize(data = [])
    @data = data
  end

  def [](switch_id)
    @data[switch_id - Configs::MAX_PLAYER_SWITCHES - 1] || false
  end

  def []=(switch_id, value)
    @data[switch_id - Configs::MAX_PLAYER_SWITCHES - 1] = value
		$network.send_global_switch(switch_id, value)
		# Atualiza enemy_id dos eventos
		$network.maps.each_value(&:refresh)
  end

end
