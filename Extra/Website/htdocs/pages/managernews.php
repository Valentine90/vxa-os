<?php if ($conectado == 1 and $acesso_g >= 2) { ?>

	<section class="py-3 header">

		<div class="row">
			<div class="col-md-12">


				<blockquote class="blockquote">
					<strong><?php echo $lang['admnews']; ?></strong>
				</blockquote>
				<!-- Tabs nav -->
				<div class="nav flex-column nav-pills nav-pills-custom" id="v-pills-tab" role="tablist" aria-orientation="vertical">
					<a class="nav-link mb-3 p-3 shadow active" id="v-pills-home-tab" data-toggle="pill" href="#v-pills-home" role="tab" aria-controls="v-pills-home" aria-selected="true">
						<i class="fas fa-plus"></i>
						<span class="font-weight-bold small text-uppercase"><small><?php echo $lang['addnewsbutton']; ?></small></span></a>

					<a class="nav-link mb-3 p-3 shadow" id="v-pills-profile-tab" data-toggle="pill" href="#v-pills-profile" role="tab" aria-controls="v-pills-profile" aria-selected="false">
						<i class="fas fa-edit"></i>
						<span class="font-weight-bold small text-uppercase"><small><?php echo $lang['editnewsbutton']; ?></small></span></a>
				</div>
			</div>






			<div class="col-md-12">
				<!-- Tabs content -->
				<div class="tab-content" id="v-pills-tabContent">
					<div class="tab-pane fade bg-white show active" id="v-pills-home" role="tabpanel" aria-labelledby="v-pills-home-tab">

						<form action="/validnews" method="post" enctype="multipart/form-data">

							<div class="form-group">
								<input type="text" class="form-control" name="titlenews" required="required" placeholder="<?php echo $lang['newstitle']; ?>">
							</div>

							<div class="form-group">
								<textarea required="required" name="contentnews" id="contentnews" class="form-control"></textarea>
							</div>

							<script type="text/javascript">
								CKEDITOR.replace('contentnews');
							</script>

							<button type="submit" class="btn btn-dark btn-sm"><?php echo $lang['bt_validar']; ?></button>
						</form>

					</div>






					<div class="tab-pane fade bg-white p-1" id="v-pills-profile" role="tabpanel" aria-labelledby="v-pills-profile-tab">
						<?php $list1 		= mysqli_query($con, "SELECT * FROM news ORDER BY id DESC"); ?>
						<div class="col-lg-12">
							<div class="row row-cols-1 row-cols-md-3">
								<?php while ($row_list1 = mysqli_fetch_object($list1)) {  ?>
									<div class="col mb-4">
										<div class="card-body">
											<strong class="card-title"><?php echo $row_list1->title; ?></strong><br>
										</div>
										<div class="card-footer">
											<button type="submit" name="okaypayment" data-toggle="modal" data-target="#editItem<?php echo $row_list1->id; ?>" class="btn btn-info btn-sm mb-1 btn-block">
												<?php echo $lang['bt_edit']; ?>
											</button>

										</div>
										</a>
									</div>
								<?php } ?>
							</div>
							<?php $list2 			= mysqli_query($con, "SELECT * FROM news ORDER BY id DESC"); ?>
							<?php while ($row_list2 	= mysqli_fetch_object($list2)) {  ?>
								<div class="modal fade" id="editItem<?php echo $row_list2->id; ?>" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
									<div class="modal-dialog  modal-lg">
										<div class="modal-content">
											<div class="modal-header">
												<button type="button" class="close" data-dismiss="modal" aria-label="Close">
													<span aria-hidden="true">&times;</span>
												</button>
											</div>
											<div class="modal-body">
												<form action="/editnews" method="post">
													<div class="form-group">
														<input type="text" class="form-control" readonly="readonly" name="news_id" value="<?php echo $row_list2->id; ?>" required="required">
													</div>

													<div class="form-group">
														<input type="text" class="form-control" name="titlenews" value="<?php echo $row_list2->title; ?>" required="required" placeholder="<?php echo $lang['newstitle']; ?>">
													</div>


													<div class="form-group">
														<textarea required="required" name="contentnews" id="contentnews<?php echo $row_list2->id; ?>" class="form-control" placeholder="<?php echo $lang['descitem']; ?>"><?php echo $row_list2->content; ?></textarea>
													</div>

													<script type="text/javascript">
														CKEDITOR.replace('contentnews<?php echo $row_list2->id; ?>');
													</script>

													<button type="submit" class="btn btn-dark btn-block"><?php echo $lang['bt_validar']; ?></button>

												</form>
												<a href="/deletenews/<?php echo $row_list2->id; ?>">
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