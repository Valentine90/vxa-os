#==============================================================================
# ** VXAOS_Base
#------------------------------------------------------------------------------
#  Este módulo é uma ponte para abrir DLLs.
#------------------------------------------------------------------------------
#  Autor: Cidiomar
#==============================================================================

module DL
  
  module CParser
    
    def self.parse_struct_signature(signature, tymap = nil)
      signature = signature.split(/\s*,\s*/) if( signature.is_a?(String) )
      mems, tys = [], []
      signature.each { |msig|
        tks = msig.split(/\s+(\*)?/)
        ty = tks[0..-2].join(" ")
        member = tks[-1]
        case ty
        when /\[(\d+)\]/
          n = $1.to_i
          ty.gsub!(/\s*\[\d+\]/,"")
          ty = [ty, n]
        when /\[\]/
          ty.gsub!(/\s*\[\]/, "*")
        end
        case member
        when /\[(\d+)\]/
          ty = [ty, $1.to_i]
          member.gsub!(/\s*\[\d+\]/,"")
        when /\[\]/
          ty = ty + "*"
          member.gsub!(/\s*\[\]/, "")
        end
        mems.push(member)
        tys.push(parse_ctype(ty, tymap))
      }
      return tys, mems
    end
    
    def self.parse_signature(signature, tymap = nil)
      tymap ||= {}
      signature = signature.gsub(/\s+/, " ").strip
      case signature
      when /^([\w@\*\s]+)\(([\w\*\s\,\[\]]*)\)$/
        ret = $1
        (args = $2).strip!
        ret = ret.split(/\s+/)
        args = args.split(/\s*,\s*/)
        func = ret.pop
        if( func =~ /^\*/ )
          func.gsub!(/^\*+/,"")
          ret.push("*")
        end
        ret  = ret.join(" ")
        return [func, parse_ctype(ret, tymap), args.collect{ |arg| parse_ctype(arg, tymap) }]
      else
        raise(RuntimeError,"can't parse the function prototype: #{signature}")
      end
    end
    
    def self.parse_ctype(ty, tymap = nil)
      tymap ||= {}
      case ty
      when Array
        return [parse_ctype(ty[0], tymap), ty[1]]
      when "void"
        return TYPE_VOID
      when "char"
        return TYPE_CHAR
      when "unsigned char"
        return  -TYPE_CHAR
      when "short"
        return TYPE_SHORT
      when "unsigned short"
        return -TYPE_SHORT
      when "int"
        return TYPE_INT
      when "unsigned int", 'uint'
        return -TYPE_INT
      when "long"
        return TYPE_LONG
      when "unsigned long"
        return -TYPE_LONG
      when "long long"
        if( defined?(TYPE_LONG_LONG) )
          return TYPE_LONG_LONG
        else
          raise(RuntimeError, "unsupported type: #{ty}")
        end
      when "unsigned long long"
        if( defined?(TYPE_LONG_LONG) )
          return -TYPE_LONG_LONG
        else
          raise(RuntimeError, "unsupported type: #{ty}")
        end
      when "float"
        return TYPE_FLOAT
      when "double"
        return TYPE_DOUBLE
      when /\*/, /\[\s*\]/
        return TYPE_VOIDP
      else
        if(tymap[ty])
          return parse_ctype(tymap[ty], tymap)
        else
          raise(DLError, "unknown type: #{ty}")
        end
      end
    end
    
  end
  
end

