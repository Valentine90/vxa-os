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
require 'json'

require './Data/rpg'
require './Data/rgss'

require_relative 'Kernel/scripts'
require_relative 'Kernel/enums'
require_relative 'Kernel/structs'
require_relative 'Database/logger'
require_relative 'Database/game_data'
require_relative 'Database/database'
require_relative 'Guild/game_guild'
require_relative 'Combat/game_battle'
require_relative 'Combat/game_client'
require_relative 'Combat/game_enemy'
require_relative 'Trade/game_trade'
require_relative 'Party/game_party'
require_relative 'Network/buffer'
require_relative 'Network/send_data'
require_relative 'Network/handle_data'
require_relative 'Network/game_general'
require_relative 'Network/game_commands'
require_relative 'Network/network'
require_relative 'Client/game_character'
require_relative 'Client/game_bank'
require_relative 'Client/game_quest'
require_relative 'Client/game_switches'
require_relative 'Client/game_account'
require_relative 'Client/game_client'
require_relative 'Map/game_moveevent'
require_relative 'Map/game_interpreter'
require_relative 'Map/game_event'
require_relative 'Map/game_map'

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
