<?php if ($conectado == 1 and $acesso_g >= 2) {

	$titlesite 			= $_POST['titlesite'];
	$cashname 			= $_POST['cashname'];
	$maxrank 			= $_POST['maxrank'];
	$maxnews 			= $_POST['maxnews'];
	$maxrankguild 		= $_POST['maxrankguild'];
	$maxitemstore 		= $_POST['maxitemstore'];
	$downloadlink 		= $_POST['downloadlink'];
	$discount 			= $_POST['discount'];
	$languages 			= $_POST['languages'];
	$langdefault 		= $_POST['langdefault'];
	$ipserver 			= $_POST['ipserver'];
	$portserver 		= $_POST['portserver'];

	if (mysqli_query($con, "UPDATE `configs` SET `titlesite` = '$titlesite', `cashname` = '$cashname', `maxrank` = '$maxrank', `maxrankguild` = '$maxrankguild', `maxitemstore` = '$maxitemstore', `downloadlink` = '$downloadlink', `discount` = '$discount', `languages` = '$languages', `langdefault` = '$langdefault', `ipserver` = '$ipserver', `portserver` = '$portserver', `maxnews` = '$maxnews' WHERE `id` = '1'")) {
		echo "<div class='alert alert-dismissable alert-success' style='padding:5px;'>
							<i class='glyphicon glyphicon-ok'></i> " . $lang['msgsuccesslogin'] . "
						</div>"; ?>
		<script type="text/javascript">
			window.setTimeout("location.href='/painel';", 1000);
		</script>
<?php
	}
} ?>