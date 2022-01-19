<?php
if ($conectado == 1 and $acesso_g >= 1) {
    $news_id   = $_POST['news_id'];
    $title      = $_POST['titlenews'];
    $content    = $_POST['contentnews'];

    if (mysqli_query($con, "UPDATE `news` SET `title` = '$title', `content` = '$content' WHERE `id` = '$news_id'")) { ?>
        <div class="alert alert-success mt-3" role="alert">
            <?php echo $lang['msgeditsuccess']; ?><br>
            <a href="/managernews"><?php echo $lang['msgback']; ?></a>
        </div>

<?php               } else {
        echo $lang['criterror'];
    }
}

?>