#==============================================================================
# ** VXAOS
#==============================================================================
module VXAOS
  
  TYPES_SIZE = {
    /([cC])([0-9]*)/           => 1,
    /([nSsv])[_]*([0-9]*)/     => 2,
    /([IiLlNPpV])[_]*([0-9]*)/ => 4,
    /([Qq])([0-9]*)/           => 8,
    /([efFg])([0-9]*)/         => 4,
    /([dDEG])([0-9]*)/         => 8
  }
  
  def self.sizeof_fmt(sizes_str)
    sizes_str = sizes_str.to_s
    size = 0
    TYPES_SIZE.each do |reg, s|
      while (m = sizes_str.match(reg))
        sizes_str.sub!(reg, '')
        m = m.to_a
        if m[2].empty?
          size += s
        else
          size += s * m[2].to_i
        end
      end
    end
    size
  end
  
  class API
    
    class << self;  def new(*args);  self;  end;  end
    
    DLL = {}
    FUNTIONS = {}
    BASE_TYPES = [
      'void', 'char', 'unsigned char', 'short', 'unsigned short', 'int',
      'unsigned int', 'uint', 'long', 'unsigned long', 'long long',
      'unsigned long long', 'float', 'double'
    ]
    TYPEMAP = {}
    
    class Function
      
      attr_reader :dll, :args, :type, :name
      
      def initialize(dll, handle, ctype, name, args)
        @dll = dll
        @args = args
        @type = ctype
        @name = name
        @cfunc = DL::CFunc.new(handle, ctype.abs, name, :stdcall)
      end
      
      def call(*args)
        c_args = []
        if @args.length == 1 and @args[0] == DL::TYPE_VOID
        else
          @args.each_with_index do |arg, i|
            x = args[i]
            if arg == DL::TYPE_VOIDP
              if x.is_a?(Integer)
                c_args << x
              elsif x.is_a?(DL::CPtr)
                c_args << x.to_i
              elsif x.is_a?(String)
                c_args << [x == 0 ? nil : x].pack("p").unpack("l!*")[0]
              else
                c_args << (x.object_id << 1)
              end
            else
              c_args << wrap_value(x, arg)
            end
          end
        end
        ret = @cfunc.call(c_args)
        if @type == DL::TYPE_VOID
          return nil
        else
          if @type == DL::TYPE_VOIDP
            return DL::CPtr.new(ret)
          else
            return wrap_value(ret, @type)
          end
        end
      end
      
      def wrap_value(val, ty)
        case ty
        when -DL::TYPE_CHAR
          [val].pack("c").unpack("C")[0]
        when -DL::TYPE_SHORT
          [val].pack("s!").unpack("S!")[0]
        when -DL::TYPE_INT
          [val].pack("i!").unpack("I!")[0]
        when -DL::TYPE_LONG
          [val].pack("l!").unpack("L!")[0]
        when -DL::TYPE_LONG_LONG
          [val].pack("q!").unpack("Q!")[0]
        when DL::TYPE_CHAR
          [val].pack("C").unpack("c")[0]
        when DL::TYPE_SHORT
          [val].pack("S!").unpack("s!")[0]
        when DL::TYPE_INT
          [val].pack("I!").unpack("i!")[0]
        when DL::TYPE_LONG
          [val].pack("L!").unpack("l!")[0]
        when DL::TYPE_LONG_LONG
          [val].pack("Q!").unpack("q!")[0]
        else
          val
        end
      end
    end
    
    def self.new_func(dllname, signature)
      symname, ctype, arglist = DL::CParser.parse_signature(signature, TYPEMAP)
      return FUNTIONS[[dllname, symname]] if FUNTIONS[[dllname, symname]]
      handle = DLL[dllname] ||= DL.dlopen(dllname)
      FUNTIONS[[dllname, symname]] = Function.new(dllname, handle[symname], ctype, symname, arglist)
    end
    
    def self.typedef(signature)
      signature = signature.split(' ')
      new = signature.pop
      old = signature.join(' ')
      if BASE_TYPES.include?(old) or TYPEMAP.include?(old)
        if DL::CParser.parse_ctype(old, TYPEMAP) != nil
          TYPEMAP[new] = old
          TYPEMAP[new] = TYPEMAP[old]  until BASE_TYPES.include?(TYPEMAP[new])
        end
      else
        raise "Base type #{old} not defined!\n"
      end
    end
    
    module Importer
      
      module_function
      
      def extern(dllname, signature)
        f = VXAOS::API.new_func(dllname, signature)
        begin
          /^(.+?):(\d+)/ =~ caller.first
          file, line = $1, $2.to_i
        rescue
          file, line = __FILE__, __LINE__+3
        end
        module_eval(<<-EOS, file, line)
          def #{f.name}(*args, &block)
            @func_map['#{f.name}'].call(*args,&block)
          end
        EOS
        module_function(f.name)
        f
      end
      
    end
    
  end
  
end
