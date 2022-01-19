<?php

$itemid 	= intval($_GET['id']);
$sel 		= mysqli_query($con, "SELECT * FROM store WHERE id = '$itemid'");
$r_sel		= mysqli_fetch_object($sel);

?>
<div class="row">
	<?php if ($conectado == 1) { ?>
		<div class="col-lg-12">
			<i class="far fa-gem"> </i> <strong><?php echo $lang['saldo']; ?> <?php echo $account_cash . " " . $cash_name; ?></strong>
		</div>
	<?php } ?>
	<div class="col-lg-12 col-md-8 col-xs-12">
		<div class="row">
			<div class="col-lg-4 col-md-4 col-xs-4">
				<div class="card">
					<img src="imgs/shop/icons/<?php echo $r_sel->img ?>" class="card-img-top  mx-auto d-block" alt="...">
					<ul class="list-group list-group-flush">
						<li class="list-group-item text-center">
							<?php if ($discount == 0) { $calc = $r_sel->price; ?>
								<span class="badge badge-primary text-wrap">
									<small>
										<i class="far fa-gem"> </i> <?php echo $r_sel->price . " " . $cash_name; ?>
									</small>
								</span>
							<?php
							} else {
								$calc 	= $r_sel->price - $r_sel->price * $discount / 100; ?>
								<span class="badge badge-warning"><strong><?php echo $discount; ?>% OFF</strong></span>
								<small>
									<s>
										<strong><?php echo $r_sel->price; ?></strong>
									</s>
								</small>
								<br>
								<span class="badge badge-primary text-wrap">
									<font size="+1">
										<i class="far fa-gem"> </i> <?php echo $calc . " " . $cash_name; ?>
									</font>
								</span>
							<?php } ?>
						</li>
					</ul>
					<div class="card-body">
						<?php if ($conectado == 1) { ?>
							<?php if ($account_cash > $calc) { ?>
								<a href="/payment/<?php echo $r_sel->id; ?>">
									<button type="button" class="btn btn-info btn-block">
										<i class="fas fa-shopping-cart"></i> <?php echo $lang['bt_buy']; ?></span>
									</button>
								</a>
							<?php } else { ?>
								<button type="button" disabled="disabled" class="btn btn-warning btn-block">
									<?php echo $lang['msgnobalance']; ?></span>
								</button>
							<?php }
						} else { ?>
							<a href="" data-toggle="modal" class="text-white" data-target="#Login">
								<button type="button" class="btn btn-info btn-block text-white">
									<i class="fas fa-user-alt"></i> <?php echo $lang['login']; ?>
								</button>
							</a>
						<?php } ?>
					</div>
				</div>
			</div>
			<div class="col-lg-8 col-md-8 col-xs-8">
				<div class="row">
					<div class="col-lg-12 col-md-12 col-xs-12">
						<div class="shadow-sm p-3 mb-1 bg-white rounded">
							<span class="badge badge-primary">
								<font size="+1">
									<?php echo $r_sel->name ?>
								</font>
							</span>
							<span class="badge badge-secondary">
								<font size="+1">
									<?php echo $lang['type']; ?>:
									<?php echo $lang['categorystore' . $r_sel->category . '']; ?>
								</font>
							</span>
							<span class="badge badge-info">
								<font size="+1">
									<?php
									echo $lang['amount']; ?>: <?php echo $r_sel->amount;
																	if ($r_sel->category == 1) {
																		echo " " . $lang['days'];
																	}
																	?>
								</font>
							</span>
						</div>
					</div>
					<div class="col-lg-12 col-md-12 col-xs-12">
						<div class="shadow-sm p-3 mb-5 bg-white rounded">
							<?php echo $r_sel->description ?>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>