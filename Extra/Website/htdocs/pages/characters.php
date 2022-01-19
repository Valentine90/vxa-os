<div class="row">
	<div class="col-lg-12 mb-3">
		<strong><?php echo $whos_count . " " . $lang['whosonline']; ?></strong>
	</div>
	<div class="col-md-12">
		<table class="table table-striped">
			<thead class="thead-dark">
				<tr>
					<th scope="col">#</th>
					<th scope="col"><?php echo $lang['nome']; ?></th>
					<th scope="col"><?php echo $lang['level']; ?></th>
					<th scope="col"><?php echo $lang['guild']; ?></th>
				</tr>
			</thead>
			<tbody>
				<?php
				$rank 			= mysqli_query($con, "SELECT * FROM actors WHERE online = '1'");
				$cont 			= 0;
				while ($row 	= mysqli_fetch_object($rank)) {
					$g 			= mysqli_query($con, "SELECT * FROM guilds WHERE id = '" . $row->guild_id . "'");
					$g_row 		= mysqli_fetch_object($g);
					$cont++;
				?>
					<tr>
						<th scope="row"><?php echo $cont; ?></th>
						<td><a href="/char/<?php echo $row->name; ?>"><?php echo $row->name; ?></a></td>
						<td><?php echo $row->level; ?></td>
						<td><?php if ($row->guild_id != 0) { ?><a href="/guild/<?php echo $g_row->name; ?>"><?php echo $g_row->name; ?></a><?php } else {
																																		} ?></td>
					</tr>
				<?php
				}
				?>
			</tbody>
		</table>
	</div>
</div>