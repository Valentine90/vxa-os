#==============================================================================
# ** Enums
#------------------------------------------------------------------------------
#  Este módulo lida com as enumerações. Ele também é
# executado no servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Enums
  
  # Sexos
  Sex = enum %w(
    MALE
    FEMALE
  )
  
  # Pacotes enviados pelo cliente para o servidor e vice-versa
  Packet = enum %w(
    NONE
    LOGIN
    FAIL_LOGIN
    CREATE_ACCOUNT
    CREATE_ACTOR
    FAIL_CREATE_ACTOR
    ACTOR
    REMOVE_ACTOR
    USE_ACTOR
    MOTD
    PLAYER_DATA
    REMOVE_PLAYER
    PLAYER_MOVE
    MAP_MSG
    CHAT_MSG
    ALERT_MSG
    PLAYER_ATTACK
    ATTACK_PLAYER
    ATTACK_ENEMY
    USE_ITEM
    USE_SKILL
    ANIMATION
    BALLOON
    USE_HOTBAR
    ENEMY_REVIVE
    EVENT_DATA
    EVENT_MOVE
    ADD_DROP
    REMOVE_DROP
    ADD_PROJECTILE
    PLAYER_VITALS
    PLAYER_EXP
    PLAYER_STATE
    PLAYER_BUFF
    PLAYER_ITEM
    PLAYER_GOLD
    PLAYER_PARAM
    PLAYER_EQUIP
    PLAYER_SKILL
    PLAYER_CLASS
    PLAYER_SEX
    PLAYER_GRAPHIC
    PLAYER_POINTS
    PLAYER_HOTBAR
    TARGET
    TRANSFER
    OPEN_FRIENDS
    ADD_FRIEND
    REMOVE_FRIEND
    OPEN_CREATE_GUILD
    CREATE_GUILD
    OPEN_GUILD
    GUILD_NAME
    GUILD_LEADER
    GUILD_NOTICE
    REMOVE_GUILD_MEMBER
    LEAVE_GUILD
    JOIN_PARTY
    LEAVE_PARTY
    DISSOLVE_PARTY
    CHOICE
    OPEN_BANK
    BANK_ITEM
    BANK_GOLD
    CLOSE_WINDOW
    OPEN_SHOP
    BUY_ITEM
    SELL_ITEM
    OPEN_TELEPORT
    CHOICE_TELEPORT
    EVENT_COMMAND
    NEXT_COMMAND
    REQUEST
    ACCEPT_REQUEST
    DECLINE_REQUEST
    TRADE_ITEM
    TRADE_GOLD
    ADD_QUEST
    FINISH_QUEST
    VIP_DAYS
    LOGOUT
    ADMIN_COMMAND
    SWITCH
    VARIABLE
    SELF_SWITCH
    NET_SWITCHES
  )
  
  # Grupos
  Group = enum %w(
    STANDARD
    MONITOR
    ADMIN
  )
  
  # Direções
  module Dir
    DOWN_LEFT  = 1
    DOWN       = 2
    DOWN_RIGHT = 3
    LEFT       = 4
    RIGHT      = 6
    UP_LEFT    = 7
    UP         = 8
    UP_RIGHT   = 9
  end
  
  # Bate-papo
  Chat = enum %w(
    MAP
    GLOBAL
    PARTY
    GUILD
    PRIVATE
  )
  
  # Entrada
  Login = enum %w(
    SERVER_FULL
    IP_BANNED
    OLD_VERSION
    ACC_BANNED
    INVALD_USER
    MULTI_ACCOUNT
    INVALID_PASS
    IP_BLOCKED
    INACTIVITY
  )
  
  # Criação de conta
  Register = enum %w(
    ACC_EXIST
    SUCCESSFUL
  )
  
  # Alertas
  Alert = enum %w(
    INVALID_NAME
    TELEPORTED
    PULLED
    ATTACK_ADMIN
    BUSY
    IN_PARTY
    IN_GUILD
    GUILD_EXIST
    NOT_GUILD_LEADER
    FULL_GUILD
    NOT_PICK_UP_DROP
    REQUEST_DECLINED
    TRADE_DECLINED
    TRADE_FINISHED
    FULL_INV
    FULL_TRADE
    FULL_BANK
    MUTED
  )
  
  # Atalhos
  Hotbar = enum %w(
    NONE
    ITEM
    SKILL
  )
  
  # Comandos do painel de administração
  Command = enum %w(
    KICK
    TELEPORT
    GO
    PULL
    ITEM
    WEAPON
    ARMOR
    GOLD
    BAN_IP
    BAN_ACC
    UNBAN
    SWITCH
    MOTD
    MUTE
    MSG
  )
  
  # Projéteis
  Projectile = enum %w(
    WEAPON
    SKILL
  )
  
  # Alvos
  Target = enum %w(
    NONE
    PLAYER
    ENEMY
  )
  
  # Deslizamento do mouse
  Mouse = enum %w(
    NONE
    ITEM
    SKILL
    EQUIP
    SHOP
    TRADE
    BANK
  )
  
  # Gráfico do cursor
  Cursor = enum %w(
    NONE
    EVENT
    ENEMY
    PLAYER
    DROP
  )
  
  # Quantidade
  Amount = enum %w(
    BUY_ITEM
    SELL_ITEM
    DROP_ITEM
    ADD_TRADE_ITEM
    ADD_TRADE_GOLD
    REMOVE_TRADE_ITEM
    REMOVE_TRADE_GOLD
    DEPOSIT_ITEM
    DEPOSIT_GOLD
    WITHDRAW_ITEM
    WITHDRAW_GOLD
  )
  
  # Escolhas
  Choice = enum %w(
    REMOVE_FRIEND
    REQUEST
    FINISH_TRADE
    LEAVE_PARTY
    LEAVE_GUILD
    REMOVE_GUILD_MEMBER
    CHANGE_GUILD_LEADER
  )
  
  # Solicitações
  Request = enum %w(
    NONE
    TRADE
    FINISH_TRADE
    PARTY
    FRIEND
    GUILD
  )
  
  # Missões
  Quest = enum %w(
    IN_PROGRESS
    FINISHED
  )
  
end
