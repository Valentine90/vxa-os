<?php if ($conectado == 1 and $acesso_g >= 2) { ?>

    <form action="" method="post">
        <div class="form-group">
        <label>Nome da Box</label>
            <input type="text" class="form-control" name="name" placeholder="Nome da Box">
        </div>
        <div class="form-group">
        <label>Preço da Box</label>
            <input type="number" class="form-control" name="name" placeholder="Preço da Box">
        </div>
        <div class="form-group">
        <label>Limite de compra por conta</label>
            <input type="number" class="form-control" name="name" placeholder="0">
        </div>
        <div class="form-group">
        <label>Limite por tempo (em dias)</label>
            <input type="number" class="form-control" name="name" placeholder="0">
        </div>
    </form>

<?php }
