<!--                                              
 ___  ___  ___  ___  ___  ___  ___  ___  ___  
(___)(___)(___)(___)(___)(___)(___)(___)(___) 
       _  _  _  _     __    __   ____         
      / )( \( \/ )   / _\  /  \ / ___)        
      \ \/ / )  (   /    \(  O )\___ \        
       \__/ (_/\_)  \_/\_/ \__/ (____/        
 ___  ___  ___  ___  ___  ___  ___  ___  ___  
(___)(___)(___)(___)(___)(___)(___)(___)(___) 

-->



<div class="row py-4">

	<div class="col-md-12">

		<table class="table table-striped table-bordered">

			<thead class="thead-dark">

				<tr>
					<th scope="col"><?php echo $lang['flag']; ?></th>
					<th scope="col"><?php echo $lang['nome']; ?></th>
					<th scope="col"><?php echo $lang['leader']; ?></th>

				</tr>

			</thead>


			<tbody>
				<?php

				$rank 			= mysqli_query($con, "SELECT * FROM guilds ORDER BY name DESC LIMIT 0, $max_rank_guild");
				$cont 			= 0;
				while ($row 	= mysqli_fetch_object($rank)) {
					$cont++;
				?>
					<tr>
						<td width="20px"><?php echo Flag($row->flag); ?></td>
						<td><a href="/guild/<?php echo $row->name; ?>"><strong><?php echo $row->name; ?></strong></a><br>
							<small><?php echo $row->description; ?></small>
						</td>
						<td><a href="/char/<?php echo $row->leader; ?>"><?php echo $row->leader; ?></a></td>
					</tr>
				<?php
				}
				?>
			</tbody>

		</table>

	</div>

</div>