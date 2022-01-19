	<div class="row">
		<div class="col-lg-12 mb-3">
			<strong><?php echo $lang['rank'] ?></strong>
		</div>
		<div class="col-md-12">
			<table id="example" style="width:100%" class="display">
				<thead class="thead-dark">
					<tr>
						<th scope="col"><i class="fas fa-crown"></i></th>
						<th scope="col"><?php echo $lang['nome']; ?></th>
						<th scope="col"><?php echo $lang['level']; ?></th>
						<th scope="col"><?php echo $lang['exprank']; ?></th>
					</tr>
				</thead>
				<tbody>
					<?php
					$rank 			= mysqli_query($con, "SELECT * FROM actors ORDER BY exp DESC LIMIT 0, $max_rank");
					$cont 			= 0;
					while ($row 	= mysqli_fetch_object($rank)) {
						$cont++;
					?>
						<tr>
							<th scope="row"><?php echo $cont; ?></th>
							<td><a href="/char/<?php echo $row->name; ?>"><?php echo $row->name; ?></a></td>
							<td><?php echo $row->level; ?></td>
							<td><?php echo number_format($row->exp, 2, ".", "."); ?></td>
						</tr>
					<?php
					}
					?>
				</tbody>
			</table>
		</div>
	</div>
	<script src="js/jquery.dataTables.min.js"></script>
	<script>
		$(document).ready(function() {
			$('#example').dataTable({
			})
		});
	</script>