<?php

$class = $_GET['id'];

$rskills = str_replace('@', '', file_get_contents('wiki/json/Skills.json'));
$rclasses = str_replace('@', '', file_get_contents('wiki/json/Classes.json'));

$skills = json_decode($rskills);
$classes = json_decode($rclasses);

?>
<div>
	<a href="/class">
		<button class="btn btn-primary"><i class="fas fa-arrow-alt-circle-left"></i> <?php echo $lang['wiki']; ?></button><br><br>
	</a>
</div>
<div class="row">
	<div class="col-md-12">
		<h5><?php echo $lang['infoskill'] . " " . $class ?></h5>
	</div>
	<?php foreach ($classes as $classe) :
		if (@$classe->name === $class) :
			foreach ($classe->learnings as $sk) :
				foreach ($skills as $skill) :
					if (@$skill->id == $sk->skill_id) :
						$x = intval(@$skill->icon_index % 16) * 24;
						$y = intval(@$skill->icon_index / 16) * 24; ?>
						<div class="col-md-12 mt-3">
							<div class="card">
								<ul class="list-group list-group-flush">
									<li class="list-group-item">
										<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;">
										</div>
										<strong><?php echo $lang['nome'] ?>:</strong> <?php echo $skill->name ?>
									</li>
									<li class="list-group-item">
										<strong><?php echo $lang['level'] ?>:</strong> <?php echo $sk->level ?>
									</li>
									<li class="list-group-item">
										<strong><?php echo $lang['description'] ?>:</strong> <?php echo $skill->description ?>
									</li>
									<li class="list-group-item">
										<strong><?php echo $lang['mpcost'] ?>:</strong> <?php echo $skill->mp_cost ?>
									</li>
								</ul>
							</div>
						</div>
			<?php
					endif;
				endforeach;
			endforeach;
			?>

		<?php endif; ?>
	<?php endforeach; ?>
</div>

<style type="text/css">
	.a1 {
		display: none;
	}

	.sprite {
		background-image: url(wiki/imgs/IconSet.png);
		background-size: auto;
		background-repeat: no-repeat;
		width: 24px;
		height: 24px;
		max-width: 100%;
	}
</style>