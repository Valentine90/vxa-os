<?php if ($conectado == 1 and $acesso_g >= 2) {

	$aaa = intval($_GET['id']);

	if (mysqli_query($con, "DELETE FROM `store` WHERE `id` = '$aaa'")) { ?>

		<div class="alert alert-success mt-3" role="alert">
			<?php echo $lang['msgdeleteditem']; ?><br>
			<a href="/managershop"><?php echo $lang['msgback']; ?></a>
		</div>

<?php
	} else {
		echo "erro";
		echo $aaa;
	}
} ?>