<div class="row">

	<div class="col-md-10">
		<?php

		if (isset($_POST['cad'])) {
			include('funcoes/config_main.php');


			$con = mysqli_connect($mysql_host, $mysql_user, $mysql_pass, $mysql_db);

			$login 	   	=   antiSQL($_POST['login']);
			$email 		=   antiSQL($_POST['email']);
			$senha    	=   md5($_POST['pass']);
			$senha2    	=   md5($_POST['pass2']);
			$dat 						= 		time();


			$c      	=   mysqli_query($con, "SELECT * FROM accounts WHERE username = '$login'");
			@$cont    	=   mysqli_num_rows($c);

			if ($cont == 1 or $senha != $senha2) {
				echo "<br><br><div class='alert alert-danger text-center'>" . $lang['msgexistlogin'] . "</br> </div>";
			} else {
				if (mysqli_query($con, "INSERT INTO `accounts` (`id`, `username`, `password`, `email`, `group`, `creation_date`, `vip_time`, `cash`) VALUES (NULL, '$login', '$senha2', '$email', '0', '$dat', '$dat', '0')")) {
					$bb = mysqli_fetch_object(mysqli_query($con, "SELECT * FROM accounts WHERE username = '$login'"));
					$cc_id = $bb->id;

					if (mysqli_query($con, "INSERT INTO `banks` (`id`, `account_id`, `gold`) VALUES (NULL, '$cc_id', '0')")) {
						echo "<br><br><div class='alert alert-info text-center'>" . $lang['msgsucesscad'] . "</br> </div>";
					} else {
						echo "<br><br><div class='alert alert-danger text-center'>" . $lang['criterror'] . "</br> </div>";
					}
				} else {
					echo "<br><br><div class='alert alert-danger text-center'>" . $lang['criterror'] . "</br> </div>";
				}
			}
		}

		?>

	</div>
</div>