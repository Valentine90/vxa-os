#==============================================================================
# ** Account_Editor
#------------------------------------------------------------------------------
#  Este script lida com o editor temporário de contas.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

load './configs.ini'

require 'sequel'
require 'colorize'
require 'digest'

#==============================================================================
# ** Database
#==============================================================================
module Database

	def self.sql_client
		if DATABASE_PATH.empty?
			Sequel.connect("mysql2://#{DATABASE_USER}:#{DATABASE_PASS}@#{DATABASE_HOST}:#{DATABASE_PORT}/#{DATABASE_NAME}")
		else
			Sequel.connect("sqlite://Data/#{DATABASE_PATH}.db")
		end
  end
  
	def self.account_exist?(user)
		s_client = sql_client
		account = s_client[:accounts].select(:id).where(:username => user)
		s_client.disconnect
		!account.empty?
  end
  
  def self.change_vip_time(user, days)
    s_client = sql_client
    vip_time = [s_client[:accounts].select(:vip_time).where(:username => user).single_value, Time.now.to_i].max
    s_client[:accounts].where(:username => user).update(:vip_time => vip_time + days)
    s_client.disconnect
    puts("A conta #{user} agora tem #{((vip_time + days - Time.now.to_i) / 86400).to_i} dias VIP.".colorize(:green))
  end

  def self.change_group(user, group)
    s_client = sql_client
    s_client[:accounts].where(:username => user).update(:group => group)
    s_client.disconnect
  end

  def self.change_password(user, pass)
    s_client = sql_client
    s_client[:accounts].where(:username => user).update(:password => Digest::MD5.hexdigest(pass))
    s_client.disconnect
  end

end

#==============================================================================
# ** Account_Editor
#==============================================================================
module Account_Editor

  def self.start
    puts('Digite o nome da conta que você quer alterar:')
    user = gets.chomp
    if Database.account_exist?(user)
      puts('O que você quer mudar? [Tempo vip, grupo, senha]')
      type = gets.chomp.downcase
      case type
      when 'tempo vip', 'vip'
        change_vip_time(user)
      when 'grupo'
        change_group(user)
      when 'senha'
        change_password(user)
      else
        puts('Comando inválido!'.colorize(:red))
      end
    else
      puts('Esta conta não existe!'.colorize(:red))
    end
    start
  end

  def self.change_vip_time(user)
    puts('Quantos dias VIP você quer adicionar?')
    days = gets.chomp.to_i
    if days > 0
      Database.change_vip_time(user, days * 86400)
    else
      puts('Você digitou um número inválido!'.colorize(:red))
      change_vip_time(user)
    end
  end

  def self.change_group(user)
    puts('Qual grupo? [0 = padrão, 1 = monitor, 2 = administrador]')
    group = gets.to_i
    case group
    when 0
      Database.change_group(user, group)
      puts("#{user} agora é um jogador padrão.".colorize(:green))
    when 1
      Database.change_group(user, group)
      puts("#{user} agora é um monitor.".colorize(:green))
    when 2
      Database.change_group(user, group)
      puts("#{user} agora é um administrador.".colorize(:green))
    else
      puts('Você digitou um número inválido!'.colorize(:red))
      change_group(user)
    end
  end

  def self.change_password(user)
    puts('Digite a nova senha:')
    pass = gets.chomp
    Database.change_password(user, pass)
    puts("A senha da conta #{user} foi alterada!".colorize(:green))
  end

end

Account_Editor.start
