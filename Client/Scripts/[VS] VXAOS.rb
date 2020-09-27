#==============================================================================
# ** VXAOS
#------------------------------------------------------------------------------
#  Este módulo é uma ponte para abrir DLLs.
#------------------------------------------------------------------------------
#  Autor: Cidiomar
#==============================================================================

def typedef(signature)
  VXAOS::API.typedef(signature)
end

def c_function(dll, signature)
  VXAOS::API.new_func(dll, signature)
end

#==============================================================================
# ** VXAOS
#==============================================================================
module VXAOS
  
  DLL = 'System/VXAOS.dll'
  typedef 'unsigned long  VALUE'
  typedef 'unsigned long  ID'
  typedef 'int            BOOL'
  typedef 'unsigned char  uint8_t'
  typedef 'unsigned short uint16_t'
  typedef 'unsigned int   uint32_t'
  typedef 'unsigned int   uint'
  typedef 'unsigned int   UINT'
  typedef 'UINT           HANDLE'
  typedef 'HANDLE         HWND'
  System__setCompatibility = c_function(DLL, 'void System__setCompatibility()')
  System__setCompatibility.call
  System__getHWND = c_function(DLL, 'UINT System__getHWND()')
  HWND = System__getHWND.call
  MD5_Crypt = c_function(DLL, 'void MD5_Crypt(const char *, int, char *)')
  
  def self.md5(string)
    buff = DL::CPtr.new(DL.malloc(33), 32)
    MD5_Crypt.call(string, string.length, buff)
    buff.to_str
  end

end

#==============================================================================
# ** DL
#==============================================================================
module DL

  LIBC_memcpy = c_function('msvcrt.dll', 'void memcpy(void*, void*, uint)')

  def self.memcpy(src, dst, sz)
    LIBC_memcpy.call(src, dst, sz)
  end

end
