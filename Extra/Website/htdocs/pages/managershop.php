<?php if ($conectado == 1 and $acesso_g >= 2) { ?>

	<section class="py-3 header">

		<div class="row">
			<div class="col-md-12">
				<!-- Tabs nav -->
				<div class="nav flex-column nav-pills nav-pills-custom" id="v-pills-tab" role="tablist" aria-orientation="vertical">
					<a class="nav-link mb-3 p-3 shadow active" id="v-pills-home-tab" data-toggle="pill" href="#v-pills-home" role="tab" aria-controls="v-pills-home" aria-selected="true">
						<i class="fas fa-plus"></i>
						<span class="font-weight-bold small text-uppercase"><small><?php echo $lang['shopadditem']; ?></small></span></a>

					<a class="nav-link mb-3 p-3 shadow" id="v-pills-profile-tab" data-toggle="pill" href="#v-pills-profile" role="tab" aria-controls="v-pills-profile" aria-selected="false">
						<i class="fas fa-edit"></i>
						<span class="font-weight-bold small text-uppercase"><small><?php echo $lang['shopitemedit']; ?></small></span></a>
				</div>
			</div>


			<div class="col-md-12">
				<!-- Tabs content -->
				<div class="tab-content" id="v-pills-tabContent">
					<div class="tab-pane fade bg-white show active" id="v-pills-home" role="tabpanel" aria-labelledby="v-pills-home-tab">

						<form action="/validitemshop" method="post" enctype="multipart/form-data">

							<div class="form-group">
								<input type="text" class="form-control" name="nameitem" required="required" placeholder="<?php echo $lang['nameitem']; ?>">
							</div>

							<div class="form-group">
								<input type="text" class="form-control" name="priceitem" required="required" placeholder="<?php echo $lang['priceitem']; ?>">
							</div>

							<small><?php echo $lang['categoryitem']; ?></small>
							<div class="form-group">
								<select required="required" class="form-control" name="categoryitem">
									<option value="1"><?php echo $lang['category1']; ?></option>
									<option value="2"><?php echo $lang['category2']; ?></option>
									<option value="3"><?php echo $lang['category3']; ?></option>
									<option value="4"><?php echo $lang['category4']; ?></option>
								</select>
							</div>

							<div class="form-group">
								<input type="text" class="form-control" name="itemid" required="required" placeholder="<?php echo $lang['itemid']; ?>">
							</div>

							<div class="form-group">
								<input type="text" class="form-control" name="amountitem" required="required" placeholder="<?php echo $lang['amountitem']; ?>">
							</div>
							<small><?php echo $lang['descitem']; ?></small>
							<div class="form-group">
								<textarea required="required" name="descitem" id="descitem" class="form-control" placeholder="<?php echo $lang['descitem']; ?>"></textarea>
							</div>

							<script type="text/javascript">
								CKEDITOR.replace('descitem');
							</script>
							<small><?php echo $lang['alertitemmsg']; ?></small>
							<div class="input-group mb-3">
								<div class="custom-file">
									<input required="required" type="file" name="arquivo" class="custom-file-input" id="inputGroupFile01" aria-describedby="inputGroupFileAddon01">
									<label class="custom-file-label" for="inputGroupFile01"><?php echo $lang['imgitem']; ?></label>
								</div>
							</div>

							<button type="submit" class="btn btn-dark btn-sm"><?php echo $lang['bt_validar']; ?></button>
						</form>

					</div>

					<div class="tab-pane fade bg-white p-1" id="v-pills-profile" role="tabpanel" aria-labelledby="v-pills-profile-tab">
						<?php $list1 		= mysqli_query($con, "SELECT * FROM store ORDER BY id DESC"); ?>
						<div class="col-lg-12">
							<div class="row row-cols-1 row-cols-md-3">
								<?php while ($row_list1 = mysqli_fetch_object($list1)) {  ?>
									<div class="col mb-4">
										<div class="card h-100">
											<img src="imgs/shop/icons/<?php echo $row_list1->img ?>" class="card-img-top ml-4" alt="...">
											<div class="card-body">
												<strong class="card-title"><?php echo $row_list1->name; ?></strong><br>
												<small class="text-muted"><?php echo $row_list1->price . " " . $cash_name ?></small>
											</div>
											<div class="card-footer">
												<button type="submit" name="okaypayment" data-toggle="modal" data-target="#editItem<?php echo $row_list1->id; ?>" class="btn btn-info btn-sm mb-1 btn-block">
													<?php echo $lang['bt_edit']; ?>
												</button>

											</div>
										</div>
										</a>
									</div>
								<?php } ?>
							</div>
							<?php $list2 			= mysqli_query($con, "SELECT * FROM store ORDER BY id DESC"); ?>
							<?php while ($row_list2 	= mysqli_fetch_object($list2)) {  ?>
								<div class="modal fade" id="editItem<?php echo $row_list2->id; ?>" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
									<div class="modal-dialog  modal-lg">
										<div class="modal-content">
											<div class="modal-header">
												<h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
												<button type="button" class="close" data-dismiss="modal" aria-label="Close">
													<span aria-hidden="true">&times;</span>
												</button>
											</div>
											<div class="modal-body">
												<form action="/edititemshop" method="post">
													<div class="form-group">
														<input type="text" class="form-control" readonly="readonly" name="store_id" value="<?php echo $row_list2->id; ?>" required="required">
													</div>

													<div class="form-group">
														<input type="text" class="form-control" name="nameitem" value="<?php echo $row_list2->name; ?>" required="required" placeholder="<?php echo $lang['nameitem']; ?>">
													</div>

													<div class="form-group">
														<input type="text" class="form-control" name="priceitem" value="<?php echo $row_list2->price; ?>" required="required" placeholder="<?php echo $lang['priceitem']; ?>">
													</div>

													<small><?php echo $lang['categoryitem']; ?></small>
													<div class="form-group">
														<select required="required" class="form-control" name="categoryitem">
															<option <?php if ($row_list2->category == 1) {
																		echo "selected='selected'";
																	} ?> value="1"><?php echo $lang['category1']; ?></option>
															<option <?php if ($row_list2->category == 2) {
																		echo "selected='selected'";
																	} ?> value="2"><?php echo $lang['category2']; ?></option>
															<option <?php if ($row_list2->category == 3) {
																		echo "selected='selected'";
																	} ?> value="3"><?php echo $lang['category3']; ?></option>
															<option <?php if ($row_list2->category == 4) {
																		echo "selected='selected'";
																	} ?> value="4"><?php echo $lang['category4']; ?></option>
														</select>
													</div>

													<div class="form-group">
														<input type="text" class="form-control" name="amountitem" value="<?php echo $row_list2->amount; ?>" required="required" placeholder="<?php echo $lang['amountitem']; ?>">
													</div>
													<small><?php echo $lang['descitem']; ?></small>
													<div class="form-group">
														<textarea required="required" name="descitem" id="descitem<?php echo $row_list2->id; ?>" class="form-control" placeholder="<?php echo $lang['descitem']; ?>"><?php echo $row_list2->description; ?></textarea>
													</div>

													<script type="text/javascript">
														CKEDITOR.replace('descitem<?php echo $row_list2->id; ?>');
													</script>

													<button type="submit" class="btn btn-dark btn-block"><?php echo $lang['bt_validar']; ?></button>

												</form>
												<a href="/deleteitemshop/<?php echo $row_list2->id; ?>">
													<button type="submit" name="okaypayment" class="btn btn-danger btn-sm btn-block mt-2">
														<?php echo $lang['bt_delete']; ?>
													</button>
												</a>

											</div>
										</div>
									</div>
								</div>
							<?php } ?>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>



<?php } ?>