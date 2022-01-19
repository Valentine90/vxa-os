<?php
$arquivo = str_replace('@', '', file_get_contents('wiki/json/Enemies.json'));

$json = json_decode($arquivo);
?>
<div>
	<a href="/wikipedia">
		<button class="btn btn-primary"><i class="fas fa-arrow-alt-circle-left"></i> <?php echo $lang['wiki']; ?></button><br><br>
	</a>
</div>
<table class="table table-striped table-bordered">
	<thead class="thead-dark">
		<tr>
			<td><strong><?php echo $lang['nome']; ?></strong></td>
			<td><strong><?php echo $lang['exprank']; ?></strong></td>
			<td><strong><?php echo $lang['HP']; ?></strong></td>
			<td><strong><?php echo $lang['gold']; ?></strong></td>

		</tr>
	</thead>
	<?php $n = 0;
	foreach ($json as $registro) : $n++ ?>
		<tr class="a<?php echo $n; ?>">
			<td><a href="/monster/<?php echo @$registro->name; ?>"><?php echo @$registro->name; ?></a></td>
			<td><?php echo @$registro->exp; ?></td>
			<td>
				<div class="progress">
					<div class="progress-bar bg-danger" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">HP <?php echo @$registro->params[0]; ?></div>
				</div>
			</td>
			<td><?php echo @$registro->gold; ?></td>

		</tr>
	<?php endforeach; ?>
</table>


<style type="text/css">
	.a1 {
		display: none;
	}
</style>