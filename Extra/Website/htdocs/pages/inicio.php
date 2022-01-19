<section class="header">
	<?php $news 	= mysqli_query($con, "SELECT * FROM news ORDER BY id DESC LIMIT 0, $max_news"); ?>
	<div class="row">
		<?php while ($row_news		= mysqli_fetch_object($news)) { ?>
			<div class="col-md-12 mb-3">
				<div class="card">
					<div class="card-header">
						<?php echo $row_news->title; ?>
						<br>
						<small><small><i class="fas fa-khanda"></i> <?php echo utf8_encode(strftime('' . $lang['data'] . '', $row_news->date)) ?></small></small>
					</div>
					<div class="card-body">
						<small><?php echo $row_news->content; ?></small>
					</div>
				</div>
			</div>
		<?php } ?>

	</div>
</section>