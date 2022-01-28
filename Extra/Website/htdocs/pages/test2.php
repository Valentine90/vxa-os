<?php
$rarmors		= json_decode(file_get_contents('wiki/json/Armors.json'));
$rweapons		= json_decode(file_get_contents('wiki/json/Weapons.json'));

$eq 			= mysqli_query($con, "SELECT * FROM actor_equips WHERE actor_id = '1' ORDER BY slot_id");

?>
<div class="row">
	<div class="col-lg-4">
		<div class="row">
			<?php while ($roweq 	= mysqli_fetch_object($eq)) {
				foreach ($rarmors as $rowitem) {
					$x = intval(@$rowitem->icon_index % 16) * 24;
					$y = intval(@$rowitem->icon_index / 16) * 24;

					if (@$rowitem->id == $roweq->equip_id and $roweq->slot_id != 0) { ?>
						<div class="col-lg-4 py-2" style="border: 1px solid #ccc;">
							<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;"></div>
						</div>
					<?php 	}
				}

				foreach ($rweapons as $we) {
					if ($roweq->slot_id == 0 and @$we->id == $roweq->equip_id) {
						$x1 = intval(@$we->icon_index % 16) * 24;
						$y1 = intval(@$we->icon_index / 16) * 24;
					?>
						<div class="col-lg-4  py-2" style="border: 1px solid #ccc;">
							<div class="sprite" style="background-position: <?php echo "-" . $x1 . "px -" . $y1 . "px" ?>;"></div>
						</div>
			<?php 	}
				}
			} ?>
		</div>
	</div>
</div>

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