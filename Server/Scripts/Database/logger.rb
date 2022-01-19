#==============================================================================
# ** Logger
#------------------------------------------------------------------------------
#  Esta classe grava informações importantes do servidor, como erros e comandos
# executados por administradores e monitores.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Logger

	def initialize
		@text = {}
	end
	
	def add(type, color, text)
		type = type.is_a?(Integer) ? type == Enums::Group::ADMIN ? 'Admin' : 'Monitor' : type
		day = Time.now.strftime("#{type}-%d-%b-%Y")
		@text[day] = "#{@text[day]}#{Time.now.strftime("%X: #{text}")}\n"
		puts(text.colorize(color))
	end

	def save_all
		@text.each do |day, text|
			file = File.open("Logs/#{day}.txt", 'a+')
			file.write(text)
			file.close
		end
		@text.clear
	end
	
end
