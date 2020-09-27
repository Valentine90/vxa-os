#==============================================================================
# ** Game_Actors
#------------------------------------------------------------------------------
#  Esta classe gerencia a lista de heróis.
# A instância desta classe é referenciada por $game_actors.
#==============================================================================

class Game_Actors
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Aquisição da informação do herói
  #     actor_id : ID do herói
  #--------------------------------------------------------------------------
  def [](actor_id)
    return nil unless $data_actors[actor_id]
    @data[actor_id] ||= Game_Actor.new(actor_id)
  end
end
