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
		    

		    ----------------------------------------------- */


header('Content-type: text/html; charset=utf-8');

// URL AMIGAVEL! NÃO ALETERE NADA NESTE CÓDIGO A NÃO SER QUE SAIBA O QUE ESTÁ FAZENDO
// ESTA PARTE É INALTERAVEL, QUALQUER MANUSEIO INCORRETO PODE COMPROMETER O SISTEMA

// FRIENDLY URL! DO NOT CHANGE ANYTHING IN THIS CODE UNLESS YOU KNOW WHAT YOU ARE DOING
// THIS PART IS UNALTERABLE, ANY INCORRECT HANDLING MAY COMPROMISE THE SYSTEM

if (isset($_GET['url'])) {
	$url = explode('/', $_GET['url']);
	$_GET['p'] = $url[0];
	$_GET['erro'] = $_GET['id'] = isset($url[1]) ? $url[1] : null;
	$_GET['url'] = null;
}

if (isset($_GET['p'])) {
	$p = htmlspecialchars($_GET['p']);
} else {
	$p = 'inicio';
}

if (!file_exists('pages/' . $p . '.php')) {
	$p = '404';
}


setlocale(LC_ALL, "pt_BR", "pt_BR.iso-8859-1", "ptb", "pt_BR.utf-8", "portuguese");
date_default_timezone_set('America/Sao_Paulo');

session_start();

include('funcoes/config_main.php');
include('funcoes/funcoes.php');

if (isset($_SESSION['conectado'])) {
	$id 			= $_SESSION['id'];
	$conectado 		= 1;
	$sq 			= mysqli_query($con, "SELECT * FROM accounts WHERE id = '$id'");
	$row_sq 		= mysqli_fetch_object($sq);
	$contaid 		= $row_sq->id;
	$username 	 	= $row_sq->username;
	$check_vip	 	= $row_sq->vip_time;
	$check_senha	= $row_sq->password;
	$acesso_g		= $row_sq->group;
	$account_cash	= $row_sq->cash;
} else {
	$conectado = 0;
}

$whos 				= mysqli_query($con, "SELECT * FROM actors WHERE online = '1'");
$whos_count 		= mysqli_num_rows($whos);

?>


<!DOCTYPE html>
<html>

<head>
	<!-- ==============================================================
								        ESSENCIAIS
			=============================================================== -->
	<base href="http://localhost/">

	<title><?php echo $title; ?></title>

	<link rel="apple-touch-icon" sizes="57x57" href="imgs/favicon/apple-icon-57x57.png">
	<link rel="apple-touch-icon" sizes="60x60" href="imgs/favicon/apple-icon-60x60.png">
	<link rel="apple-touch-icon" sizes="72x72" href="imgs/favicon/apple-icon-72x72.png">
	<link rel="apple-touch-icon" sizes="76x76" href="imgs/favicon/apple-icon-76x76.png">
	<link rel="apple-touch-icon" sizes="114x114" href="imgs/favicon/apple-icon-114x114.png">
	<link rel="apple-touch-icon" sizes="120x120" href="imgs/favicon/apple-icon-120x120.png">
	<link rel="apple-touch-icon" sizes="144x144" href="imgs/favicon/apple-icon-144x144.png">
	<link rel="apple-touch-icon" sizes="152x152" href="imgs/favicon/apple-icon-152x152.png">
	<link rel="apple-touch-icon" sizes="180x180" href="imgs/favicon/apple-icon-180x180.png">
	<link rel="icon" type="image/png" sizes="192x192" href="imgs/favicon/android-icon-192x192.png">
	<link rel="icon" type="image/png" sizes="32x32" href="imgs/favicon/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="96x96" href="imgs/favicon/favicon-96x96.png">
	<link rel="icon" type="image/png" sizes="16x16" href="imgs/favicon/favicon-16x16.png">
	<link rel="manifest" href="imgs/favicon/manifest.json">
	<meta name="msapplication-TileColor" content="#ffffff">
	<meta name="msapplication-TileImage" content="/ms-icon-144x144.png">
	<meta name="theme-color" content="#ffffff">


	<!-- ==============================================================
								      SCRIPTS E CSS
	=============================================================== -->

	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script src="js/jquery-3.5.1.js"></script>
	<script src="//cdn.ckeditor.com/4.15.1/standard/ckeditor.js"></script>

	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="js/bootstrap.js"></script>


	<script type="text/javascript">
		$(document).on('click', '[data-toggle="lightbox"]', function(event) {
			event.preventDefault();
			$(this).ekkoLightbox();
		});

		$(function() {
			$('[data-toggle="tooltip"]').tooltip()
		})
	</script>


	<link rel="stylesheet" type="text/css" href="css/bootstrap.css">

	<!-- Include all compiled plugins (below), or include individual files as needed -->

	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
	<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
	<!--[if lt IE 9]>
		      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
		      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		    <![endif]-->

