<?php

if ($conectado == 1 and $acesso_g >= 2) {

    $id = $_POST['id'];
    $username = $_POST['username'];
    $email = $_POST['email'];
    $group = $_POST['group'];
    $vip_time = $_POST['vip_time'];
    $cash = $_POST['cash'];

    $h = strtotime($vip_time . ' day', time());

    if (mysqli_query($con, "UPDATE `accounts` SET 
    `username` = '$username', 
    `email` = '$email', 
    `group` = '$group', 
    `vip_time` = '$h', 
    `cash` = '$cash' WHERE `id` = $id")) : ?>
        <div class="alert alert-success mt-3" role="alert">
            <?php echo $lang['msgeditsuccess']; ?><br>
            <a href="/manageraccounts"><?php echo $lang['msgback']; ?></a>
        </div>

<?php
    endif;
}
