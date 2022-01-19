#==============================================================================
# ** Sound
#------------------------------------------------------------------------------
#  Este modulo reproduz efeitos sonoros. Ela obtem efeitos sonoros obtidos 
# na base de dados utilizando a variável global $data_system, e os reproduz.
#==============================================================================

module Sound
  
  # Sons do Sistema
  def self.play_system_sound(n)
    $data_system.sounds[n].play
  end

  # Movimento de cursos
  def self.play_cursor
    play_system_sound(0)
  end

  # OK
  def self.play_ok
    play_system_sound(1)
  end

 # Cancelar
  def self.play_cancel
    play_system_sound(2)
  end

  # Erro
  def self.play_buzzer
    play_system_sound(3)
  end

  # Equipar
  def self.play_equip
    play_system_sound(4)
  end

  # Salvar
  def self.play_save
    play_system_sound(5)
  end

  # Carregar
  def self.play_load
    play_system_sound(6)
  end

  # Início da batalha
  def self.play_battle_start
    play_system_sound(7)
  end

  # Início da batalha
  def self.play_escape
    play_system_sound(8)
  end

  # Ataque inimigo
  def self.play_enemy_attack
    play_system_sound(9)
  end

  # Dano inimigo
  def self.play_enemy_damage
    play_system_sound(10)
  end

  # Colapso do Inimigo
  def self.play_enemy_collapse
    play_system_sound(11)
  end

  # Colapso de Boss 1
  def self.play_boss_collapse1
    play_system_sound(12)
  end

  # Colapso de Boss 2
  def self.play_boss_collapse2
    play_system_sound(13)
  end

  # Dano aliado
  def self.play_actor_damage
    play_system_sound(14)
  end

  # Colapso do Aliado
  def self.play_actor_collapse
    play_system_sound(15)
  end

  # Cura
  def self.play_recovery
    play_system_sound(16)
  end

  # Errar Ataque
  def self.play_miss
    play_system_sound(17)
  end

  # Esquivar Ataque
  def self.play_evasion
    play_system_sound(18)
  end

  # Esquivar Magia
  def self.play_magic_evasion
    play_system_sound(19)
  end

  # Refletir
  def self.play_reflection
    play_system_sound(20)
  end

  # Loja
  def self.play_shop
    play_system_sound(21)
  end

  # Usar Item
  def self.play_use_item
    play_system_sound(22)
  end

  # Usar Habilidade
  def self.play_use_skill
    play_system_sound(23)
  end

end
