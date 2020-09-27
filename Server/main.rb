#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  Este script inicia o processamento.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

load './configs.ini'
load './vocab.ini'

require 'eventmachine'
require 'colorize'
require 'zlib'
require './RGSS3/rgss'
require './Scripts/scripts'
require './Scripts/enums'
require './Scripts/buffer'
require './Scripts/game_character'
require './Scripts/game_map'
require './Scripts/logger'
require './Scripts/send_data'
require './Scripts/handle_data'
require './Scripts/game_general'
require './Scripts/game_data'
require './Scripts/game_guild'
require './Scripts/network'
require './Scripts/structs'
require './Scripts/database'
require './Scripts/game_battle'
require './Scripts/game_moveevent'
require './Scripts/game_trade'
require './Scripts/game_bank'
require './Scripts/game_quest'
require './Scripts/game_account'
require './Scripts/game_party'
require './Scripts/game_client'
require './Scripts/game_interpreter'
require './Scripts/game_event'

EventMachine.run do
	Signal.trap('INT') { $server.save_game_data; EventMachine.stop  }
	Signal.trap('TERM') { $server.save_game_data; EventMachine.stop }
	$server = Server.new
	# Carrega dados, utilizando-se das informações da classe Server, após $server ser definido
	$server.load_game_data
	EventMachine.start_server(HOST, PORT, Game_Client)
	# Reduz o uso da CPU
	EventMachine::PeriodicTimer.new(0.08) { $server.update }
	EventMachine::PeriodicTimer.new(SAVE_DATA_TIME) { $server.save_game_data }
end
