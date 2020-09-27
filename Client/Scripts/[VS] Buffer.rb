#==============================================================================
# ** Buffer
#------------------------------------------------------------------------------
#  Esta classe lê e escreve dados binários. Ela é utilizada
# especialmente para reduzir a quantidade de bytes trocados
# pelo cliente e servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Buffer_Writer
  
  def initialize
    @buffer = []
    @pack = ''
  end
  
  def write_byte(byte)
    write(byte, 'c')
  end
  
  def write_boolean(value)
    write_byte(value ? 1 : 0)
  end
  
  def write_short(short)
    write(short, 's')
  end
  
  def write_int(int)
    write(int, 'i')
  end
  
  def write_long(long)
    # q representa um número de 64 bits, diferentemente
    #de l que representa um número de 32 bits
    write(long, 'q')
  end
  
  def write_string(str)
    write_short(str.bytesize)
    str.each_byte { |c| write_byte(c) }
  end
  
  def to_s
    @buffer.pack(@pack)
  end
  
  private
  
  def write(value, format)
    @buffer << value
    @pack << format
  end
  
end

#==============================================================================
# ** Buffer_Reader
#==============================================================================
class Buffer_Reader
  
  def initialize(str)
    # O método to_a é usado, pois, nesta versão do Ruby,
    #bytes retorna Enumerator em vez de Array
    @bytes = str.bytes.to_a
  end
  
  def read_byte
    @bytes.shift
  end
  
  def read_boolean
    read_byte == 1
  end
  
  def read_short
    read(2, 's')
  end
  
  def read_int
    read(4, 'i')
  end
  
  def read_long
    read(8, 'q')
  end
  
  def read_string
    size = read_short
    read(size, "A#{size}")
  end
  
  def read_time
    Time.new(read_short, read_byte, read_byte)
  end
  
  private
  
  def read(n, format)
    @bytes.shift(n).pack('C*').unpack(format)[0]
  end
  
end
