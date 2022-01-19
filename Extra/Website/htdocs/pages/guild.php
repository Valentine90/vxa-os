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

<?php
if (isset($_GET['id']))

$id 			= $_GET['id'];
$guild 			= mysqli_query($con, "SELECT * FROM guilds WHERE name = '$id' ORDER BY leader");
$row_guild		= mysqli_fetch_object($guild);
$members 		= mysqli_query($con, "SELECT * FROM actors WHERE guild_id = '$row_guild->id'"); {
?>
	<div class="row container">
		<table class="table table-striped table-bordered">
			<thead class="thead-dark">
				<tr>
					<td width="65px"><?php echo Flag($row_guild->flag); ?></td>
					<td>
						<h2 class="text-guild"><?php echo $row_guild->name; ?></h2>
					</td>
				</tr>
				<tr>
					<td colspan="2"><small><?php echo $row_guild->description; ?> <br>
							<strong><?php echo $lang['creationdata']; ?>:</strong> <?php echo utf8_encode(strftime('' . $lang['data'] . '', $row_guild->creation_date)) ?></small></td>
				</tr>
			</thead>
			<tbody>
				<?php while ($row_member = mysqli_fetch_object($members)) { ?>
					<tr class="text-center">
						<td colspan="2">
							<h5><a href="/char/<?php echo $row_member->name; ?>"><?php if ($row_guild->leader == $row_member->name) { ?> <i class="fas fa-chess-king"></i> <?php };
																																										echo $row_member->name; ?></h5></a>
						</td>
					</tr>
				<?php } ?>
			</tbody>
		</table>
	</div>
<?php } ?>