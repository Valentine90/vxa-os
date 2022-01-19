<?php

$rclasses = str_replace('@', '', file_get_contents('wiki/json/Actors.json'));

$classes = json_decode($rclasses);

?>
<div>
	<a href="/wikipedia">
		<button class="btn btn-primary"><i class="fas fa-arrow-alt-circle-left"></i> <?php echo $lang['wiki']; ?></button><br><br>
	</a>
</div>
<div class="row">
	<?php $n = 0;
	foreach ($classes as $class) : $n++;

		$char_img = "wiki/imgs/Faces/" . @$class->face_name . ".png";

		$x = intval(@$class->face_index % 4) * 96;
		$y = intval(@$class->face_index / 4) * 96;

		$im = "url(" . $char_img . ")";

	?>
		<div id="a<?php echo $n ?>" class="col-md-3 text-center">
			<a style="text-decoration: none;" href="/skillswiki/<?php echo @$class->name; ?>">
				<div class="sprite<?php echo $n ?>" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;">
				</div>
				<h3 class="wiki"><?php echo @$class->name; ?></h3>
			</a>
		</div>

		<style>
			.sprite<?php echo $n ?> {
				background-image: <?php echo $im; ?>;
				background-size: auto;
				background-repeat: no-repeat;
				width: 96px;
				height: 96px;
				max-width: 100%;
				margin: auto;
			}
		</style>
	<?php endforeach; ?>
</div>

<style>
	#a1 {
		display: none;
	}
</style>