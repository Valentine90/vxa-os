#==============================================================================
# ** RGSS
#------------------------------------------------------------------------------
# Este script lida com as classes necessárias para carregar os mapas e os
#scripts do cliente
#------------------------------------------------------------------------------
# Autor: zh99998
#==============================================================================

class Table
  def initialize(xsize, ysize = 1, zsize = 1)
    @xsize = xsize
    @ysize = ysize
    @zsize = zsize
    @data = Array.new(@xsize * @ysize * @zsize, 0)
  end

  def resize(xsize, ysize = 1, zsize = 1)
  end

  def [](x, y = 0, z = 0)
    return nil if x >= @xsize or y >= @ysize
    @data[x + y * @xsize + z * @xsize * @ysize]
  end

  def []=(x, y = 0, z = 0, v)
    @data[x + y * @xsize + z * @xsize * @ysize]=v
  end

  def self._load(s)
    Table.new(1).instance_eval {
      @size, @xsize, @ysize, @zsize, xx, *@data = s.unpack('LLLLLS*')
      self
    }
  end

  def _dump(d = 0)
    [@size, @xsize, @ysize, @zsize, @xsize * @ysize * @zsize, *@data].pack('LLLLLS*')
  end

  attr_reader :xsize
  attr_reader :ysize
  attr_reader :zsize
end

#==============================================================================
# ** Color
#==============================================================================
class Color
  def initialize(red=0, green=0, blue=0, alpha = 255)
    @red   = red
    @blue  = blue
    @green = green
    @alpha = alpha
  end

  def set(red, blue=0, green=0, alpha = 255)
    if red.is_a? Color
      color  = red
      @red   = color.red
      @blue  = color.blue
      @green = color.green
      @alpha = color.alpha
    else
      @red   = red
      @blue  = blue
      @green = green
      @alpha = alpha
    end
    return self
  end

  def to_s()
    "(#{@red}, #{@blue}, #{@green}, #{@alpha})"
  end

  def _dump(depth = 0)
    [@red, @green, @blue, @alpha].pack('D*')
  end

  def self._load(string)
    self.new(*string.unpack('D*'))
  end

  def red=(val)
    @red = [[0, val].max, 255].min
  end

  def blue=(val)
    @blue = [[0, val].max, 255].min
  end

  def green=(val)
    @green = [[0, val].max, 255].min
  end

  def alpha=(val)
    @alpha = [[0, val].max, 255].min
  end

  def ==(other)
    raise TypeError.new("can't convert #{other.class} into Color") unless self.class == other.class
    return @red == other.red &&
        @green == other.green &&
        @blue == other.blue &&
        @alpha == other.alpha
  end

  def ===(other)
    raise TypeError.new("can't convert #{other.class} into Color") unless self.class == other.class
    return @red == other.red &&
        @green == other.green &&
        @blue == other.blue &&
        @alpha == other.alpha
  end

  def egl?(other)
    raise TypeError.new("can't convert #{other.class} into Color") unless self.class == other.class
    return @red == other.red &&
        @green == other.green &&
        @blue == other.blue &&
        @alpha == other.alpha
  end

  attr_accessor :red
  attr_accessor :blue
  attr_accessor :green
  attr_accessor :alpha
end


#==============================================================================
# ** Tone
#==============================================================================
class Tone
  def initialize(red = 0, green = 0, blue = 0, gray = 0)
    self.red, self.green, self.blue, self.gray = red, green, blue, gray
  end

  def set(red, green=0, blue=0, gray=0)
    if red.is_a? Tone
      tone   = red
      @red   = tone.red
      @green = tone.green
      @blue  = tone.blue
      @gray  = tone.gray
    else
      @red   = red
      @green = green
      @blue  = blue
      @gray  = gray
    end
  end

  def red=(value)
    @red = [[-255, value].max, 255].min
  end

  def green=(value)
    @green = [[-255, value].max, 255].min
  end

  def blue=(value)
    @blue = [[-255, value].max, 255].min
  end

  def gray=(value)
    @gray = [[0, value].max, 255].min
  end

  def to_s
    "(#{red}, #{green}, #{blue}, #{gray})"
  end

  def blend(tone)
    self.clone.blend!(tone)
  end

  def blend!(tone)
    self.red   += tone.red
    self.green += tone.green
    self.blue  += tone.blue
    self.gray  += tone.gray
    self
  end

  def _dump(marshal_depth = -1)
    [@red, @green, @blue, @gray].pack('E4')
  end

  def self._load(data)
    new(*data.unpack('E4'))
  end

  attr_accessor :red
  attr_accessor :green
  attr_accessor :blue
  attr_accessor :gray
end

#==============================================================================
# ** Font
#==============================================================================
class Font
  @@cache = {}

  def initialize(arg_name= @@default_name, arg_size= @@default_size)
    @name = arg_name
    @size = arg_size
    @bold = @@default_bold
    @italic = @@default_italic
    @color = @@default_color
  end

  def Font.exist?(arg_font_name)
    font_key = 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts'
    reg_open_keyex = Win32API.new('Advapi32', 'RegOpenKeyEx', 'lpllp', 'l')
    reg_enum_value = Win32API.new('Advapi32', 'RegEnumValue', 'llppiiii', 'l')
    reg_close_key = Win32API.new('Advapi32', 'RegCloseKey', 'l', 'l')
    open_key = [0].pack('V')
    reg_open_keyex.call(0x80000002, font_key, 0, 0x20019, open_key)
    open_key = (open_key + [0].pack('V')).unpack('V').first
    buffer = "\0"*256
    buff_size = [255].pack('l')
    key_i = 0
    font_names = []
    while (reg_enum_value.call(open_key, key_i, buffer, buff_size, 0, 0, 0, 0).zero?)
      font_names << buffer[0, buff_size.unpack('l').first].sub(/\s\(.*\)/, '')
      buff_size = [255].pack('l')
      key_i += 1
    end
    reg_close_key.call(open_key)
    return font_names.include?(arg_font_name)
  end

  def entity
    result = @@cache[[@name, @size]] ||= SDL::TTF.open('wqy-microhei.ttc', @size)
    result.style = (@bold ? SDL::TTF::STYLE_BOLD : 0) | (@italic ? SDL::TTF::STYLE_ITALIC : 0)
    result
  end

  class <<self
    [:name, :size, :bold, :italic, :color, :outline, :shadow, :out_color].each { |attribute|
      name = 'default_' + attribute.to_s
      define_method(name) { class_variable_get('@@'+name) }
      define_method(name+'=') { |value| class_variable_set('@@'+name, value) }
    }
  end

  @@default_name = "Arial"
  @@default_size = 22
  @@default_bold = false
  @@default_italic = false
  @@default_color = Color.new(255, 255, 255, 255)

  attr_accessor :name
  attr_accessor :size
  attr_accessor :bold
  attr_accessor :italic
  attr_accessor :outline
  attr_accessor :shadow
  attr_accessor :color
  attr_accessor :out_color
end

def load_data(file_name)
	File.open("#{DATA_PATH}/#{file_name}", 'rb') { |f| Marshal.load(f) }
end
