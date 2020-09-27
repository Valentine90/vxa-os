#==============================================================================
# ** Window_ScrollText
#------------------------------------------------------------------------------
#  Esta janela é usada para exibir o texto rolante. Não exibe o quadro da
# janela, é tratado como uma janela por conveniência.
#==============================================================================

class Window_ScrollText < Window_Base
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0
    self.arrows_visible = false
    hide
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    if $game_message.scroll_mode
      update_message if @text
      start_message if !@text && $game_message.has_text?
    end
  end
  #--------------------------------------------------------------------------
  # * Inicialização da mensagem
  #--------------------------------------------------------------------------
  def start_message
    @text = $game_message.all_text
    refresh
    show
  end
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    reset_font_settings
    update_all_text_height
    create_contents
    draw_text_ex(4, 0, @text)
    self.oy = @scroll_pos = -height
  end
  #--------------------------------------------------------------------------
  # * Atualização da altura necessária para o desenho do texto completo
  #--------------------------------------------------------------------------
  def update_all_text_height
    @all_text_height = 1
    convert_escape_characters(@text).each_line do |line|
      @all_text_height += calc_line_height(line, false)
    end
    reset_font_settings
  end
  #--------------------------------------------------------------------------
  # * Cálculo da altura do conteúdo da janela
  #--------------------------------------------------------------------------
  def contents_height
    @all_text_height ? @all_text_height : super
  end
  #--------------------------------------------------------------------------
  # * Atualização da mensagem
  #--------------------------------------------------------------------------
  def update_message
    @scroll_pos += scroll_speed
    self.oy = @scroll_pos
    terminate_message if @scroll_pos >= contents.height
  end
  #--------------------------------------------------------------------------
  # * Aquisição da velocidade de rolagem
  #--------------------------------------------------------------------------
  def scroll_speed
    $game_message.scroll_speed * (show_fast? ? 1.0 : 0.5)
  end
  #--------------------------------------------------------------------------
  # * Definição de exbição rápida
  #--------------------------------------------------------------------------
  def show_fast?
    !$game_message.scroll_no_fast && (Input.press?(:A) || Input.press?(:C))
  end
  #--------------------------------------------------------------------------
  # * Finalização da mensagem
  #--------------------------------------------------------------------------
  def terminate_message
    @text = nil
    $game_message.clear
    hide
  end
end
