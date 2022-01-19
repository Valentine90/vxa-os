<?php

	$mysql_host 	= 	"localhost";
	$mysql_user 	= 	"root";
	$mysql_pass 	= 	"";
	$mysql_db 		= 	"vxaos_db";


    // NÃO ALTERAR ESSA PARTE

	if($con = mysqli_connect($mysql_host, $mysql_user, $mysql_pass, $mysql_db))
	{
		  //mysqli_query($con,"SET NAMES 'utf8'");
		  //mysqli_query($con,'SET character_set_connection=utf8');
		  //mysqli_query($con,'SET charecter_set_client=utf8');
		  //mysqli_query($con,'SET charecter_set_results=utf8');
	} 
		else
	{ echo "Ocorreu um erro ao conectar-se!"; }
