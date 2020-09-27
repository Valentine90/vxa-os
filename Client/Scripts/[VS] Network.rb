#==============================================================================
# ** Network
#------------------------------------------------------------------------------
#  Esta classe lida com a rede.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Network
  
  include Send_Data, Handle_Data
  
  attr_reader   :motd, :actors, :vip_time 
  
  def initialize
    @group = Enums::Group::STANDARD
    @in_game = false
    @socket = nil
    @vip_time = nil
    @message = nil
    @m_size = 0
    @player_id = -1
    @motd = ''
    @actors = {}
  end
  
  def connect
    @socket = SocketLib.new(Configs::HOST, Configs::PORT)
  end
  
  def disconnect
    return unless connected?
    @socket.close
    @socket = nil
  end
  
  def connected?
    @socket
  end
  
  def connection_lost?(status)
    status == -1
  end
  
  def standard_group?
    @group == Enums::Group::STANDARD
  end
  
  def vip?
    @vip_time > Time.now
  end
  
  def server_online?
    retry_count = 0
    successful = false
    while !successful && retry_count < 2
      begin
        connect
        successful = true
      rescue
        retry_count += 1
      end
    end
    successful
  end
  
  def update
    # Se a conexão não foi fechada e há dados para ler
    until !@socket || @socket.eof?
      if @message
        receive_message_gradually
      else
        receive_full_message
      end
    end
  end
  
  def receive_full_message
    b_size = @socket.recv_non_block(2)
    if connection_lost?(b_size) || b_size.size < 2
      $alert_msg ||= Vocab::ConnectionFailed
      DataManager.back_login
      return
    end
    size = b_size.unpack('s')[0]
    message = @socket.recv_non_block(size)
    if message.size - 4 == size
      handle_messages(message)
    else
      @message = message
      @m_size = size
    end
  end
  
  def receive_message_gradually
    message = @socket.recv_non_block(@m_size - @message.size)
    @message << message
    if @message.size - 4 == @m_size
      handle_messages(@message)
      @message = nil
    end
  end
  
end
