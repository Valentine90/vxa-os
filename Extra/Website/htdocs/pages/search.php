<div class="row">
	<div class="col-md-12">
		<table class="table table-striped">
			<thead class="thead-dark">
				<tr>
					<th scope="col"><?php echo $lang['nome']; ?></th>
					<th scope="col"><?php echo $lang['level']; ?></th>
				</tr>
			</thead>
			<tbody>
				<?php
				if ($_POST['search']) {
					$words 		= antiSQL($_POST['search']);
					$search  	= mysqli_query($con, "SELECT * FROM actors where name like '%$words%'");
					$count 		= mysqli_num_rows($search);
					while ($row_search = mysqli_fetch_object($search)) { ?>
						<tr>
							<td><a href="/char/<?php echo $row_search->name; ?>"><strong><?php echo $row_search->name; ?></strong></a></td>
							<td><?php echo $row_search->level; ?></td>
						</tr>
				<?php }
				} ?>
			</tbody>
		</table>
	</div>
</div>