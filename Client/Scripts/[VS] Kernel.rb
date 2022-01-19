#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Este script lida com as notas do banco de dados e o leitor
# de arquivos INI. Ele também é executado no servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Kernel
  
  def enum(constant_names)
    Module.new do |mod|
      n = 0
      constant_names.each_with_index do |const, i|
        if constant_names[i + 1].to_i > 0
          n = constant_names[i + 1].to_i
          # Remove o próximo elemento sem causar
          #problemas na iteração
          constant_names.delete_at(i + 1)
        end
        mod.const_set(const.to_s, n)
        n += 1
      end
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

#==============================================================================
# ** INI
#==============================================================================
class INI
  
  attr_reader :filename
  
  def initialize(filename)
    @filename = filename
    @data = {}
    create_properties
  end
  
  def create_properties
    str = File.open(@filename, 'r:bom|UTF-8', &:read)
    key = nil
    # Divide str em substrings com base apenas na quebra
    #de linha, e não nos espaços em branco
    str.split("\n").each do |line|
      if line.start_with?('[')
        key = line[1...line.size - 1]
        @data[key] = {}
      # Se não for uma linha em branco ou comentário
      elsif !line.strip.empty? && !line.include?(';')
        name, value = line.split('=')
        @data[key][name.rstrip] = parse(value.lstrip)
      end
    end
  end
  
  def [](key)
    @data[key]
  end
  
  def each(&block)
    @data.each { |key, property| yield(key, property) }
  end
  
  def parse(value)
    if value =~ /^([\d_]+)$/
      return value.to_i
    elsif value =~ /^([\d_]*\.\d+)$/
      return value.to_f
    elsif value =~ /true|false/i
      return value.downcase == 'true'
    else
      # O gsub, em vez de delete, remove aspas simples e duplas e evita
      #que o caractere \ seja removido do restante do texto
      return value.gsub(/\"|'/, '')
    end
  end
  
end
