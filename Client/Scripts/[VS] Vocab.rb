#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  Este módulo lida com o vocabulário. Todos os textos
# exibidos no jogo ficam aqui.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Vocab
  
  # Entrada e criação de conta
  Username           = 'Usuário'
  Password           = 'Senha'
  RepeatPass         = 'Repetir senha:'
  Email              = 'E-mail:'
  Remember           = 'Lembrar?'
  Register           = 'Registrar'
  Connect            = 'Conectar'
  NewAcc             = 'Registre-se'
  Login              = 'Conecte-se'
  
  # Criação e seleção de personagem
  NotVIP             = 'Você não é VIP'
  VIP                = 'Você tem %s dias VIP.'
  Name               = 'Nome'
  Sex                = 'Sexo:'
  Class              = 'Classe:'
  Graphic            = 'Gráfico:'
  Points             = 'Pontos:'
  Male               = 'Homem'
  Female             = 'Mulher'
  Empty              = 'Vazio'
  Play               = 'Entrar'
  ShopBuy            = 'Comprar'
  
  # Bate-papo
  SecondaryText      = 'Pressione Enter para falar...'
  Map                = 'Mapa'
  All                = 'Todos'
  Party              = 'Grupo'
  Guild              = 'Guilda'
  Private            = 'Privado'
  Emojis             = 'Emojis'
  
  # Alerta do menu
  ServerOffline      = 'O servidor está off-line!'
  ServerFull         = 'O servidor está cheio. Tente novamente mais tarde!'
  ConnectionFailed   = 'A conexão falhou!'
  Insufficient       = '%s deve ter pelo menos %d caracteres!'
  ForbiddenCharacter = 'O nome só pode conter letras, números e espaço!'
  Kicked             = 'Você foi expulso!'
  IPBanned           = 'Seu IP está banido!'
  OldVersion         = 'Esta versão é antiga. Por favor, atualize!'
  AccBanned          = 'Sua conta está banida!'
  InvalidUser        = 'Usuário inválido!'
  InvalidPass        = 'Senha inválida!'
  InvalidName        = 'Nome inválido!'
  InvalidEmail       = 'E-mail inválido!'
  PasswordsNotMatch  = 'As senhas não coincidem!'
  IPBlocked          = 'Você errou seus dados 5 vezes. Seu IP foi bloqueado por 3 minutos!'
  MultiAccount       = 'Usuário conectado!'
  Inactivity         = 'Você excedeu o tempo máximo de inatividade!'
  EnterPass          = 'O personagem será apagado permanentemente e não poderá ser recuperado. Por favor, digite sua senha para confirmar a exclusão.'
  AccExist           = 'Esse usuário já existe!'
  Successful         = 'Conta registrada com sucesso!'
  CharExist          = 'Esse nome já está sendo usado!'
  
  # Alerta do jogo
  Teleported         = 'Você foi teletransportado.'
  Pulled             = 'Você foi puxado.'
  Muted              = 'Você foi silenciado por 30 segundos.'
  NonPvP             = 'Você não pode atacar aqui.'
  AttackAdmin        = 'Você não pode atacar um administrador.'
  NotEnoughMoney     = 'Dinheiro insuficiente.'
  NotSellItem        = 'Esta loja não compra itens.'
  NotTarget          = 'Você não tem alvo.'
  NotSeeTarget       = 'Você não está vendo o alvo.'
  TargetNotInRange   = 'Alvo fora de alcance!'
  InsufficientLevel  = 'Você não tem nível suficiente para usar este item.'
  InsufficientMP     = 'Você não tem MP suficiente.'
  GlobalSpawning     = 'Espere 1 segundo para falar novamente no bate-papo global.'
  NotAmmo            = 'Você não tem munição.'
  NotPickUpDrop      = 'Você ainda não pode pegar esse item.'
  NotHave            = 'Você não tem'
  RequestDeclined    = 'Sua solicitação foi recusada.'
  FullInventory      = 'Seu inventário está cheio.'
  FullTrade          = 'A troca está cheia.'
  FullBank           = 'O banco está cheio.'
  FullDrops          = 'Você não pode derrubar item no chão agora.'
  ProtectionLevel    = 'Você ou seu alvo não tem nível suficiente para duelar.'
  WTypeNotEquipped   = 'Você não equipou o tipo de arma exigida para usar essa habilidade.'
  EquipVIP           = 'Só jogadores VIP podem usar este equipamento.'
  DifferentSex       = 'Este protetor não foi feito para o seu sexo.'
  SoulboundItem      = 'Este item está ligado à sua alma e não pode ser negociado, derrubado nem depositado.'
  Blocked            = 'foi bloqueado.'
  Unlocked           = 'foi desbloqueado.'
  Busy               = 'Este jogador está ocupado.'
  Ask                = 'Você tem certeza?'
  Press              = 'Pressione'
  
  # Habilidades
  Attack             = 'Ataque'
  Support            = 'Suporte'
  
  # Amigos
  FullFriends        = 'Sua lista de amigos está cheia.'
  FriendAdded        = 'foi adicionado à sua lista de amigos.'
  FriendExist        = 'Este jogador já é seu amigo.'
  FriendRequest      = 'quer ser seu amigo. Aceitar?'
  Friend             = 'Amigo'
  
  # Troca
  TradeRequest       = 'te convidou para uma troca. Aceitar?'
  TradeComplete      = 'quer concluir a troca. Aceitar?'
  TradeDeclined      = 'A troca foi recusada.'
  TradeFinished      = 'Troca concluída.'
  PlayerNotInRange   = 'Jogador fora de alcance.'
  InTrade            = 'Você já está em uma troca.'
  Trade              = 'Troca'
  
  # Banco
  Items              = 'Itens'
  Weapons            = 'Armas'
  Armors             = 'Protetores'
  
  # Grupo
  InParty            = 'Este jogador já está em um grupo.'
  PartyRequest       = 'te convidou para um grupo. Aceitar?'
  PartyMemberJoined  = 'entrou no grupo.'
  PartyMemberLeave   = 'saiu do grupo.'
  DissolvedParty     = 'Grupo dissolvido.'
  FullParty          = 'Seu grupo está cheio.'
  NotParty           = 'Você não está em um grupo.'
  
  # Guilda
  NewGuild           = 'Criação de guilda'
  YouInGuild         = 'Você já está em uma guilda.'
  PlayerInGuild      = 'já está na guilda'
  GuildExist         = 'Essa guilda já existe.'
  EmptyFlag          = 'Você não desenhou o brasão.'
  NotGuildLeader     = 'Você não é o líder da guilda.'
  FullGuild          = 'Sua guilda está cheia.'
  GuildRequest       = 'te convidou para a guilda %s. Aceitar?'
  NotGuild           = 'Você não está em uma guilda.'
  Leader             = 'Líder'
  Member             = 'Membro'
  Add                = 'Adicionar:'
  NewLeader          = 'Novo líder:'
  Notice             = 'Aviso:'
  Main               = 'Principal'
  Manage             = 'Gerir'
  
  # Descrição de itens, armas e protetores
  Equipable          = 'Equipável por'
  NotEquipable       = 'Não equipável por'
  Consumable         = 'Consumível:'
  BaseDamage         = 'Dano base:'
  Soulbound          = 'Preso à alma'
  TwoHanded          = 'Arma de duas mãos'
  OneHanded          = 'Arma de uma mão'
  ItemType           = 'Tipo:'
  Normal             = 'Normal'
  MPCost             = 'Custo de MP:'
  Hit                = 'Precisão:'
  
  # Menu
  Menu               = 'Menu'
  Configs            = 'Configurações'
  BackLogin          = 'Voltar à entrada'
  BackSelection      = 'Voltar à seleção'
  Quit               = 'Abandonar jogo'
  Music              = 'Música:'
  Sound              = 'Som:'
  Resolution         = 'Resolução:'
  FullScreen         = 'Tela cheia:'
  FPS                = 'FPS:'
  Vsync              = 'V-sync'
  NoLimit            = 'Sem limite'
  
  # Títulos
  Teleport           = 'Teletransporte'
  Bank               = 'Banco'
  Amount             = 'Quantidade'
  Shop               = 'Loja'
  Alert              = 'Alerta'
  NewChar            = 'Criação de personagem'
  UseChar            = 'Seleção de personagens'
  
  # Missões
  Quest              = 'Missão'
  Quests             = 'Missões'
  Dialogue           = 'Diálogo'
  Information        = 'Informações'
  InProgress         = 'Em andamento'
  Completed          = 'Concluídas'
  StartQuest         = 'Você iniciou a missão'
  FinishQuest        = 'Você concluiu a missão'
  Rewards            = 'Recompensas:'
  Item               = 'Item'
  Exp                = 'Exp'
  
  # Painel de administração
  SecondaryPanelText = "Escreva o nome ou 'all'"
  AdmPanel           = 'Painel de administração'
  AlertMessage       = 'Mensagem de alerta:'
  Motd               = 'Mensagem do dia:'
  Banishment         = 'Banimento:'
  GlobalSwitch       = 'Switche global:'
  Days               = 'Dias'
  ID                 = 'ID:'
  Kick               = 'Expulsar'
  Mute               = 'Silenciar'
  Pull               = 'Puxar'
  GoTo               = 'Ir até'
  Change             = 'Mudar'
  BanAcc             = 'Banir conta'
  BanIP              = 'Banir IP'
  Unban              = 'Desbanir'
  On                 = 'Ligar'
  Off                = 'Desligar'
  Teleport           = 'Teletransportar'
  GiveItem           = 'Dar item'
  Send               = 'Enviar'
  
  # Botões
  Ok                 = 'Ok'
  Go                 = 'Ir'
  Cancel             = 'Cancelar'
  Yes                = 'Sim'
  No                 = 'Não'
  Create             = 'Criar'
  Delete             = 'Excluir'
  Accept             = 'Aceitar'
  Block              = 'Bloquear'
  Unlock             = 'Desbloquear'
  Activated          = 'Ativado'
  Disabled           = 'Desativado'
  
  # Ícones da miniatura do mapa
  Boss               = 'Chefe'
  CheckPoint         = 'Ponto de referência'
  
  # HUD
  MaxLevel           = 'Nível máximo'
  
end
