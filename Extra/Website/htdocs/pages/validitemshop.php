<?php
if ($conectado == 1 and $acesso_g >= 1) {
    if (isset($_FILES['arquivo']['name']) && $_FILES['arquivo']['error'] == 0) {
        $nameitem       = $_POST['nameitem'];
        $priceitem      = $_POST['priceitem'];
        $categoryitem   = $_POST['categoryitem'];
        $amountitem     = $_POST['amountitem'];
        $descitem       = $_POST['descitem'];
        $itemid         = $_POST['itemid'];

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
            $destino = 'imgs/shop/icons/' . $novoNome;

            // tenta mover o arquivo para o destino
            if (@move_uploaded_file($arquivo_tmp, $destino)) {
                if (mysqli_query($con, "INSERT INTO `store` (`id`, `category`, `name`, `description`, `price`, `img`, `amount`, `purchased`, `item_id`) VALUES (NULL, '$categoryitem', '$nameitem', '$descitem', '$priceitem', '$novoNome', '$amountitem', '0', '$itemid')")) {
?>
                    <div class="alert alert-success mt-3" role="alert">
                        <?php echo $lang['msgaddsuccess']; ?><br>
                        <a href="/managershop"><?php echo $lang['msgback']; ?></a>
                    </div>

<?php
                }
            } else
                echo 'Erro ao salvar o arquivo. Aparentemente você não tem permissão de escrita.<br />';
        } else
            echo 'Você poderá enviar apenas arquivos "*.jpg;*.jpeg;*.gif;*.png"<br />';
    } else
        echo 'Você não enviou nenhum arquivo!';
}
?>