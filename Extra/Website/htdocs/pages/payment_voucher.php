<?php

/******
 * Upload de imagens
 ******/

// verifica se foi enviado um arquivo
if (isset($_FILES['arquivo']['name']) && $_FILES['arquivo']['error'] == 0) {
    $login  = $_POST['loginbuy'];
    $amount = $_POST['amountbuy'];
    $data   = time();

    $arquivo_tmp = $_FILES['arquivo']['tmp_name'];
    $nome = $_FILES['arquivo']['name'];

    // Pega a extensão
    $extensao = pathinfo($nome, PATHINFO_EXTENSION);

    // Converte a extensão para minúsculo
    $extensao = strtolower($extensao);

    // Somente imagens, .jpg;.jpeg;.gif;.png
    // Aqui eu enfileiro as extensões permitidas e separo por ';'
    // Isso serve apenas para eu poder pesquisar dentro desta String
    if (strstr('.jpg;.jpeg;.gif;.png', $extensao)) {
        // Cria um nome único para esta imagem
        // Evita que duplique as imagens no servidor.
        // Evita nomes com acentos, espaços e caracteres não alfanuméricos
        $novoNome = uniqid(time()) . '.' . $extensao;

        // Concatena a pasta com o nome
        $destino = 'imgs/payments_voucher/' . $novoNome;

        // tenta mover o arquivo para o destino
        if (@move_uploaded_file($arquivo_tmp, $destino)) {
            if (mysqli_query($con, "INSERT INTO `payment_voucher` (`id`, `account_id`, `date`, `amount`, `img`, `reader`, `okay`) VALUES (NULL, '$login', '$data', '$amount', '$novoNome', '0', '0')")) {
?>
                <div class="alert alert-success mt-3" role="alert">
                    <?php echo $lang['msgvouchersuccess']; ?><br>
                    <a href="/painel"><?php echo $lang['msgback']; ?></a>
                </div>

<?php
            } else {
                echo $lang['criterror'] . "Erro banco de dados!";
            }
        } else
            echo $lang['criterror'] . "Erro de arquivo!";
    } else
        echo "<div class='alert alert-warning mt-3' role='alert'>" . $lang['msgerrorfile'] . "*.jpg;*.jpeg;*.gif;*.png <br /><a href='/painel'> " . $lang['msgback'] . "</a></div>";
} else
    echo 'Você não enviou nenhum arquivo!';

?>