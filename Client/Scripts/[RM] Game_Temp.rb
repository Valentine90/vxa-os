#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  Esta classe gerencia dados temporários que não são salvos pelo jogo.
# A instância desta classe é referenciada por $game_temp.
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  #attr_reader   :common_event_id          # ID do evendo commun
  attr_accessor :fade_type                # Tipo de efeito de fade
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    #@common_event_id = 0
    @fade_type = 0
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de evento comum a ser iniciado
  #--------------------------------------------------------------------------
  def reserve_common_event(common_event_id)
    @common_event_id = common_event_id
  end
  #--------------------------------------------------------------------------
  # * Limpeza do evento comum
  #--------------------------------------------------------------------------
  def clear_common_event
    @common_event_id = 0
  end
  #--------------------------------------------------------------------------
  # * Definição de chamada de eventos comuns
  #--------------------------------------------------------------------------
  def common_event_reserved?
    @common_event_id > 0
  end
  #--------------------------------------------------------------------------
  # * Definição de evento comun
  #--------------------------------------------------------------------------
  def reserved_common_event
    $data_common_events[@common_event_id]
  end
=end
end
