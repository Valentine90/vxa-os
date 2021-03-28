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
require 'sequel'
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
require './Scripts/game_switches'
require './Scripts/game_account'
require './Scripts/game_party'
require './Scripts/game_client'
require './Scripts/game_interpreter'
require './Scripts/game_event'

EventMachine.run do
	# Adia o processamento do sinal para que a chamada que salva os dados no banco de dados MySQL
	#seja considerada segura pelo Ruby, evitando que ela seja bloqueada dentro do tratador de trap
	Signal.trap('INT') { EM.add_timer(0) { $network.save_game_data; EventMachine.stop } }
	Signal.trap('TERM') { EM.add_timer(0) { $network.save_game_data; EventMachine.stop } }
	$network = Network.new
	# Carrega dados, utilizando-se das informações da classe Network, após $network ser definido
	$network.load_game_data
	EventMachine.start_server(SERVER_HOST, SERVER_PORT, Game_Client)
	# Reduz o uso da CPU
	EventMachine::PeriodicTimer.new(0.08) { $network.update }
	EventMachine::PeriodicTimer.new(SAVE_DATA_TIME) { $network.save_game_data }
end
