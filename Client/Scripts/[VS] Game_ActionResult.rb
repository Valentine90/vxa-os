#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  Esta classe lida com os resultados das ações nos combates.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_ActionResult
  
  attr_writer   :level_up
  attr_accessor :exp
  
  def clear_hit_flags
    @used = false
    @missed = false
    @evaded = false
    @critical = false
    @success = false
    @level_up = false
  end
  
  def clear_damage_values
    @hp_damage = nil
    @mp_damage = 0
    @tp_damage = 0
    @hp_drain = 0
    @mp_drain = 0
    @exp = 0
  end
  
  def success?
    # Se causou dano de HP ou de MP, subiu nível ou
    #ganhou experiência
    @hp_damage || level_up? || gain_exp?
  end
  
  def critical?
    @critical
  end
  
  def level_up?
    @level_up
  end
  
  def gain_exp?
    @exp > 0
  end
  
end
