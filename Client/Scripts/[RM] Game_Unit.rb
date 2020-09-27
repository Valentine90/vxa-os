#==============================================================================
# ** Game_Unit
#------------------------------------------------------------------------------
#  Esta classe gerencia as unidades. Esta classe é usada como superclasse das
# classes Game_Troop e Game_Party.
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :in_battle                # flag de batalha
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @in_battle = false
  end
  #--------------------------------------------------------------------------
  # * Aquisição dos membros
  #--------------------------------------------------------------------------
  def members
    return []
  end
  #--------------------------------------------------------------------------
  # * Lista de membros vivos
  #--------------------------------------------------------------------------
  def alive_members
    members.select {|member| member.alive? }
  end
  #--------------------------------------------------------------------------
  # * Lista de membros incapacitados
  #--------------------------------------------------------------------------
  def dead_members
    members.select {|member| member.dead? }
  end
  #--------------------------------------------------------------------------
  # * Lista de membros que podem agir
  #--------------------------------------------------------------------------
  def movable_members
    members.select {|member| member.movable? }
  end
  #--------------------------------------------------------------------------
  # * Limpeza das ações
  #--------------------------------------------------------------------------
  def clear_actions
    members.each {|member| member.clear_actions }
  end
  #--------------------------------------------------------------------------
  # * Cálculo do valor médio de agilidade
  #--------------------------------------------------------------------------
  def agi
    return 1 if members.size == 0
    members.inject(0) {|r, member| r += member.agi } / members.size
  end
  #--------------------------------------------------------------------------
  # * Cálculo da a taxa de alvo
  #--------------------------------------------------------------------------
  def tgr_sum
    alive_members.inject(0) {|r, member| r + member.tgr }
  end
  #--------------------------------------------------------------------------
  # * Definição de alvo aleatório
  #--------------------------------------------------------------------------
  def random_target
    tgr_rand = rand * tgr_sum
    alive_members.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    alive_members[0]
  end
  #--------------------------------------------------------------------------
  # * Definição de alvo aleatório (incapacitado)
  #--------------------------------------------------------------------------
  def random_dead_target
    dead_members.empty? ? nil : dead_members[rand(dead_members.size)]
  end
  #--------------------------------------------------------------------------
  # * Determinação precisa de alvo
  #     index : índice do alvo
  #--------------------------------------------------------------------------
  def smooth_target(index)
    member = members[index]
    (member && member.alive?) ? member : alive_members[0]
  end
  #--------------------------------------------------------------------------
  # * Determinação precisa de alvo (incapacitado)
  #     index : índice do alvo
  #--------------------------------------------------------------------------
  def smooth_dead_target(index)
    member = members[index]
    (member && member.dead?) ? member : dead_members[0]
  end
  #--------------------------------------------------------------------------
  # * Limpeza dos resultados
  #--------------------------------------------------------------------------
  def clear_results
    members.select {|member| member.result.clear }
  end
  #--------------------------------------------------------------------------
  # * Processamento no inicio do combate
  #--------------------------------------------------------------------------
  def on_battle_start
    members.each {|member| member.on_battle_start }
    @in_battle = true
  end
  #--------------------------------------------------------------------------
  # * Processamento no final do combate
  #--------------------------------------------------------------------------
  def on_battle_end
    @in_battle = false
    members.each {|member| member.on_battle_end }
  end
  #--------------------------------------------------------------------------
  # * Definição de ações
  #--------------------------------------------------------------------------
  def make_actions
    members.each {|member| member.make_actions }
  end
  #--------------------------------------------------------------------------
  # * Definição de derrota
  #--------------------------------------------------------------------------
  def all_dead?
    alive_members.empty?
  end
  #--------------------------------------------------------------------------
  # * Definição de subistituto
  #--------------------------------------------------------------------------
  def substitute_battler
    members.find {|member| member.substitute? }
  end
end
