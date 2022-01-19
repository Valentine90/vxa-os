<?php

if ($conectado == 1 and $acesso_g >= 2) {

$id = $_POST['id'];
$account_id = $_POST['account_id'];
$slot_id = $_POST['slot_id'];
$name = $_POST['name'];
$character_name = $_POST['character_name'];
$character_index = $_POST['character_index'];
$face_name = $_POST['face_name'];
$face_index = $_POST['face_index'];
$class_id = $_POST['class_id'];
$sex = $_POST['sex'];
$level = $_POST['level'];
$exp = $_POST['exp'];
$hp = $_POST['hp'];
$mp = $_POST['mp'];
$mhp = $_POST['mhp'];
$mmp = $_POST['mmp'];
$atk = $_POST['atk'];
$def = $_POST['def'];
$int = $_POST['int'];
$res = $_POST['res'];
$agi = $_POST['agi'];
$luk = $_POST['luk'];
$points = $_POST['points'];
$guild_id = $_POST['guild_id'];
$revive_map_id = $_POST['revive_map_id'];
$revive_x = $_POST['revive_x'];
$revive_y = $_POST['revive_y'];
$map_id = $_POST['map_id'];
$x = $_POST['x'];
$y = $_POST['y'];
$direction = $_POST['direction'];
$gold = $_POST['gold'];
$id = $_POST['id'];
$id = $_POST['id'];


if (mysqli_query($con, "UPDATE `actors` SET 
    `account_id` = '$account_id', 
    `slot_id` = '$slot_id', 
    `name` = '$name', 
    `character_name` = '$character_name', 
    `character_index` = '$character_index', 
    `face_name` = '$face_name', 
    `face_index` = '$face_index', 
    `class_id` = '$class_id', 
    `sex` = '$sex', 
    `level` = '$level', 
    `exp` = '$exp', 
    `hp` = '$hp', 
    `mp` = '$mp', 
    `mhp` = '$mhp', 
    `mmp` = '$mmp', 
    `atk` = '$atk', 
    `def` = '$def', 
    `int` = '$int', 
    `res` = '$res', 
    `agi` = '$agi', 
    `luk` = '$luk', 
    `points` = '$points', 
    `guild_id` = '$guild_id', 
    `revive_map_id` = '$revive_map_id', 
    `revive_x` = '$revive_x', 
    `revive_y` = '$revive_y', 
    `map_id` = '$map_id', 
    `x` = '$x', 
    `y` = '$y', 
    `direction` = '$direction', 
    `gold` = '$gold' WHERE `id` = $id")) : ?>
    <div class="alert alert-success mt-3" role="alert">
        <?php echo $lang['msgeditsuccess']; ?><br>
        <a href="/manageraccounts"><?php echo $lang['msgback']; ?></a>
    </div>

<?php
else :
    echo "error";
endif;

}