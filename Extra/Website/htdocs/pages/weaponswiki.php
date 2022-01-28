<?php
$json = json_decode(file_get_contents('wiki/json/Weapons.json'));
$json2 = json_decode(file_get_contents('wiki/json/Enemies.json'));
?>
<div>
	<a href="/wikipedia">
		<button class="btn btn-primary"><i class="fas fa-arrow-alt-circle-left"></i> <?php echo $lang['wiki']; ?></button><br><br>
	</a>
</div>
<table class="table table-striped table-bordered">
	<thead class="thead-dark">
		<tr>
			<td><strong><?php echo $lang['icon']; ?></strong></td>
			<td><strong><?php echo $lang['nome']; ?></strong></td>
			<td><strong><?php echo $lang['descitem']; ?></strong></td>
			<td><strong><?php echo $lang['valor']; ?></strong></td>
			<td><strong><?php echo $lang['drop']; ?></strong></td>
			<td><strong><?php echo $lang['params']; ?></strong></td>

		</tr>
	</thead>

	<?php $n = 0;
	foreach ($json as $registro) : $n++;

		$x = intval(@$registro->icon_index % 16) * 24;
		$y = intval(@$registro->icon_index / 16) * 24;
	?>
		<tr class="a<?php echo $n; ?>">
			<td>
				<div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;">
				</div>
			</td>
			<td><?php echo @$registro->name; ?></td>
			<td><?php echo @$registro->description; ?></td>
			<td><?php echo @$registro->price; ?></td>
			<td>
				<?php
				foreach ($json2 as $registro2) :
					if (@$registro2->drop_items[0]->kind == 2 and @$registro2->drop_items[0]->data_id == @$registro->id) {
						echo "<a href='/monster/" . @$registro2->name . "'>" . @$registro2->name . "</a><br>";
					};
					if (@$registro2->drop_items[1]->kind == 2 and @$registro2->drop_items[1]->data_id == @$registro->id and @$registro2->drop_items[1]->data_id != @$registro2->drop_items[0]->data_id) {
						echo "<a href='/monster/" . @$registro2->name . "'>" . @$registro2->name . "</a><br>";
					};
					if (@$registro2->drop_items[2]->kind == 2 and @$registro2->drop_items[2]->data_id == @$registro->id and @$registro2->drop_items[2]->data_id != @$registro2->drop_items[1]->data_id) {
						echo "<a href='/monster/" . @$registro2->name . "'>" . @$registro2->name . "</a><br>";
					};
				endforeach;
				?>
			</td>
			<td><?php
				if (@$registro->params[0] == 0) {
				} else {
					echo @"HP: " . @$registro->params[0] . "<br>";
				}
				if (@$registro->params[1] == 0) {
				} else {
					echo @"MP: " . @$registro->params[1] . "<br>";
				}
				if (@$registro->params[2] == 0) {
				} else {
					echo @"Atk: " . @$registro->params[2] . "<br>";
				}
				if (@$registro->params[3] == 0) {
				} else {
					echo @"Def: " . @$registro->params[3] . "<br>";
				}
				if (@$registro->params[4] == 0) {
				} else {
					echo @"MAtk: " . @$registro->params[4] . "<br>";
				}
				if (@$registro->params[5] == 0) {
				} else {
					echo @"DMgc: " . @$registro->params[5] . "<br>";
				}
				if (@$registro->params[6] == 0) {
				} else {
					echo @"Agi: " . @$registro->params[6] . "<br>";
				}
				if (@$registro->params[7] == 0) {
				} else {
					echo @"Luk: " . @$registro->params[7] . "<br>";
				}
				?>
			</td>

		</tr>
	<?php endforeach; ?>
</table>

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