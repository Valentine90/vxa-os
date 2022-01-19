<?php

if ($conectado == 1 and $acesso_g >= 1) {

	if (isset($_POST['okaypayment'])) {
		$a 		= antiSQL($_POST['loginbuy']);
		$b 		= antiSQL($_POST['amountbuy']);
		$h 		= antiSQL($_POST['idbuy']);
		$c 		= mysqli_query($con, "SELECT * FROM accounts WHERE username = '$a'");
		$d 		= mysqli_num_rows($c);

		if ($d > 0) {
			mysqli_query($con, "UPDATE `payment_voucher` SET `reader` = '1', `okay` = '1' WHERE `id` = '$h'");
			$e 	= mysqli_fetch_object($c);
			$f 	= $e->cash + $b;

			if (mysqli_query($con, "UPDATE accounts SET cash = '$f' WHERE username = '$a'")) { ?>
				<div class="alert alert-primary mt-3" role="alert">
					<?php echo $lang['msgsucessaddcash'] . "<strong>" . $f . "</strong> " . $cash_name . " " . $lang['for'] . " <strong>" . $e->username . "</strong>"; ?><br>
					<a href="/painel"><?php echo $lang['msgback']; ?></a>
				</div>

			<?php	} else {
			?>
				<div class="alert alert-danger mt-3" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

			<?php
			}
		} else {
			?>
			<div class="alert alert-danger mt-3" role="alert">
				<?php echo $lang['errorlogin']; ?>
			</div>

			<?php
		}
	}



	if (isset($_POST['addcash'])) {
		$a 		= antiSQL($_POST['login']);
		$b 		= antiSQL($_POST['amount']);
		$c 		= mysqli_query($con, "SELECT * FROM accounts WHERE username = '$a'");
		$d 		= mysqli_num_rows($c);

		if ($d > 0) {

			$e 	= mysqli_fetch_object($c);
			$f 	= $e->cash + $b;

			if (mysqli_query($con, "UPDATE accounts SET cash = '$f' WHERE username = '$a'")) { ?>
				<div class="alert alert-primary mt-3" role="alert">
					<?php echo $lang['msgsucessaddcash'] . "<strong>" . $f . "</strong> " . $cash_name . " " . $lang['for'] . " <strong>" . $e->username . "</strong>"; ?><br>
					<a href="/painel"><?php echo $lang['msgback']; ?></a>
				</div>

			<?php	} else {
			?>
				<div class="alert alert-danger mt-3" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

			<?php
			}
		} else {
			?>
			<div class="alert alert-danger mt-3" role="alert">
				<?php echo $lang['errorlogin']; ?>
			</div>

			<?php
		}
	}




	if (isset($_POST['takeoutcash'])) {
		$a 		= antiSQL($_POST['login']);
		$b 		= antiSQL($_POST['amount']);
		$c 		= mysqli_query($con, "SELECT * FROM accounts WHERE username = '$a'");
		$d 		= mysqli_num_rows($c);

		if ($d > 0) {

			$e 	= mysqli_fetch_object($c);
			$f 	= $e->cash - $b;

			if (mysqli_query($con, "UPDATE accounts SET cash = '$f' WHERE username = '$a'")) { ?>
				<div class="alert alert-warning mt-3" role="alert">
					<?php echo $lang['msgsucesstakeoutcash'] . "<strong>" . $f . "</strong> " . $cash_name . " " . $lang['for'] . " <strong>" . $e->username . "</strong>"; ?><br>
					<a href="/painel"><?php echo $lang['msgback']; ?></a>
				</div>

			<?php	} else {
			?>
				<div class="alert alert-danger mt-3" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

			<?php
			}
		} else {
			?>
			<div class="alert alert-danger mt-3" role="alert">
				<?php echo $lang['errorlogin']; ?>
			</div>

<?php
		}
	}
}
?>