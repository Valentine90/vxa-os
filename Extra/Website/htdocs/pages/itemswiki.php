<?php
$arquivo = str_replace('@', '', file_get_contents('wiki/json/Items.json'));
$arquivo2 = str_replace('@', '', file_get_contents('wiki/json/Enemies.json'));

$json = json_decode($arquivo);
$json2 = json_decode($arquivo2);
?>

<style type="text/css">


</style>


<div class="sprite sprite--frog"></div>
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
			<td><strong><?php echo $lang['drop']; ?></strong></td>
			<td><strong><?php echo $lang['valor']; ?></strong></td>
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
			<td>
				<?php
				foreach ($json2 as $registro2) :
					if (@$registro2->drop_items[0]->kind == 1 and @$registro2->drop_items[0]->data_id == @$registro->id) {
						echo "<a href='/monster/" . @$registro2->name . "'>" . @$registro2->name . "</a><br>";
					};
					if (@$registro2->drop_items[1]->kind == 1 and @$registro2->drop_items[1]->data_id == @$registro->id and @$registro2->drop_items[1]->data_id != @$registro2->drop_items[0]->data_id) {
						echo "<a href='/monster/" . @$registro2->name . "'>" . @$registro2->name . "</a><br>";
					};
					if (@$registro2->drop_items[2]->kind == 1 and @$registro2->drop_items[2]->data_id == @$registro->id and @$registro2->drop_items[2]->data_id != @$registro2->drop_items[1]->data_id and @$registro2->drop_items[0]->data_id != @$registro2->drop_items[2]->data_id) {
						"<a href='/monster/" . @$registro2->name . "'>" . @$registro2->name . "</a><br>";
					};
				endforeach;
				?>
			</td>
			<td><?php echo @$registro->price; ?></td>

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