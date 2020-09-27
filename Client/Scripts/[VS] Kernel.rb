#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Este script lida com as notas do banco de dados. Ele
# também é executado no servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Kernel
  
  def enum(constant_names)
    Module.new do |mod|
      constant_names.each_with_index{ |const, i| mod.const_set(const.to_s, i) }
    end
  end
  
end

#==============================================================================
# ** Note
#==============================================================================
module Note
  
  def self.read_graphics(note)
    note.each_line.map{ |line| line.split('=')[1] }.map{ |graphic| graphic.split(',').map{ |graphic| split(graphic) }}
  end
  
  def self.read_paperdoll(note)
    split((note[/Paperdoll=(.*)/, 1] || ''))
  end
  
  def self.read_boolean(str, note)
    note[/#{str}=(....)/, 1] == 'true'
  end
  
  def self.read_number(str, note)
    note[/#{str}=(.*)/, 1].to_i
  end
  
  private
  
  def self.split(str)
    ary = str.split('/')
    return ary if ary.empty?
    return ary[0].chomp, ary[1].to_i
  end
  
end
