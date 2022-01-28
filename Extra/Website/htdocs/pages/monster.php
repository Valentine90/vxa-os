<?php
$id = $_GET['id'];

$json 		= json_decode(file_get_contents('wiki/json/Enemies.json'));
$ritems		= json_decode(file_get_contents('wiki/json/Items.json'));
$rweapons	= json_decode(file_get_contents('wiki/json/Weapons.json'));
$rarmors	= json_decode(file_get_contents('wiki/json/Armors.json'));

foreach ($json as $registro) :

	if (@$registro->name == $id) { ?>

		<div class="row" style="font-size: 15px">
			<div class="col-lg-1">
				<img class="img-responsive" src="wiki/imgs/monsters/<?php echo @$registro->name ?>.png">
			</div>
			<div class="col-lg-8">
				<h2><?php echo @$registro->name ?></h2>
			</div>
			<div class="col-lg-12">
				<div class="progress">
					<div class="progress-bar bg-danger" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">HP <?php echo @$registro->params[0]; ?></div>
				</div>
			</div>
			<div class="col-lg-3">
				<font style="color: #836FFF;">
					<i class="fas fa-brain"></i> Exp: <strong><?php echo @$registro->exp ?></strong>
				</font>
				<br>
				<font style="color: #FFA500">
					<i class="fas fa-coins"></i><?php echo $lang['gold'] ?>:<strong><?php echo @$registro->gold ?></strong>
				</font>
			</div>

			<div class="col-lg-3">
				<font style="color: #FF4500">
					<strong>
						<i class="fas fa-dice"></i><?php echo $lang['atk'] ?>:<?php echo @$registro->params[2]; ?>
					</strong>
				</font>
				<br>
				<font style="color: #FF1493">
					<strong>
						<i class="fas fa-shield-alt"></i><?php echo $lang['def'] ?>:<?php echo @$registro->params[3]; ?>
					</strong>
				</font>
				<br>
				<font style="color: #4B0082">
					<strong>
						<i class="fas fa-magic"></i><?php echo $lang['mat'] ?>:<?php echo @$registro->params[4]; ?>
					</strong>
				</font>
				<br>
				<font style="color: #7B68EE">
					<strong>
						<i class="fas fa-user-shield"></i><?php echo $lang['mdf'] ?>:<?php echo @$registro->params[5]; ?>
					</strong>
				</font>
				<br>
				<font style="color: #008B8B">
					<strong>
						<i class="fas fa-tachometer-alt"></i><?php echo $lang['agi'] ?>:<?php echo @$registro->params[6]; ?>
					</strong>
				</font>
				<br>
				<font style="color: #FFA500">
					<strong>
						<i class="fab fa-canadian-maple-leaf"></i><?php echo $lang['luk'] ?>:<?php echo @$registro->params[7]; ?>
					</strong>
				</font>
				<br>
			</div>
			<div class="col-lg-6">
				<?php
				foreach ($ritems as $rowitem) :

					$x = intval(@$rowitem->icon_index % 16) * 24;
					$y = intval(@$rowitem->icon_index / 16) * 24;

					if (@$registro->name == @$registro->name and @$rowitem->id == @$registro->drop_items[0]->data_id and @$registro->drop_items[0]->kind == 1) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowitem->name; ?>
					<?php }

					if (@$registro->name == @$registro->name and @$rowitem->id == @$registro->drop_items[1]->data_id and @$registro->drop_items[1]->kind == 1) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowitem->name; ?>
					<?php }

					if (@$registro->name == @$registro->name and @$rowitem->id == @$registro->drop_items[2]->data_id and @$registro->drop_items[2]->kind == 1) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowitem->name; ?>
					<?php } ?>

				<?php endforeach;  ?>

				<?php
				foreach ($rweapons as $rowweapons) :

					$x = intval(@$rowweapons->icon_index % 16) * 24;
					$y = intval(@$rowweapons->icon_index / 16) * 24;

					if (@$registro->name == @$registro->name and @$rowweapons->id == @$registro->drop_items[0]->data_id and @$registro->drop_items[0]->kind == 2) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowweapons->name; ?>
					<?php }

					if (@$registro->name == @$registro->name and @$rowweapons->id == @$registro->drop_items[1]->data_id and @$registro->drop_items[1]->kind == 2) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowweapons->name; ?>
					<?php }

					if (@$registro->name == @$registro->name and @$rowweapons->id == @$registro->drop_items[2]->data_id and @$registro->drop_items[2]->kind == 2) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowweapons->name; ?>
					<?php } ?>

				<?php endforeach;  ?>

				<?php
				foreach ($rarmors as $rowarmors) :

					$x = intval(@$rowarmors->icon_index % 16) * 24;
					$y = intval(@$rowarmors->icon_index / 16) * 24;

					if (@$registro->name == @$registro->name and @$rowarmors->id == @$registro->drop_items[0]->data_id and @$registro->drop_items[0]->kind == 3) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowarmors->name; ?>
					<?php }

					if (@$registro->name == @$registro->name and @$rowarmors->id == @$registro->drop_items[1]->data_id and @$registro->drop_items[1]->kind == 3) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowarmors->name; ?>
					<?php }

					if (@$registro->name == @$registro->name and @$rowarmors->id == @$registro->drop_items[2]->data_id and @$registro->drop_items[2]->kind == 3) { ?>
						<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						<?php echo @$rowarmors->name; ?>
					<?php } ?>

				<?php endforeach;  ?>
			</div>
		</div>


<?php }
endforeach; ?>

<style type="text/css">
	.sprite {
		background-image: url(wiki/imgs/IconSet.png);
		background-size: auto;
		background-repeat: no-repeat;
		width: 24px;
		height: 24px;
		max-width: 100%;
	}
</style>