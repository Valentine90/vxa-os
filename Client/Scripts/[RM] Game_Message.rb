#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  Esta classe gerencia o estado da janela de mensagem que exibe textos ou
# seleções, etc. A instância desta classe é referenciada por $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :texts                    # Texto da mensagem
  attr_reader   :choices                  # Conjunto de escolhas
  attr_accessor :face_name                # Nome do arquivo de face
  attr_accessor :face_index               # Índice do arquivo de face
  attr_accessor :background               # Tipo de fundo
  attr_accessor :position                 # Posição da janela
  attr_accessor :choice_proc              # Chamada de escolha (Proc)
  attr_accessor :choice_cancel_type       # Opção em caso de cancelamento
  attr_accessor :num_input_variable_id    # ID da variável numérica
  attr_accessor :num_input_digits_max     # Máximo de dígitos
  attr_accessor :item_choice_variable_id  # ID da variavel de seleção de itens
  attr_accessor :scroll_mode              # Flag de rolagem de texto
  attr_accessor :scroll_speed             # Velocidade de rolagem de texto
  attr_accessor :scroll_no_fast           # Acelerar rolagem desabilitada
  attr_accessor :visible                  # Visibilidade da janela
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    clear
    @visible = false
  end
  #--------------------------------------------------------------------------
  # * Limpeza
  #--------------------------------------------------------------------------
  def clear
    @texts = []
    @choices = []
    @face_name = ""
    @face_index = 0
    @background = 0
    @position = 2
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @item_choice_variable_id = 0
    @scroll_mode = false
    @scroll_speed = 2
    @scroll_no_fast = false
  end
  #--------------------------------------------------------------------------
  # * Adição de texto
  #--------------------------------------------------------------------------
  def add(text)
    @texts.push(text)
  end
  #--------------------------------------------------------------------------
  # * Definição de a presença de texto
  #--------------------------------------------------------------------------
  def has_text?
    @texts.size > 0
  end
  #--------------------------------------------------------------------------
  # * Definição de modo de escolhas
  #--------------------------------------------------------------------------
  def choice?
    @choices.size > 0
  end
  #--------------------------------------------------------------------------
  # * Definição de entrada númerica
  #--------------------------------------------------------------------------
  def num_input?
    @num_input_variable_id > 0
  end
  #--------------------------------------------------------------------------
  # * Definição de seleção de itens
  #--------------------------------------------------------------------------
  def item_choice?
    @item_choice_variable_id > 0
  end
  #--------------------------------------------------------------------------
  # * Definição de ocupação
  #--------------------------------------------------------------------------
  def busy?
    has_text? || choice? || num_input? || item_choice?
  end
  #--------------------------------------------------------------------------
  # * Nova página
  #--------------------------------------------------------------------------
  def new_page
    @texts[-1] += "\f" if @texts.size > 0
  end
  #--------------------------------------------------------------------------
  # * Aquisição de todos os textos incluídos
  #--------------------------------------------------------------------------
  def all_text
    @texts.inject("") {|r, text| r += text + "\n" }
  end
end
