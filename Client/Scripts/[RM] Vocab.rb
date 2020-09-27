#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  Este modulo define os termos e mensagens. Ele define algumas informação
# como variáveis constantes. Termos da base de dados são obtidos utilizando a 
# variável global $data_system.
#==============================================================================

module Vocab

  # Frases de loja
  #ShopSell        = "Vender"
  #ShopCancel      = "Sair"
  #Possession      = "Possui"

  # Frases de Estado
  #ExpTotal        = "Experiência Total"
  #ExpNext         = "Próximo %s"

  # Frases de salvar/carregar
  #File            = "Arquivo"

  # Nome do grupo de personagens
  PartyName       = "%s"

  # Mensagens iniciais de batalha
  Emerge          = "%s apareceu!"
  Preemptive      = "%s ataca primeiro!"
  Surprise        = "%s chegou de surpresa!"
  EscapeStart     = "% s fugiu!"
  EscapeFailure   = "Tentativa de fuga falhou!"

  # Mensagens finais de batalha
  Victory         = "O grupo de %s venceu a batalha!"
  Defeat          = "O grupo de %s foi derrotado!"
  ObtainExp       = "%s pontos de experiência!"
  ObtainGold      = "Você recebeu %s%s!"
  #ObtainItem      = "Você adquiriu  %s!"
  #LevelUp         = "%s subiu para o %s %s!"
  ObtainSkill     = "Aprendeu a habilidade %s!"

  # Mensagens de batalha
  #UseItem         = "%s usou %s!"

 # Resultados de ações (herói)
  ActorDamage     = "%s recebeu %s pontos de dano!"
  ActorRecovery   = "%s recuperou %s%s!"
  ActorGain       = "%s ganhou %s%s!"
  ActorLoss       = "%s perdeu %s%s!"
  ActorDrain      = "%s teve %s%s drenados"
  ActorNoDamage   = "%s não recebeu dano!"

  # Resultados de ações (inimigo)
  EnemyDamage     = "%s recebeu %s pontos de dano!"
  EnemyRecovery   = "%s recuperou %s%s!"
  EnemyGain       = "%s ganhou %s%s!"
  EnemyLoss       = "%s perdeu %s%s!"
  EnemyDrain      = "%s  teve %s%s drenados"
  EnemyNoDamage   = "%s não recebeu dano!"

  # Reflexão / Evasão
  #Evasion         = "%s evitou o ataque!"
  #MagicEvasion    = "%s evitou a magia!"
  #MagicReflection = "%s refletiu a magia!"
  #CounterAttack   = "%s contra - atacou!"
  #Substitute      = "%s transforma-se em %s!"

  # Enfraquecimento / Fortalecimento
  #BuffAdd         = "%s foi encantado com %s!"
  #DebuffAdd       = "%s sofeu %s!"
  #BuffRemove      = "%s não está mais encantado com %s!"

  # Caso não haja efeito do item
  #ActionFailure   = "%s não causou efeito!"

  # Mensagem de erro
  PlayerPosError  = "Não é possível definir a posição inicial do jogador."
  EventOverflow   = "Excedeu o máximo de chamadas de Eventos Comuns."

  # Termos Básicos
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # Parâmetros
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # Tipo de Equipamento
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # Comandos
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # Moeda
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # Nível
  def self.level_a;     basic(1);     end   # Nível (abreviação)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (abreviação)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (abreviação)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (abreviação)
  def self.fight;       command(0);   end   # Lutar
  def self.escape;      command(1);   end   # Fugir
  def self.attack;      command(2);   end   # Atacar
  def self.guard;       command(3);   end   # Defender
  def self.item;        command(4);   end   # Item
  def self.skill;       command(5);   end   # Habilidade
  def self.equip;       command(6);   end   # Equipamento
  def self.status;      command(7);   end   # Estado
  def self.formation;   command(8);   end   # Formação
  def self.save;        command(9);   end   # Salvar
  def self.game_end;    command(10);  end   # Sair
  def self.weapon;      command(12);  end   # Arma
  def self.armor;       command(13);  end   # Armadura
  def self.key_item;    command(14);  end   # Item Importante
  def self.equip2;      command(15);  end   # Mudar equipamento
  def self.optimize;    command(16);  end   # Otimizar
  def self.clear;       command(17);  end   # Remover
  def self.new_game;    command(18);  end   # Novo Jogo
  def self.continue;    command(19);  end   # Continuar
  def self.shutdown;    command(20);  end   # Sair
  def self.to_title;    command(21);  end   # Tela de Título
  def self.cancel;      command(22);  end   # Cancelar
  #--------------------------------------------------------------------------
end
