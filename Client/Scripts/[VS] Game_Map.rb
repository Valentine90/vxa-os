#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  Esta classe lida com a atualização dos eventos, eventos
# comuns e jogadores do mapa.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Map
  
  attr_reader   :pvp, :players, :drops, :projectiles
  
  def in_screen?(object_x, object_y = nil)
    unless object_y
      object = object_x
      object_x = object.x
      object_y = object.y
    end
    return false if object_x <= @display_x - 4
    return false if object_x >= @display_x + screen_tile_x + 3
    return false if object_y <= @display_y - 4
    return false if object_y >= @display_y + screen_tile_y + 3
    return true
  end
  
  def pvp?
    Note.read_boolean('PvP', @map.note)
  end
  
  def refresh
    @events.each_value(&:refresh)
    $windows[:minimap].refresh if $windows.has_key?(:minimap)
    refresh_tile_events
    @need_refresh = false
  end
  
  def update_events
    @players.each_value { |player| player.update if in_screen?(player) }
    @events.each_value { |event| event.update if need_update?(event) }
  end
  
  def need_update?(event)
    return false if event.event.name == 'notupdate'
    # Executa os comandos chamados no handle_event_command
    #dos eventos com condição de início processo paralelo
    #ou início automático
    return true if event.trigger == 3
    return true if event.trigger == 4
    return in_screen?(event)
  end
  
end
