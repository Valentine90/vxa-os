#==============================================================================
# ** Game_Action
#------------------------------------------------------------------------------
#  Esta classe gerencia as ações do combate.
# Esta classe é usada internamente pela classe Game_Battler.
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :subject                  # Alvos
  attr_reader   :forcing                  # Flag de ação forçada
  attr_reader   :item                     # habilidade/item
  attr_accessor :target_index             # índice do alvo
  attr_reader   :value                    # valor
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize(subject, forcing = false)
    @subject = subject
    @forcing = forcing
    clear
  end
  #--------------------------------------------------------------------------
  # * Limpeza
  #--------------------------------------------------------------------------
  def clear
    @item = Game_BaseItem.new
    @target_index = -1
    @value = 0
  end
  #--------------------------------------------------------------------------
  # * Unidade aliada
  #--------------------------------------------------------------------------
  def friends_unit
    subject.friends_unit
  end
  #--------------------------------------------------------------------------
  # * Unidade inimiga
  #--------------------------------------------------------------------------
  def opponents_unit
    subject.opponents_unit
  end
  #--------------------------------------------------------------------------
  # * Definir ação dos inimigos
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def set_enemy_action(action)
    if action
      set_skill(action.skill_id)
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # * Configuração do ataque
  #--------------------------------------------------------------------------
  def set_attack
    set_skill(subject.attack_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # * Configuração da defesa
  #--------------------------------------------------------------------------
  def set_guard
    set_skill(subject.guard_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # * Configuração das habilidades
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def set_skill(skill_id)
    @item.object = $data_skills[skill_id]
    self
  end
  #--------------------------------------------------------------------------
  # * Configuração dos itens
  #     item_id : ID do item
  #--------------------------------------------------------------------------
  def set_item(item_id)
    @item.object = $data_items[item_id]
    self
  end
  #--------------------------------------------------------------------------
  # * Aquisição das informações
  #--------------------------------------------------------------------------
  def item
    @item.object
  end
  #--------------------------------------------------------------------------
  # * Definição de ataque
  #--------------------------------------------------------------------------
  def attack?
    item == $data_skills[subject.attack_skill_id]
  end
  #--------------------------------------------------------------------------
  # * Definição de alvo aleatório
  #--------------------------------------------------------------------------
  def decide_random_target
    if item.for_dead_friend?
      target = friends_unit.random_dead_target
    elsif item.for_friend?
      target = friends_unit.random_target
    else
      target = opponents_unit.random_target
    end
    if target
      @target_index = target.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de ação em cofusão
  #--------------------------------------------------------------------------
  def set_confusion
    set_attack
  end
  #--------------------------------------------------------------------------
  # * Preparar ação
  #--------------------------------------------------------------------------
  def prepare
    set_confusion if subject.confusion? && !forcing
  end
  #--------------------------------------------------------------------------
  # * Definição de ação é válida
  #   Assumindo que um comando de evento não cause [Ação Forçada], se uma
  #   limitação de estado ou outra condição impeça que a ação seja executada
  #   retorna false.
  #--------------------------------------------------------------------------
  def valid?
    (forcing && item) || subject.usable?(item)
  end
  #--------------------------------------------------------------------------
  # * Definição de velocidade da ação
  #--------------------------------------------------------------------------
  def speed
    speed = subject.agi + rand(5 + subject.agi / 4)
    speed += item.speed if item
    speed += subject.atk_speed if attack?
    speed
  end
  #--------------------------------------------------------------------------
  # * Criação da lista de alvos
  #--------------------------------------------------------------------------
  def make_targets
    if !forcing && subject.confusion?
      [confusion_target]
    elsif item.for_opponent?
      targets_for_opponents
    elsif item.for_friend?
      targets_for_friends
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # * Quando é alvo de confusão 
  #--------------------------------------------------------------------------
  def confusion_target
    case subject.confusion_level
    when 1
      opponents_unit.random_target
    when 2
      if rand(2) == 0
        opponents_unit.random_target
      else
        friends_unit.random_target
      end
    else
      friends_unit.random_target
    end
  end
  #--------------------------------------------------------------------------
  # * Alvos para inimigos
  #--------------------------------------------------------------------------
  def targets_for_opponents
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.random_target] * num
      else
        [opponents_unit.smooth_target(@target_index)] * num
      end
    else
      opponents_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # * Alvos para aliados
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        [friends_unit.smooth_target(@target_index)]
      else
        friends_unit.alive_members
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Verificação da ação (combate automático)
  #    @value e @target_index são definidas automaticamente.
  #--------------------------------------------------------------------------
  def evaluate
    @value = 0
    evaluate_item if valid?
    @value += rand if @value > 0
    self
  end
  #--------------------------------------------------------------------------
  # * Verificação da habilidade/item
  #--------------------------------------------------------------------------
  def evaluate_item
    item_target_candidates.each do |target|
      value = evaluate_item_with_target(target)
      if item.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos candidatos a alvo da habilidade/item
  #--------------------------------------------------------------------------
  def item_target_candidates
    if item.for_opponent?
      opponents_unit.alive_members
    elsif item.for_user?
      [subject]
    elsif item.for_dead_friend?
      friends_unit.dead_members
    else
      friends_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # * Verificação de habilidades / itens (definição de alvo)
  #--------------------------------------------------------------------------
  def evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if item.for_opponent?
      return target.result.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.result.hp_damage, target.mhp - target.hp].min
      return recovery.to_f / target.mhp
    end
  end
end
