#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  Esta classe gerencia os resultados das ações nos combates.
# Esta classe é usada internamente pela classe Game_Battler.
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :used                     # Flag de uso
  attr_accessor :missed                   # Flag de erro
  attr_accessor :evaded                   # Flag de esquiva
  attr_accessor :critical                 # Flag de crítico
  attr_accessor :success                  # Flag de sucesso
  attr_accessor :hp_damage                # Dano no HP
  attr_accessor :mp_damage                # Dano no MP
  attr_accessor :tp_damage                # Dano no TP
  attr_accessor :hp_drain                 # Derno de HP
  attr_accessor :mp_drain                 # Dreno de MP
  attr_accessor :added_states             # Estados adicionados
  attr_accessor :removed_states           # Estados removidos
  attr_accessor :added_buffs              # Fortalecimentos adicionados
  attr_accessor :added_debuffs            # Enfraquecimentos adicionados
  attr_accessor :removed_buffs            # Modificações removidas
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear
  end
  #--------------------------------------------------------------------------
  # * Limpeza
  #--------------------------------------------------------------------------
  def clear
    clear_hit_flags
    clear_damage_values
    clear_status_effects
  end
  #--------------------------------------------------------------------------
  # * Limpeza do flags de acerto
  #--------------------------------------------------------------------------
  def clear_hit_flags
    @used = false
    @missed = false
    @evaded = false
    @critical = false
    @success = false
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos danos
  #--------------------------------------------------------------------------
  def clear_damage_values
    @hp_damage = 0
    @mp_damage = 0
    @tp_damage = 0
    @hp_drain = 0
    @mp_drain = 0
  end
  #--------------------------------------------------------------------------
  # * Criação do dano
  #     value : valor do dano
  #     item  : objeto
  #--------------------------------------------------------------------------
  def make_damage(value, item)
    @critical = false if value == 0
    @hp_damage = value if item.damage.to_hp?
    @mp_damage = value if item.damage.to_mp?
    @mp_damage = [@battler.mp, @mp_damage].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    @hp_drain = [@battler.hp, @hp_drain].min
    @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos estados
  #--------------------------------------------------------------------------
  def clear_status_effects
    @added_states = []
    @removed_states = []
    @added_buffs = []
    @added_debuffs = []
    @removed_buffs = []
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de estados adicionados
  #--------------------------------------------------------------------------
  def added_state_objects
    @added_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # * Aquisição da lista de estados removidos
  #--------------------------------------------------------------------------
  def removed_state_objects
    @removed_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # * Definição de afetado por mudança de esados
  #--------------------------------------------------------------------------
  def status_affected?
    !(@added_states.empty? && @removed_states.empty? &&
      @added_buffs.empty? && @added_debuffs.empty? && @removed_buffs.empty?)
  end
  #--------------------------------------------------------------------------
  # * Definição de acerto
  #--------------------------------------------------------------------------
  def hit?
    @used && !@missed && !@evaded
  end
  #--------------------------------------------------------------------------
  # * Aquisição do texto de dano no HP
  #--------------------------------------------------------------------------
  def hp_damage_text
    if @hp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, @hp_drain, Vocab::hp)
    elsif @hp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorDamage : Vocab::EnemyDamage
      sprintf(fmt, @battler.name, @hp_damage)
    elsif @hp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, -@hp_damage, Vocab::hp)
    else
      fmt = @battler.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      sprintf(fmt, @battler.name)
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição do texto de dano no MP
  #--------------------------------------------------------------------------
  def mp_damage_text
    if @mp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, @mp_drain, Vocab::mp)
    elsif @mp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, @mp_damage, Vocab::mp)
    elsif @mp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, -@mp_damage, Vocab::mp)
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição do texto de dano no TP
  #--------------------------------------------------------------------------
  def tp_damage_text
    if @tp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, @tp_damage, Vocab::tp)
    elsif @tp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorGain : Vocab::EnemyGain
      sprintf(fmt, @battler.name, -@tp_damage, Vocab::tp)
    else
      ""
    end
  end
end
