#==============================================================================
# ** Spriteset_Weather
#------------------------------------------------------------------------------
#  Classe　dos efeitos climáticoss (chuva, tempestade, neve). Esta classe 
# é usada internamente pela classe Spriteset_Map. 
#==============================================================================

class Spriteset_Weather
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :type                     # Tipo de clima
  attr_accessor :ox                       # Coordenada X de origem
  attr_accessor :oy                       # Coordenada Y de origem
  attr_reader   :power                    # Intensidade
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #     viewport : camada
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    @viewport = viewport
    init_members
    create_rain_bitmap
    create_storm_bitmap
    create_snow_bitmap
  end
  #--------------------------------------------------------------------------
  # * Inicialização das variaves
  #--------------------------------------------------------------------------
  def init_members
    @type = :none
    @ox = 0
    @oy = 0
    @power = 0
    @sprites = []
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each {|sprite| sprite.dispose }
    @rain_bitmap.dispose
    @storm_bitmap.dispose
    @snow_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Cor da partícula 1
  #--------------------------------------------------------------------------
  def particle_color1
    Color.new(255, 255, 255, 192)
  end
  #--------------------------------------------------------------------------
  # * Cor da partícula 2
  #--------------------------------------------------------------------------
  def particle_color2
    Color.new(255, 255, 255, 96)
  end
  #--------------------------------------------------------------------------
  # * Criação dos bitmaps da chuva
  #--------------------------------------------------------------------------
  def create_rain_bitmap
    @rain_bitmap = Bitmap.new(7, 42)
    7.times {|i| @rain_bitmap.fill_rect(6-i, i*6, 1, 6, particle_color1) }
  end
  #--------------------------------------------------------------------------
  # * Criação dos bitmaps da tempestade
  #--------------------------------------------------------------------------
  def create_storm_bitmap
    @storm_bitmap = Bitmap.new(34, 64)
    32.times do |i|
      @storm_bitmap.fill_rect(33-i, i*2, 1, 2, particle_color2)
      @storm_bitmap.fill_rect(32-i, i*2, 1, 2, particle_color1)
      @storm_bitmap.fill_rect(31-i, i*2, 1, 2, particle_color2)
    end
  end
  #--------------------------------------------------------------------------
  # * Criação dos bitmaps da neve
  #--------------------------------------------------------------------------
  def create_snow_bitmap
    @snow_bitmap = Bitmap.new(6, 6)
    @snow_bitmap.fill_rect(0, 1, 6, 4, particle_color2)
    @snow_bitmap.fill_rect(1, 0, 4, 6, particle_color2)
    @snow_bitmap.fill_rect(1, 2, 4, 2, particle_color1)
    @snow_bitmap.fill_rect(2, 1, 2, 4, particle_color1)
  end
  #--------------------------------------------------------------------------
  # * Definir a intensidade do clima
  #     power : intensidade
  #--------------------------------------------------------------------------
  def power=(power)
    @power = power
    (sprite_max - @sprites.size).times { add_sprite }
    (@sprites.size - sprite_max).times { remove_sprite }
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número máximo de sprites
  #--------------------------------------------------------------------------
  def sprite_max
    (@power * 10).to_i
  end
  #--------------------------------------------------------------------------
  # * Adição do sprite
  #--------------------------------------------------------------------------
  def add_sprite
    sprite = Sprite.new(@viewport)
    sprite.opacity = 0
    @sprites.push(sprite)
  end
  #--------------------------------------------------------------------------
  # * Remoção do sprite
  #--------------------------------------------------------------------------
  def remove_sprite
    sprite = @sprites.pop
    sprite.dispose if sprite
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    update_screen
    @sprites.each {|sprite| update_sprite(sprite) }
  end
  #--------------------------------------------------------------------------
  # * Atualização da tonalidade da tela
  #--------------------------------------------------------------------------
  def update_screen
    @viewport.tone.set(-dimness, -dimness, -dimness)
  end
  #--------------------------------------------------------------------------
  # * Aquisição do nível de escuridão
  #--------------------------------------------------------------------------
  def dimness
    (@power * 6).to_i
  end
  #--------------------------------------------------------------------------
  # * Atualização do sprite
  #     sprite : sprite
  #--------------------------------------------------------------------------
  def update_sprite(sprite)
    sprite.ox = @ox
    sprite.oy = @oy
    case @type
    when :rain
      update_sprite_rain(sprite)
    when :storm
      update_sprite_storm(sprite)
    when :snow
      update_sprite_snow(sprite)
    end
    create_new_particle(sprite) if sprite.opacity < 64
  end
  #--------------------------------------------------------------------------
  # * Atualização do sprite de chuva
  #     sprite : sprite
  #--------------------------------------------------------------------------
  def update_sprite_rain(sprite)
    sprite.bitmap = @rain_bitmap
    sprite.x -= 1
    sprite.y += 6
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Atualização do sprite de tempestade
  #     sprite : sprite
  #--------------------------------------------------------------------------
  def update_sprite_storm(sprite)
    sprite.bitmap = @storm_bitmap
    sprite.x -= 3
    sprite.y += 6
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Atualização do sprite de neve
  #     sprite : sprite
  #--------------------------------------------------------------------------
  def update_sprite_snow(sprite)
    sprite.bitmap = @snow_bitmap
    sprite.x -= 1
    sprite.y += 3
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Criação de uma nova partícula
  #     sprite : sprite
  #--------------------------------------------------------------------------
  def create_new_particle(sprite)
    sprite.x = rand(Graphics.width + 100) - 100 + @ox
    sprite.y = rand(Graphics.height + 200) - 200 + @oy
    sprite.opacity = 160 + rand(96)
  end
end
