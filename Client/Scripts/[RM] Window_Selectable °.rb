#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  Esta janela contém as funções de movimento do cursor e rolagem.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :index                    # Posição do cursor
  attr_reader   :help_window              # Janela de ajuda
  attr_accessor :cursor_fix               # Flag de fixação do cursor
  attr_accessor :cursor_all               # Flag de seleção de todos
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     x      : coordenada X
  #     y      : coordenada Y
  #     width  : largura
  #     height : altura
  #-------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @index = -1
    @handler = {}
    @cursor_fix = false
    @cursor_all = false
    update_padding
    deactivate
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de colunas
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição do espaçamento entre os itens
  #--------------------------------------------------------------------------
  def spacing
    return 32
  end
=begin
  #--------------------------------------------------------------------------
  # * Aquisição do número máximo de itens
  #--------------------------------------------------------------------------
  def item_max
    return 0
  end
=end
  #--------------------------------------------------------------------------
  # * Aquisição de largura do item
  #--------------------------------------------------------------------------
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  #--------------------------------------------------------------------------
  # * Aquisição de altura do item
  #--------------------------------------------------------------------------
  def item_height
    line_height
  end
  #--------------------------------------------------------------------------
  # * Cálculo do número de linhas
  #--------------------------------------------------------------------------
  def row_max
    [(item_max + col_max - 1) / col_max, 1].max
  end
  #--------------------------------------------------------------------------
  # * Cálculo da altura do conteúdo da janela
  #--------------------------------------------------------------------------
  def contents_height
    [super - super % item_height, row_max * item_height].max
  end
  #--------------------------------------------------------------------------
  # * Atualização do espaçamento
  #--------------------------------------------------------------------------
  def update_padding
    super
    update_padding_bottom
  end
  #--------------------------------------------------------------------------
  # * Atualização do espaçamento abaixo
  #--------------------------------------------------------------------------
  def update_padding_bottom
    surplus = (height - standard_padding * 2) % item_height
    self.padding_bottom = padding + surplus
  end
  #--------------------------------------------------------------------------
  # * Ajuste de altura
  #     height : valor de ajuset
  #--------------------------------------------------------------------------
  def height=(height)
    super
    update_padding
  end
  #--------------------------------------------------------------------------
  # * Mudança na atividade
  #    active : flag de atividade
  #--------------------------------------------------------------------------
  def active=(active)
    super
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Definição da posição do cursor
  #    índice : posição do cursor
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Seleção de itens
  #     index : índice do item
  #--------------------------------------------------------------------------
  def select(index)
    self.index = index if index
  end
  #--------------------------------------------------------------------------
  # * Remoção da seleção de itens
  #--------------------------------------------------------------------------
  def unselect
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # * Aquisição da linha atual
  #--------------------------------------------------------------------------
  def row
    index / col_max
  end
  #--------------------------------------------------------------------------
  # * Aquisição da primeira linha
  #--------------------------------------------------------------------------
  def top_row
    oy / item_height
  end
  #--------------------------------------------------------------------------
  # * Definição da primeira linha
  #     row : linha
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * item_height
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de linhas exibidas por página
  #--------------------------------------------------------------------------
  def page_row_max
    (height - padding - padding_bottom) / item_height
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de itens que podem ser exibidos em uma página
  #--------------------------------------------------------------------------
  def page_item_max
    page_row_max * col_max
  end
  #--------------------------------------------------------------------------
  # * Definição de seleção horizontal
  #--------------------------------------------------------------------------
  def horizontal?
    page_row_max == 1
  end
  #--------------------------------------------------------------------------
  # * Aquisição da última linha
  #--------------------------------------------------------------------------
  def bottom_row
    top_row + page_row_max - 1
  end
  #--------------------------------------------------------------------------
  # * Definição da última linha
  #     row : linha
  #--------------------------------------------------------------------------
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do retangulo para desenhar o item
  #     index : índice do item
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # * Aquisição do retangulo para desenhar o item (para texto)
  #     index : índice do item
  #--------------------------------------------------------------------------
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    rect
  end
  #--------------------------------------------------------------------------
  # * Configuração da janela de ajuda
  #     help_window : janela de ajuda
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Configuração do controlador de operação
  #     symbol : controlador
  #     method : definição de um método controle (objeto Method)
  #--------------------------------------------------------------------------
  def set_handler(symbol, method)
    @handler[symbol] = method
  end
  #--------------------------------------------------------------------------
  # * Definição da presença do controlador
  #     symbol : controlador
  #--------------------------------------------------------------------------
  def handle?(symbol)
    @handler.include?(symbol)
  end
  #--------------------------------------------------------------------------
  # * Chamada do controlador
  #     symbol : controlador
  #--------------------------------------------------------------------------
  def call_handler(symbol)
    @handler[symbol].call if handle?(symbol)
  end
  #--------------------------------------------------------------------------
  # * Definição de movimento do cursor
  #--------------------------------------------------------------------------
  def cursor_movable?
    active && open? && !@cursor_fix && !@cursor_all && item_max > 0
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor para baixo
  #     wrap : cursor retornar a primeira ou ultima posição
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor para cima
  #     wrap : cursor retornar a primeira ou ultima posição
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor para direita
  #     wrap : cursor retornar a primeira ou ultima posição
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if col_max >= 2 && (index < item_max - 1 || (wrap && horizontal?))
      select((index + 1) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor para esquerda
  #     wrap : cursor retornar a primeira ou ultima posição
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if col_max >= 2 && (index > 0 || (wrap && horizontal?))
      select((index - 1 + item_max) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor uma página abaixo
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_row + page_row_max < row_max
      self.top_row += page_row_max
      select([@index + page_item_max, item_max - 1].min)
    end
  end
  #--------------------------------------------------------------------------
  # * Movimento do cursor uma página acima
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_row > 0
      self.top_row -= page_row_max
      select([@index - page_item_max, 0].max)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    process_cursor_move
    process_handling
  end
=begin
  #--------------------------------------------------------------------------
  # * Execução do movimento do cursor
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
  end
  #--------------------------------------------------------------------------
  # * Definição de controle de confirmação e cancelamento
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
  end
=end
  #--------------------------------------------------------------------------
  # * Definição de confirmação
  #--------------------------------------------------------------------------
  def ok_enabled?
    handle?(:ok)
  end
  #--------------------------------------------------------------------------
  # * Definição de cancelamento
  #--------------------------------------------------------------------------
  def cancel_enabled?
    handle?(:cancel)
  end
  #--------------------------------------------------------------------------
  # * Definição de resultado ao pressionar o botão de confirmação
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * Chamada de controlador de confirmação
  #--------------------------------------------------------------------------
  def call_ok_handler
    call_handler(:ok)
  end
  #--------------------------------------------------------------------------
  # * Definição de resultado ao pressionar o botão de cancelamento
  #--------------------------------------------------------------------------
  def process_cancel
    Sound.play_cancel
    Input.update
    deactivate
    call_cancel_handler
  end
  #--------------------------------------------------------------------------
  # * Chamada de controlador de cancelamento
  #--------------------------------------------------------------------------
  def call_cancel_handler
    call_handler(:cancel)
  end
  #--------------------------------------------------------------------------
  # * Definição de resultado ao pressionar o botão L (subir página)
  #--------------------------------------------------------------------------
  def process_pageup
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:pageup)
  end
  #--------------------------------------------------------------------------
  # * Definição de resultado ao pressionar o botão R (descer página)
  #--------------------------------------------------------------------------
  def process_pagedown
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:pagedown)
  end
  #--------------------------------------------------------------------------
  # * Atualização do cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
  end
  #--------------------------------------------------------------------------
  # * Confirmação de visibilidade do cursor
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_row = row if row < top_row
    self.bottom_row = row if row > bottom_row
  end
  #--------------------------------------------------------------------------
  # * Chamada do método de atualização da janela de ajuda
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active && @help_window
  end
  #--------------------------------------------------------------------------
  # * Atualização da janela de ajuda
  #--------------------------------------------------------------------------
  def update_help
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # * Definição de habilitação de seleção
  #--------------------------------------------------------------------------
  def current_item_enabled?
    return true
  end
  #--------------------------------------------------------------------------
  # * Desenho de todos os itens
  #--------------------------------------------------------------------------
  def draw_all_items
    item_max.times {|i| draw_item(i) }
  end
  #--------------------------------------------------------------------------
  # * Desenho de um item
  #     index : índice do item
  #--------------------------------------------------------------------------
  def draw_item(index)
  end
  #--------------------------------------------------------------------------
  # * Limpeza do item
  #     index : índice do item
  #--------------------------------------------------------------------------
  def clear_item(index)
    contents.clear_rect(item_rect(index))
  end
  #--------------------------------------------------------------------------
  # * Redesenho do item
  #     index : índice do item
  #--------------------------------------------------------------------------
  def redraw_item(index)
    clear_item(index) if index >= 0
    draw_item(index)  if index >= 0
  end
  #--------------------------------------------------------------------------
  # * Redesenho do item atual
  #--------------------------------------------------------------------------
  def redraw_current_item
    redraw_item(@index)
  end
=begin
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_all_items
  end
=end
end
