<div class="row">

	<div class="col-md-12">
		<?php

		if (isset($_POST['loga'])) {
			include('funcoes/config_main.php');

			$con = mysqli_connect($mysql_host, $mysql_user, $mysql_pass, $mysql_db);

			$login 		= 	$_POST['login'];
			$senha 		= 	md5($_POST['senha']);

			$c 			= 	mysqli_query($con, "SELECT * FROM accounts WHERE username = '$login' AND password = '$senha'");
			@$cont   	=   mysqli_num_rows($c);
			@$row_c 	= 	mysqli_fetch_object($c);

			if ($cont == 1) {

				$_SESSION['conectado'] 	= 	1;
				$_SESSION['id'] 		= 	$row_c->id;
				$_SESSION['acesso'] 	= 	$row_c->group;


				echo "<br><br><div class='alert alert-success text-center'> " . $lang['msgsuccesslogin'] . " </div>"; ?>

				<script type="text/javascript">
					window.setTimeout("location.href='/painel';", 2000);
				</script>

			<?php   } else {
				echo "<br><br><div class='alert alert-danger text-center'>" . $lang['msgerrorlogin'] . "</br> </div>" . $senha; ?>
		<?php 	}
		} ?>
	</div>
</div>