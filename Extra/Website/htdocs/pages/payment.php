<?php

if ($conectado == 1 and $_GET['id'] > 0) {
	$itemid 		= intval($_GET['id']);
	$sel 			= mysqli_query($con, "SELECT * FROM store WHERE id = '$itemid'");
	$r_sel			= mysqli_fetch_object($sel);

	$amount			= $r_sel->amount;

	if ($r_sel->purchased == false) {
		$z;
	} else {
		$z = $r_sel->purchased;
	}
	$j 				= @$z + 1;

	$it 			= $r_sel->item_id;

	$d = time();

	$numbers_b 		= 4;

	$calc 			= $r_sel->price - $r_sel->price * $discount / 100;

	@$sub			= @$account_cash - $calc;

	$result_b 		= random_bytes($numbers_b);
	$purchase_id 	= strtoupper(bin2hex($result_b));

	$msg 			= $lang['purchased'] . $r_sel->name . " | <i class=\"far fa-gem\"> </i>  <strong>$account_cash - $calc</strong> = <code>$sub</code>";

	mysqli_query($con, "UPDATE `store` SET `purchased` = '$j' WHERE `id` = '$itemid'");


	if ($account_cash > $calc) {

		mysqli_query($con, "INSERT INTO `records` (`id`, `text`, `date`, `account_id`, `purchase_id`) VALUES (NULL, '$msg', '$d', '$contaid', '$purchase_id')");

		// CATEGORIA VIP
		if ($r_sel->category == 1) {

			if ($check_vip == 0) {
				$c = time();
			} else {
				$c = $check_vip;
			}

			if ($d > $c) {
				$e = $d;
			} else {
				$e = $c;
			}

			$h = strtotime($amount . ' day', $e);

			if (mysqli_query($con, "UPDATE `accounts` SET `vip_time` = '$h', `cash` = '$sub' WHERE `id` = '$contaid'")) {

?>
				<div class="row">
					<div class="col-lg-12 text-center">
						<div class="alert alert-info mt-3" role="alert">
							<img src="imgs/icones/final.png"><br>
							<?php echo $lang['purchaseid'] . "<strong>" . $purchase_id . "</strong><hr>" . $lang['msgsuccessvip'] . "<br><strong>" . strftime("%c", $h) . "</strong>";
							?>
							<br>
							<hr>
							<i class="far fa-gem"> </i> <?php echo $lang['saldo']; ?> <strong> <?php echo $sub . " " . $cash_name; ?></strong>
						</div>
					</div>
				</div>

			<?php

			} else {
			?>

				<div class="alert alert-danger" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

			<?php
			}
		} // FIM CATEGORIA VIP


		// CATEGORIA ITENS GERAIS
		if ($r_sel->category == 2) {

			if (mysqli_query($con, "INSERT INTO `distributor` (`id`, `account_id`, `item_id`, `kind`, `amount`) VALUES (NULL, '$contaid', '$it', 1,'$amount')")) {
				mysqli_query($con, "UPDATE `accounts` SET `cash` = '$sub' WHERE `id` = '$contaid'");
			?>

				<div class="row">
					<div class="col-lg-12 text-center">
						<div class="alert alert-info" role="alert">
							<img src="imgs/icones/final.png"><br>
							<?php echo $lang['purchaseid'] . "<strong>" . $purchase_id . "</strong><hr>" . $lang['msgsuccesspush'] . "<br><strong>" . $r_sel->name . "</strong>";
							?>
							<br>
							<hr>
							<i class="far fa-gem"> </i> <?php echo $lang['saldo']; ?> <strong> <?php echo $sub . " " . $cash_name; ?></strong>
						</div>
					</div>
				</div>

			<?php
			} else {
			?>

				<div class="alert alert-danger mt-3" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

			<?php
			}
		} // FIM CATEGORIA ITENS GERAIS


		// CATEGORIA ARMAS
		if ($r_sel->category == 3) {

			if (mysqli_query($con, "INSERT INTO `distributor` (`id`, `account_id`, `item_id`, `kind`, `amount`) VALUES (NULL, '$contaid', '$it', 2,'$amount')")) {
				mysqli_query($con, "UPDATE `accounts` SET `cash` = '$sub' WHERE `id` = '$contaid'");
			?>

				<div class="row">
					<div class="col-lg-12 text-center">
						<div class="alert alert-info" role="alert">
							<img src="imgs/icones/final.png"><br>
							<?php echo $lang['purchaseid'] . "<strong>" . $purchase_id . "</strong><hr>" . $lang['msgsuccesspush'] . "<br><strong>" . $r_sel->name . "</strong>";
							?>
							<br>
							<hr>
							<i class="far fa-gem"> </i> <?php echo $lang['saldo']; ?> <strong> <?php echo $sub . " " . $cash_name; ?></strong>
						</div>
					</div>
				</div>

			<?php
			} else {
			?>

				<div class="alert alert-danger mt-3" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

			<?php
			}
		} // FIM CATEGORIA ARMAS


		// CATEGORIA PROTETORES
		if ($r_sel->category == 4) {

			if (mysqli_query($con, "INSERT INTO `distributor` (`id`, `account_id`, `item_id`, `kind`, `amount`) VALUES (NULL, '$contaid', '$it', 3,'$amount')")) {
				mysqli_query($con, "UPDATE `accounts` SET `cash` = '$sub' WHERE `id` = '$contaid'");
			?>

				<div class="alert alert-info mt-3" role="alert">
					<?php echo $lang['msgsuccesspush']; ?>
				</div>

			<?php
			} else {
			?>

				<div class="alert alert-danger mt-3" role="alert">
					<?php echo $lang['criterror']; ?>
				</div>

	<?php
			}
		} // FIM CATEGORIA PROTETORES

	}
} else { ?>
	<script type="text/javascript">
		window.setTimeout("location.href='/inicio';", 100);
	</script>
<?php
}

?>