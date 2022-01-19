<!--                                              
 ___  ___  ___  ___  ___  ___  ___  ___  ___  
(___)(___)(___)(___)(___)(___)(___)(___)(___) 
       _  _  _  _     __    __   ____         
      / )( \( \/ )   / _\  /  \ / ___)        
      \ \/ / )  (   /    \(  O )\___ \        
       \__/ (_/\_)  \_/\_/ \__/ (____/        
 ___  ___  ___  ___  ___  ___  ___  ___  ___  
(___)(___)(___)(___)(___)(___)(___)(___)(___) 

-->



<?php

if ($conectado == 1) {

	if (isset($_POST['senha1'])) {
	} else { ?>
		<script type="text/javascript">
			window.setTimeout("location.href='/inicio';", 1);
		</script>

		<?php
	}

	$senha1 	= md5($_POST['senha1']);
	$senha2 	= md5($_POST['senha2']);
	$senha3 	= md5($_POST['senha3']);

	if ($senha1 == $check_senha) {
		if ($senha2 == $senha3) {
			if (mysqli_query($con, "UPDATE accounts SET password = '$senha3' WHERE id = '$contaid' ")) {
				echo "<br><br><div class='alert alert-success text-center'> Senha altera com sucesso! <br>Redirecionando... </div>"; ?>

				<script type="text/javascript">
					window.setTimeout("location.href='/sair';", 2000);
				</script>
			<?php
			} else {
				echo "<br><br><div class='alert alert-danger text-center'> Ocorreu um erro critico! Contate um Administrador. </div>";
			}
		} else {
			echo "<br><br><div class='alert alert-danger text-center'> Nova senha não confere com a senha repetida! </div>"; ?>

			<script type="text/javascript">
				window.setTimeout("location.href='/painel';", 4000);
			</script>
		<?php
		}
	} else {
		echo "<br><br><div class='alert alert-danger text-center'> A senha atual digita está incorreta! </div>"; ?>

		<script type="text/javascript">
			window.setTimeout("location.href='/painel';", 4000);
		</script>
<?php
	}
}

?>