</head>


<body>


	<div class="container">
		<!--head-->
		<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css" integrity="sha384-lZN37f5QGtY3VHgisS14W3ExzMWZxybE1SJSEsQp9S+oqd12jhcu+A56Ebc1zFSJ" crossorigin="anonymous">
		<link rel="stylesheet" type="text/css" href="css/main.css">
		<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.min.css">
		<link href="css/ekko-lightbox.css" rel="stylesheet">


		<!--start code-->
		<div class="row mb-5">
			<div class="col-lg-12 col-md-12 col-sm-12 mb-3 text-center">
				<img src="imgs/layout/logo.png" class="img-responsive" width="50%">
			</div>

			<?php

			if (isset($_POST['lang'])) {
				$_SESSION['lang'] = $_POST['lang'];
			}

			if (isset($_SESSION['lang'])) {
				include 'lang/' . $_SESSION['lang'] . '.php';
			} else {
				include 'lang/' . $lang_default . '.php';
			}
			?>
		</div>



		<nav class="navbar navbar-expand-md navbar-dark bg-dark" style="margin-top: -50px;">
			<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="navbarsExampleDefault">
				<ul class="navbar-nav mr-auto">
					<li class="nav-item active">
						<a class="nav-link" href="/inicio"><i class="fas fa-home"></i> <?php echo $lang['home']; ?></a>
					</li>
					<li class="nav-item active">
						<a class="nav-link" href="/rank"><i class="fas fa-trophy"></i> <?php echo $lang['rank']; ?></a>
					</li>
					<li class="nav-item active">
						<a class="nav-link" href="/shop"><i class="fas fa-store"></i> <?php echo $lang['loja']; ?></a>
					</li>
					<li class="nav-item active">
						<a class="nav-link" href="/guilds"><i class="fas fa-shield-alt"></i> <?php echo $lang['guilds']; ?></a>
					</li>
					<li class="nav-item active">
						<a class="nav-link" href="/downloads"><i class="fas fa-download"></i> <?php echo $lang['download']; ?></a>
					</li>
					<li class="nav-item active">
						<a class="nav-link" href="/wikipedia"><i class="fas fa-atlas"></i> <?php echo $lang['wiki']; ?></a>
					</li>

				</ul>
				<form action="" method="post" class="form-inline my-1 my-lg-0">
					<select name="lang" class="form-control" id="exampleFormControlSelect1">
						<?php

						$explo = explode(",", $language);

						$count = count($explo);

						for ($i = 0; $i < $count; $i++) {
							echo "<option value='$explo[$i]'>" . $explo[$i] . "</option>";
						}

						?>
					</select>
					<input type="submit" class="btn-sm btn-info ml-1 mr-1" name="" value="<?php echo $lang['bt_alterar']; ?>">
				</form>

			</div>
		</nav>
		<!--end code-->


		<div class="row">





			<div class="col-md-8 mt-4">
				<div class="card border-secondary">
					<div class="card-body">
						<?php include('pages/' . $p . '.php'); ?>
					</div>
				</div>


				<!-- Modal Janela de Login -->
				<div class="modal fade" id="Login" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
					<div class="modal-dialog" role="document">
						<div class="modal-content">

							<div class="modal-body">
								<div class="container bootstrap snippets bootdey">
									<div class="lc-block col-md-12 col-md-offset-4 toggled" id="l-login">
										<form action="/login" method="post" class="login">
											<div class="lcb-float"><i class="fa fa-users"></i></div>
											<div class="form-group">
												<input type="text" class="form-control" placeholder="<?php echo $lang['login']; ?>" name="login" required="">
											</div>
											<div class="form-group">
												<input type="password" class="form-control" placeholder="<?php echo $lang['senha']; ?>" name="senha" required="">
											</div>
											<div class="clearfix"></div>
											<input type="submit" name="loga" value="<?php echo $lang['bt_validar']; ?>" class="btn btn-block btn-primary btn-float m-t-25" />
										</form>
									</div>
								</div>
							</div>

						</div>
					</div>
				</div>
			</div>



			<div class="col-md-4">
				<div class="row">
					<div class="col-md-12 mt-4">
						<?php
						$current_status = Verificar($ip_server, $port_server, 1);
						if ($current_status == "down") : ?>
							<div class="alert alert-danger text-center" role="alert">
								<strong>
									<?php echo $lang['server']; ?>
								</strong>
								<br>
								<strong>
									<?php echo $lang['onoff']; ?>
								</strong>
							</div>
						<?php
						else :
						?>
							<div class="alert alert-success text-center" role="alert">
								<strong>
									<?php echo $lang['server']; ?>
								</strong>
								<br>
								<a class="nav-link" href="/characters"><i class="fas fa-users"></i>
									<strong>
										<?php echo $lang['onon']; ?> (<?php echo $whos_count . " " . $lang['whosonline']; ?>)
									</strong>
								</a>
							</div>
						<?php endif; ?>
					</div>

					<div class="col-md-12 mt-1">
						<?php if ($conectado == 0) { ?>
							<div class="card border-secondary">
								<div class="card-header">
									<?php echo $lang['login']; ?>
								</div>
								<div class="card-body">
									<form action="/login" method="post" class="text-right">
										<div class="form-group">
											<input type="text" class="form-control form-control-sm" placeholder="<?php echo $lang['user']; ?>" name="login" required="">
										</div>
										<div class="form-group">
											<input type="password" class="form-control form-control-sm" placeholder="<?php echo $lang['senha']; ?>" name="senha" required="">
										</div>

										<a href="/createaccount">
											<input type="button" value="<?php echo $lang['createaccount']; ?>" class="btn btn-primary btn-float" />
										</a>
										<input type="submit" name="loga" value="<?php echo $lang['login']; ?>" class="btn btn-primary btn-float" />

									</form>
								</div>
							</div>
						<?php } else { ?>
							<div class="card border-secondary">
								<div class="card-header">
									<?php echo $lang['welcome']; ?>
								</div>
								<ul class="list-group list-group-flush">
									<li class="list-group-item"><a href="/painel"><i class="fas fa-solar-panel"></i> <?php echo $lang['myacc']; ?></a></li>
									<li class="list-group-item"><a href="/donate"><i class="fas fa-donate"></i> <?php echo $lang['donate']; ?></a></li>
									<li class="list-group-item"><a href="/sair"><input type="button" value="<?php echo $lang['sair']; ?>" class="btn btn-info btn-sm btn-block btn-float" /></a></li>
								</ul>
							</div>
						<?php } ?>
					</div>
					<div class="col-md-12 mt-3">
						<div class="card border-secondary">
							<div class="card-header">
								<?php echo $lang['search']; ?>
							</div>
							<div class="card-body">
								<form action="/search" method="post" class="text-right">
									<input type="text" class="form-control" placeholder="<?php echo $lang['nome']; ?>" name="search" required="">
								</form>
							</div>
						</div>
					</div>
					<div class="col-md-12 mt-3">
						<div class="card border-secondary">
							<div class="card-header">
								<?php echo $lang['bau']; ?>
							</div>
							<div class="card-body text-center">
								<a href="">
									<img src="imgs/shop/bau.gif" class="img-responsive" width="60%">
								</a>
							</div>
						</div>
					</div>
					<div class="col-md-12 mt-3">
						<div class="card border-secondary">
							<div class="card-header">
								<?php echo $lang['social']; ?>
							</div>
							<div class="card-body text-center">
								<a href="https://www.facebook.com/aldeiarpg"><i class="fab fa-3x fa-facebook-square"></i></a>
								<a href="https://twitter.com/"><i class="fab fa-twitter-square fa-3x social"></i></a>
								<a href="https://plus.google.com/"><i class="fab fa-youtube-square fa-3x social"></i></a>
								<a href="mailto:carloshenrychgs@gmail.com"><i class="fab fa-discord fa-3x"></i></a>
							</div>
						</div>
					</div>


				</div>
			</div>
		</div>

	</div>

	<br><br><br><br><br>

	<div class="d-flex flex-column footerrrr">

		<footer class="w-100 py-4 flex-shrink-0">
			<div class="container py-4">
				<div class="row gy-4 gx-5">
					<div class="col-lg-4 col-md-6">
						<h5 class="h1 text-white">FB.</h5>
						<p class="small text-muted">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.</p>
						<p class="small text-muted mb-0">&copy; Copyrights. All rights reserved. <a class="text-primary" href="#">Bootstrapious.com</a></p>
					</div>
					<div class="col-lg-2 col-md-6">
						<h5 class="text-white mb-3">Quick links</h5>
						<ul class="list-unstyled text-muted">
							<li><a href="#">Home</a></li>
							<li><a href="#">About</a></li>
							<li><a href="#">Get started</a></li>
							<li><a href="#">FAQ</a></li>
						</ul>
					</div>
					<div class="col-lg-2 col-md-6">
						<h5 class="text-white mb-3">Quick links</h5>
						<ul class="list-unstyled text-muted">
							<li><a href="#">Home</a></li>
							<li><a href="#">About</a></li>
							<li><a href="#">Get started</a></li>
							<li><a href="#">FAQ</a></li>
						</ul>
					</div>
					<div class="col-lg-4 col-md-6">
						<h5 class="text-white mb-3">Newsletter</h5>
						<p class="small text-muted">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.</p>
						<form action="#">
							<div class="input-group mb-3">
								<input class="form-control" type="text" placeholder="Recipient's username" aria-label="Recipient's username" aria-describedby="button-addon2">
								<button class="btn btn-primary" id="button-addon2" type="button"><i class="fas fa-paper-plane"></i></button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</footer>
	</div>

</body>

<?php mysqli_close($con); ?>

</html>