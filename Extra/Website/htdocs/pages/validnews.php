<?php
if ($conectado == 1 and $acesso_g >= 1) {
    $title      = $_POST['titlenews'];
    $content    = $_POST['contentnews'];
    $date       = time();

    if (mysqli_query($con, "INSERT INTO `news` (`id`, `title`, `content`, `date`, `writer`, `type`) VALUES (NULL, '$title', '$content', '$date', '$username', '1')")) {
?>
        <div class="alert alert-success mt-3" role="alert">
            <?php echo $lang['newsadd']; ?><br>
            <a href="/managernews"><?php echo $lang['msgback']; ?></a>
        </div>

<?php
    }
}
?>