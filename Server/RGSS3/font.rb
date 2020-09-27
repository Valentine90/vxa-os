#==============================================================================
# ** Font
#------------------------------------------------------------------------------
# Autor: zh99998
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