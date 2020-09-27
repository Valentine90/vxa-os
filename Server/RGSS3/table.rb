#==============================================================================
# ** Table
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