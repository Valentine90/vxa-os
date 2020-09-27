#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  Esta classe gerencia os dados relacionados ao sistema. Também gerencia
# veículos, BGM, etc.
# A instância desta classe é referenciada por $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :save_disabled            # Save desabilitado
  attr_accessor :menu_disabled            # Menu desabilitado
  attr_accessor :encounter_disabled       # Encontros desabilitados
  attr_accessor :formation_disabled       # Formação desabilitada
  attr_accessor :battle_count             # Numero de combates
  attr_reader   :save_count               # Número de saves
  attr_reader   :version_id               # Versão do jogo
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @formation_disabled = false
    @battle_count = 0
    @save_count = 0
    @version_id = 0
    @window_tone = nil
    @battle_bgm = nil
    @battle_end_me = nil
    @saved_bgm = nil
  end
  #--------------------------------------------------------------------------
  # * Definição de modo japonês
  #--------------------------------------------------------------------------
  def japanese?
    return false
  end
  #--------------------------------------------------------------------------
  # * Aquisição da Tonalidade da janela
  #--------------------------------------------------------------------------
  def window_tone
    @window_tone || $data_system.window_tone
  end
  #--------------------------------------------------------------------------
  # * Definir Tonalidade da janela
  #--------------------------------------------------------------------------
  def window_tone=(window_tone)
    @window_tone = window_tone
  end
  #--------------------------------------------------------------------------
  # * Informação de BGM de batalha
  #--------------------------------------------------------------------------
  def battle_bgm
    @battle_bgm || $data_system.battle_bgm
  end
  #--------------------------------------------------------------------------
  # * Configuração da BGM de batalha
  #     battle_bgm : nova BGM de batalha
  #--------------------------------------------------------------------------
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #--------------------------------------------------------------------------
  # * Informação de ME de fim de batalha
  #--------------------------------------------------------------------------
  def battle_end_me
    @battle_end_me || $data_system.battle_end_me
  end
  #--------------------------------------------------------------------------
  # * Configuração da ME de fim de batalha
  #     battle_end_me : nova ME de fim de batalha
  #--------------------------------------------------------------------------
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #--------------------------------------------------------------------------
  # * Preparação antes de salvar
  #--------------------------------------------------------------------------
  def on_before_save
    @save_count += 1
    @version_id = $data_system.version_id
    @frames_on_save = Graphics.frame_count
    @bgm_on_save = RPG::BGM.last
    @bgs_on_save = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # * Preparação após carregar
  #--------------------------------------------------------------------------
  def on_after_load
    Graphics.frame_count = @frames_on_save
    @bgm_on_save.play
    @bgs_on_save.play
  end
  #--------------------------------------------------------------------------
  # * Tempo de jogo
  #--------------------------------------------------------------------------
  def playtime
    Graphics.frame_count / Graphics.frame_rate
  end
  #--------------------------------------------------------------------------
  # * Tempo de jogo (formato de texto)
  #--------------------------------------------------------------------------
  def playtime_s
    hour = playtime / 60 / 60
    min = playtime / 60 % 60
    sec = playtime % 60
    sprintf("%02d:%02d:%02d", hour, min, sec)
  end
  #--------------------------------------------------------------------------
  # * Salvar BGM
  #--------------------------------------------------------------------------
  def save_bgm
    @saved_bgm = RPG::BGM.last
  end
  #--------------------------------------------------------------------------
  # * Resumir BGM
  #--------------------------------------------------------------------------
  def replay_bgm
    @saved_bgm.replay if @saved_bgm
  end
end
