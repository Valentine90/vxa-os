#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  Este sprite é usado para mostrar personagens. Ele observa uma instância
# da classe Game_Character e automaticamente muda as condições do sprite.
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :character
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     viewport  : camada
  #     character : personagem (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @balloon_duration = 0
    # VXA-OS
    init_sprites
    update
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  def dispose
    end_animation
    end_balloon
    # VXA-OS
    dispose_sprites
    super
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    update_src_rect
    update_position
    update_other
    update_balloon
    # VXA-OS
    update_sprites
    setup_new_effect
  end
  #--------------------------------------------------------------------------
  # * Aquisição da imagem do tileset que contém o tile designado
  #     tile_id : ID do tile
  #--------------------------------------------------------------------------
  def tileset_bitmap(tile_id)
    Cache.tileset($game_map.tileset.tileset_names[5 + tile_id / 256])
  end
  #--------------------------------------------------------------------------
  # * Atualização do bitmap de origem
  #--------------------------------------------------------------------------
  def update_bitmap
    if graphic_changed?
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_index = @character.character_index
      if @tile_id > 0
        set_tile_bitmap
      else
        set_character_bitmap
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Definição de mudança de gráficos
  #--------------------------------------------------------------------------
  def graphic_changed?
    @tile_id != @character.tile_id ||
    @character_name != @character.character_name ||
    @character_index != @character.character_index
  end
  #--------------------------------------------------------------------------
  # * Definição de bitmap do tile
  #--------------------------------------------------------------------------
  def set_tile_bitmap
    sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32;
    sy = @tile_id % 256 / 8 % 16 * 32;
    self.bitmap = tileset_bitmap(@tile_id)
    self.src_rect.set(sx, sy, 32, 32)
    self.ox = 16
    self.oy = 32
  end
  #--------------------------------------------------------------------------
  # * Definição de bitmap do personagem
  #--------------------------------------------------------------------------
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    self.ox = @cw / 2
    self.oy = @ch
  end
  #--------------------------------------------------------------------------
  # * Atualização do retângulo de origem
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da posição
  #--------------------------------------------------------------------------
  def update_position
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z
  end
  #--------------------------------------------------------------------------
  # * Atualizações variadas
  #--------------------------------------------------------------------------
  def update_other
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    self.visible = !@character.transparent
  end
  #--------------------------------------------------------------------------
  # * Definição de um novo efeito
  #--------------------------------------------------------------------------
  def setup_new_effect
    if !animation? && @character.animation_id > 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
    end
    if !@balloon_sprite && @character.balloon_id > 0
      @balloon_id = @character.balloon_id
      start_balloon
    end
  end
  #--------------------------------------------------------------------------
  # * Finalização da animação
  #--------------------------------------------------------------------------
  def end_animation
    super
    @character.animation_id = 0
  end
  #--------------------------------------------------------------------------
  # * Inicialização ícone de emoção
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * balloon_speed + balloon_wait
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    update_balloon
  end
  #--------------------------------------------------------------------------
  # * Disposição do ícone de emoção
  #--------------------------------------------------------------------------
  def dispose_balloon
    if @balloon_sprite
      @balloon_sprite.dispose
      @balloon_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do ícone de emoção
  #--------------------------------------------------------------------------
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration > 0
        @balloon_sprite.x = x
        @balloon_sprite.y = y - height
        @balloon_sprite.z = z + 200
        sx = balloon_frame_index * 32
        sy = (@balloon_id - 1) * 32
        @balloon_sprite.src_rect.set(sx, sy, 32, 32)
      else
        end_balloon
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Finalização do ícone de emoção
  #--------------------------------------------------------------------------
  def end_balloon
    dispose_balloon
    @character.balloon_id = 0
  end
  #--------------------------------------------------------------------------
  # * Velocidade do ícone de emoção
  #--------------------------------------------------------------------------
  def balloon_speed
    return 8
  end
  #--------------------------------------------------------------------------
  # * Tempo de espera do ícone de emoção
  #--------------------------------------------------------------------------
  def balloon_wait
    return 12
  end
  #--------------------------------------------------------------------------
  # * Índice do quadro do ícone de emoção
  #--------------------------------------------------------------------------
  def balloon_frame_index
    return 7 - [(@balloon_duration - balloon_wait) / balloon_speed, 0].max
  end
end
