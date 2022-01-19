<?php 
	


	/* ---------------------------------------------

	 ___  ___  ___  ___  ___  ___  ___  ___  ___  
	(___)(___)(___)(___)(___)(___)(___)(___)(___) 
	       _  _  _  _     __    __   ____         
	      / )( \( \/ )   / _\  /  \ / ___)        
	      \ \/ / )  (   /    \(  O )\___ \        
	       \__/ (_/\_)  \_/\_/ \__/ (____/        
	 ___  ___  ___  ___  ___  ___  ___  ___  ___  
	(___)(___)(___)(___)(___)(___)(___)(___)(___) 

	-----------------------------------------------

				CONFIGURAÇÕES BÁSICAS

	----------------------------------------------*/

	require('db.php');
	
	$config = mysqli_fetch_object(mysqli_query($con, "SELECT * FROM configs"));
	
	$title 				= $config->titlesite; // TITULO DO SITE |[ENGLISH]->| SITE TITLE


	$cash_name			= $config->cashname; // NOME DA MOEDA PREMIUM |[ENGLISH]->| PREMIUM CURRENCY NAME

	$max_news			= $config->maxnews; 


	$max_rank			= $config->maxrank; // MÁXIMO DE PLAYERS MOSTRANDO NO RANK |[ENGLISH]->| MAXIMUM PLAYERS SHOWING IN THE RANK


	$max_rank_guild		= $config->maxrankguild; // MÁXIMO DE GUILDS MOSTRADAS NO RANK |[ENGLISH]->| MAXIMUM GUILDS SHOWN IN RANK


	$max_item_store		= $config->maxitemstore; // MÁXIMO DE ITENS MOSTRADOS NA LOJA |[ENGLISH]->| MAXIMUM ITEMS SHOWN IN THE STORE

	
	$link_download 		= $config->downloadlink;  // AQUI VOCE COLOCA O LINK PARA DOWNLOAD DO JOGO, EXEMPLO: https://site.com/download.zip |[ENGLISH]->| HERE YOU PUT THE LINK TO DOWNLOAD THE GAME, EXAMPLE: https://site.com/download.zip


	$discount 			= $config->discount; // 0 = NÃO APLICA DISCONTO! QUALQUER OUTRO VALOR É CONVERTIDO EM % QUE SERÁ DISCONTADO NO PREÇO TOTAL DE CADA ITEM DA LOJA |[ENGLISH]->| 0 = DOES NOT APPLY DISCOUNT! ANY OTHER AMOUNT IS CONVERTED IN % WHICH WILL BE DISCOUNTED IN THE TOTAL PRICE OF EACH STORE ITEM


	$language			= $config->languages; // NÃO COLOQUE ESPAÇOS ENTRE AS VIRGULAS! CASO DESEJE ADICIONAR +1 LINGUAGEM, DUPLIQUE 1 ARQUIVO NA PASTA LANG E RENOMEIE PARA A NOVA LINGUAGEM, LOGO APÓS COLOQUE O NOME DA NOVA LINGUAGEM EXATAMENTE COMO ESTÁ NO ARQUIVO CRIADO. |[ENGLISH]->| DO NOT PLACE SPACES BETWEEN THE COMB! IF YOU WANT TO ADD +1 LANGUAGE, DOUBLE 1 FILE IN LANG FOLDER AND RENAME TO THE NEW LANGUAGE, SOON AFTER PUT THE NAME OF THE NEW LANGUAGE EXACTLY AS IT IS IN THE CREATED FILE.


	$lang_default 		= $config->langdefault; // DEFINE QUAL A LINGUAGEM PRINCIPAL DO SITE |[ENGLISH]->| DEFINE WHAT IS THE MAIN LANGUAGE OF THE SITE

	/* ---------------------------------------------

				CONFIGURAÇÕES DO SERVIDOR |[ENGLISH]->| SERVER SETTINGS

	----------------------------------------------*/

	$ip_server			= $config->ipserver; // IP DO SERVIDOR |[ENGLISH]->| SERVER IP


	$port_server		= $config->portserver;// PORTA DO SERVIDOR |[ENGLISH]->| SERVER PORT

	/* ---------------------------------------------

				CONEXÃO COM O BANCO DE DADOS |[ENGLISH]->| DATABASE CONNECTION

	----------------------------------------------*/
