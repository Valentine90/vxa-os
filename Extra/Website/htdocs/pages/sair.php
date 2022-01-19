<?php
if (isset($_SESSION['conectado'])) {
	if (session_destroy()) {
		$data					= 	time();
		$ip						= 	$_SERVER["REMOTE_ADDR"];
		echo
		"    <br><br>
						<div class='alert alert-dismissable alert-success' style='padding:5px;'>
							<i class='glyphicon glyphicon-ok'></i> " . $lang['msgsuccesslogin'] . "
						</div>
					"; ?>



		<script type="text/javascript">
			window.setTimeout("location.href='/inicio';", 1000);
		</script>
<?php
	} else {
		echo
		"
						<div class='alert alert-dismissable alert-danger' style='padding:5px;'>
							<i class='glyphicon glyphicon-remove'></i> Erro ao desconectar
						</div>
					";
	}
} else {
	echo
	"
						<div class='alert alert-dismissable alert-danger' style='padding:5px;'>
							<i class='glyphicon glyphicon-remove'></i> Sessão não registrada!
						</div>
					";
}
?>