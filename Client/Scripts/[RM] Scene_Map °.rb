#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  Esta classe executa o processamento da tela de mapa.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  #--------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    create_spriteset
    create_all_windows
    @menu_calling = false
  end
  #--------------------------------------------------------------------------
  # * Execução da transição
  #    Depois da batalha ou carregamento. 
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0
      Graphics.transition(0)
      fadein(fadein_speed)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de transição
  #--------------------------------------------------------------------------
  def transition_speed
    return 15
  end
=begin
  #--------------------------------------------------------------------------
  # * Processamento pré finalização
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)
  end
=end
  #--------------------------------------------------------------------------
  # * Finalização do processo
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_spriteset
    # VXA-OS
    #perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.update(true)
    $game_player.update
    $game_timer.update
    @spriteset.update
    # VXA-OS
    update_trigger
    #update_scene if scene_change_ok?
  end
=begin
  #--------------------------------------------------------------------------
  # * Definição de transição de cena
  #--------------------------------------------------------------------------
  def scene_change_ok?
    !$game_message.busy? && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # * Atualização da cena
  #--------------------------------------------------------------------------
  def update_scene
    check_gameover
    update_transfer_player unless scene_changing?
    update_encounter unless scene_changing?
    update_call_menu unless scene_changing?
    update_call_debug unless scene_changing?
  end
=end
  #--------------------------------------------------------------------------
  # * Atualização da tela (para fade)
  #--------------------------------------------------------------------------
  def update_for_fade
    update_basic
    $game_map.update(false)
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # * Processamento de efeito de fade
  #     duration : duração
  #--------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  #--------------------------------------------------------------------------
  # * Execução de efeito de fade in
  #     duration : duração
  #--------------------------------------------------------------------------
  def fadein(duration)
    fade_loop(duration) {|v| Graphics.brightness = v }
  end
  #--------------------------------------------------------------------------
  # * Execução de efeito de fade out
  #     duration : duração
  #--------------------------------------------------------------------------
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  #--------------------------------------------------------------------------
  # * Execução de efeito de fade in (branco)
  #     duration : duração
  #--------------------------------------------------------------------------
  def white_fadein(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, 255 - v) }
  end
  #--------------------------------------------------------------------------
  # * Execução de efeito de fade out (branco)
  #     duration : duração
  #--------------------------------------------------------------------------
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  #--------------------------------------------------------------------------
  # * Criação do conjuto de sprites
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # * Disposição do conjuto de sprites
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
=begin
  #--------------------------------------------------------------------------
  # * Criação de todas as janelas
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_location_window
  end
=end
  #--------------------------------------------------------------------------
  # * Criação da janela de mensagens
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # * Criação da janela de rolagem de texto
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
=begin
  #--------------------------------------------------------------------------
  # * Criação da janela de nome do mapa
  #--------------------------------------------------------------------------
  def create_location_window
    @map_name_window = Window_MapName.new
  end
  #--------------------------------------------------------------------------
  # * Atualização de transferência do jogador
  #--------------------------------------------------------------------------
  def update_transfer_player
    perform_transfer if $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # * Atualização dos encontros
  #--------------------------------------------------------------------------
  def update_encounter
    SceneManager.call(Scene_Battle) if $game_player.encounter
  end
  #--------------------------------------------------------------------------
  # * Atualização da chamada do menu quando pressionada tecla
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  #--------------------------------------------------------------------------
  # * Chamada do menu
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
  end
  #--------------------------------------------------------------------------
  # * Atualização da chamada do debug quando pressionada tecla F9
  #--------------------------------------------------------------------------
  def update_call_debug
    SceneManager.call(Scene_Debug) if $TEST && Input.press?(:F9)
  end
  #--------------------------------------------------------------------------
  # * Execução da mudança de localização
  #--------------------------------------------------------------------------
  def perform_transfer
    pre_transfer
    $game_player.perform_transfer
    post_transfer
  end
  #--------------------------------------------------------------------------
  # * Processamento pré mudança de localização
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close
    case $game_temp.fade_type
    when 0
      fadeout(fadeout_speed)
    when 1
      white_fadeout(fadeout_speed)
    end
  end
  #--------------------------------------------------------------------------
  # * Processamento pós mudança de localização
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    @map_name_window.open
  end
  #--------------------------------------------------------------------------
  # * Processamento pré inicio de batalha
  #--------------------------------------------------------------------------
  def pre_battle_scene
    Graphics.update
    Graphics.freeze
    @spriteset.dispose_characters
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # * Processamento pré cena de título
  #--------------------------------------------------------------------------
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  #--------------------------------------------------------------------------
  # * Execução da transição de batalha
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(60, "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de fade out
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
=end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de fade in
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
=begin
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de fade out para tela de título
  #--------------------------------------------------------------------------
  def fadeout_speed_to_title
    return 60
  end
=end
end
