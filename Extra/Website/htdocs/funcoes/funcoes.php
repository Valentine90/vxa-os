
<?php

/* ---------------------------------------------

     ___  ___  ___  ___  ___  ___  ___  ___  ___  
    (___)(___)(___)(___)(___)(___)(___)(___)(___) 
           _  _  _  _     __    __   ____         
          / )( \( \/ )   / _\  /  \ / ___)        
          \ \/ / )  (   /    \(  O )\___ \        
           \__/ (_/\_)  \_/\_/ \__/ (____/        
     ___  ___  ___  ___  ___  ___  ___  ___  ___  
    (___)(___)(___)(___)(___)(___)(___)(___)(___) 


    ----------------------------------------------- */


include("config_main.php");

function Verificar($host, $port, $timeout)
{
    $tB = microtime(true);
    $fP = @fSockOpen($host, $port, $errno, $errstr, $timeout);
    if (!$fP) {
        return "down";
    }
    $tA = microtime(true);
    return round((($tA - $tB) * 1000), 0) . " ms";
}



function Flag($a)
{
    $altura     = 8;
    $largura    = 8;

    $flag       = explode(",", $a);
    $count      = count($flag);

    for ($i = 0; $i < $count;) {
        for ($j = $altura; $j > 0; $j--) {
            for ($k = $largura; $k > 0; $k--) {
                echo "<div class='draw_flag" . $flag[$i] . "'></div>";
                $i++;
            }
            echo "<br></div><div class='resetar'>";
        }
    }
}



function Category($a)
{
    switch ($a) {
        case 1:
            $a = "VIP";
            break;
        case 2:
            $a = "Consumables";
            break;
        case 3:
            $a = "Service";
            break;
    }
    return $a;
}

function antiSQL($sql)
{
    $sql = preg_replace("/(from|select|insert|delete|where|drop table|show tables|#|\*|--|\\\\)/", "", $sql);
    $sql = trim($sql);
    $sql = strip_tags($sql);
    // $sql = (get_magic_quotes_gpc()) ? $sql : addslashes($sql);
    return $sql;
}

?>