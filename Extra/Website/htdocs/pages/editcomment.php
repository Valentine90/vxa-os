<?php

if ($conectado == 1):

    $id = $_POST['id'];
    $comment = $_POST['comment'];

    if(mysqli_query($con, "UPDATE actors SET comment = '$comment' WHERE id = '$id'")): 
        echo "Ok!";
    else: 
        echo "Erro!";
    endif;

endif;