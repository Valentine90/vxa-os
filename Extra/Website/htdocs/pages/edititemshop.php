<?php
if ($conectado == 1 and $acesso_g >= 1) {
    $store_id       = $_POST['store_id'];
    $nameitem       = $_POST['nameitem'];
    $priceitem      = $_POST['priceitem'];
    $categoryitem   = $_POST['categoryitem'];
    $amountitem     = $_POST['amountitem'];
    $descitem       = $_POST['descitem'];

    if (mysqli_query($con, "UPDATE `store` SET `category` = '$categoryitem', `name` = '$nameitem', `description` = '$descitem', `price` = '$priceitem', `amount` = '$amountitem' WHERE `id` = '$store_id'")) { ?>
        <div class="alert alert-success mt-3" role="alert">
            <?php echo $lang['msgeditsuccess']; ?><br>
            <a href="/managershop"><?php echo $lang['msgback']; ?></a>
        </div>

<?php               } else {
        echo $lang['criterror'];
    }
}

?>