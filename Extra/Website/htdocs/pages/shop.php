<div class="row">
	<?php if ($conectado == 1) { ?>
		<div class="col-lg-12 mt-2 mb-4">
			<i class="far fa-gem"> </i> <strong><?php echo $lang['saldo']; ?> <?php echo $account_cash . " " . $cash_name; ?></strong>
		</div>
	<?php } ?>



	<?php

	$list1 		= mysqli_query($con, "SELECT * FROM store ORDER BY id DESC LIMIT 0,2");
	$list2 		= mysqli_query($con, "SELECT * FROM store ORDER BY id DESC LIMIT 2,$max_item_store");

	?>


	<div class="col-lg-12">
		<div class="row row-cols-1 row-cols-md-2">
			<?php while ($row_list1 = mysqli_fetch_object($list1)) {  ?>
				<div class="col mb-4">
					<a href="/itemshop/<?php echo $row_list1->id; ?>">
						<div class="card">
							<img src="imgs/shop/icons/<?php echo $row_list1->img ?>" class="card-img-top  mx-auto d-block" alt="...">
							<div class="card-body text-center">
								<strong class="card-title"><?php echo $row_list1->name; ?></strong><br>
								<small class="text-muted">
									<?php if ($discount == 0) {
										echo $row_list1->price . " " . $cash_name;
									} else {
										$calc 	= $row_list1->price - $row_list1->price * $discount / 100; ?>
										<span class="badge badge-warning"><strong>-<?php echo $discount; ?>%</strong></span>
										<small>
											<strike>
												<?php echo $row_list1->price; ?>
											</strike>
										</small>
										<strong>
											<?php echo $calc . " " . $cash_name; ?>

										</strong>
									<?php } ?>
								</small>
							</div>
							<div class="card-footer">
								<button type="submit" name="okaypayment" class="btn btn-info btn-block btn-sm mb-1 float-right">
									<i class="fas fa-shopping-cart"><strong></i> <?php echo $lang['bt_buy']; ?></strong>
								</button>
							</div>
						</div>
					</a>
				</div>
			<?php } ?>
		</div>
	</div>

	<div class="col-lg-12 mt-1">
		<div class="row row-cols-1 row-cols-md-2">
			<?php while ($row_list2 = mysqli_fetch_object($list2)) {  ?>
				<div class="col mb-4">
					<a href="/itemshop/<?php echo $row_list2->id; ?>">
						<div class="card h-100">
							<img src="imgs/shop/icons/<?php echo $row_list2->img ?>" class="card-img-top  mx-auto d-block" alt="...">
							<div class="card-body text-center">
								<h5 class="card-title"><?php echo $row_list2->name; ?></h5>
								<small class="text-muted">
									<?php if ($discount == 0) {
										echo $row_list2->price . " " . $cash_name;
									} else {
										$calc 	= $row_list2->price - $row_list2->price * $discount / 100; ?>
										<span class="badge badge-warning"><strong>-<?php echo $discount; ?>%</strong></span>
										<small>
											<strike>
												<?php echo $row_list2->price; ?>
											</strike>
										</small>
										<strong>
											<?php echo $calc . " " . $cash_name; ?>

										</strong>
									<?php } ?>
								</small>
							</div>
							<div class="card-footer">
								<button type="submit" name="okaypayment" class="btn btn-info btn-block btn-sm mb-1 float-right">
									<i class="fas fa-shopping-cart"><strong></i> <?php echo $lang['bt_buy']; ?></strong>
								</button>
							</div>
						</div>
					</a>
				</div>
			<?php } ?>
		</div>
	</div>
</div>