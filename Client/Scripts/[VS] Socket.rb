#==============================================================================
# ** Socket
#------------------------------------------------------------------------------
#  Esta classe lida com o soquete de rede. Ela estabelece
# uma conexão entre o cliente e o servidor.
#------------------------------------------------------------------------------
#  Autor: Cidiomar
#==============================================================================

class SocketError < StandardError

  ENOASSOCHOST = 'getaddrinfo: nenhum endereço associado ao nome do host.'
  SocketLib__GetLastError = c_function('System/VXAOS.dll', 'int SocketLib__GetLastError()')

  def self.raise(errno = SocketLib__GetLastError.call)
    Kernel.raise Errno.const_get(Errno.constants.detect { |c| Errno.const_get(c).new.errno == errno }), '', caller(2)
  end

  def self.raise_no_assoc_host
    Kernel.raise SocketError, ENOASSOCHOST, caller(2)
  end
  
end

#==============================================================================
# ** SocketLib
#==============================================================================
class SocketLib

  typedef 'unsigned int SOCKET'
  dll = 'System/VXAOS.dll'
  SocketLib__setup = c_function(dll, 'int SocketLib__setup()')
  SocketLib__connect = c_function(dll, 'int SocketLib__connect(const char *, const char *, SOCKET *)')
  SocketLib__close = c_function(dll, 'int SocketLib__close(SOCKET)')
  SocketLib__send = c_function(dll, 'int SocketLib__send(SOCKET, char*, int)')
  SocketLib__recv = c_function(dll, 'int SocketLib__recv(SOCKET, char*, int)')
  SocketLib__recv_non_block = c_function(dll, 'int SocketLib__recv_non_block(SOCKET, char*, int)')
  SocketLib__TestHost = c_function(dll, 'int SocketLib__TestHost(const char *, const char *)')
  SocketLib__eof = c_function(dll, 'int SocketLib__eof(SOCKET)')

  def initialize(ip, port)
    _port = port.to_s
    @socket_id = [0, 0, 0, 0].pack('L')
    err = SocketLib__connect.call(ip, _port, @socket_id)
    unless err == 0
      if err == -1
        SocketError.raise_no_assoc_host
      else
        SocketError.raise
      end
    end
    @socket_id = @socket_id.unpack('L')[0]
  end
  
  def send(data)
    data = data.to_s
    return 0 if data.empty?
    if (ss = SocketLib__send.call(@socket_id, data, data.bytesize)) < 0
      SocketError.raise
    end
    ss
  end
  
  def recv(maxlen)
    buff = "\0" * (maxlen.to_i + 4)
    r_len = SocketLib__recv.call(@socket_id, buff, maxlen)
    SocketError.raise if r_len < 0
    if r_len == maxlen
      buff
    else
      buff[0...r_len]
    end
  end
  
  def recv_non_block(maxlen)
    buff = "\0" * (maxlen.to_i + 4)
    r_len = SocketLib__recv_non_block.call(@socket_id, buff, maxlen)
    return -1 if r_len <= 0
    if r_len == maxlen
      buff
    else
      buff[0...r_len]
    end
  end
  
  def eof?
    SocketLib__eof.call(@socket_id) == 0
  end
  
  def close
    SocketLib__close.call(@socket_id)
  end
  
  class << self
    def test_host(ip, port)
      if (SocketLib__TestHost.call(ip, port) == 1)
        return true
      else
        SocketError::SocketLib__GetLastError.call()
        return false
      end
    end
  end
  
  def self.ping(server)
    IO.popen("ping -n 1 #{server}").close
    $?.exitstatus == 0
  end
  
  if SocketLib__setup.call != 0
    SocketError.raise
  end
  
end
