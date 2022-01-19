<?php

	$soma 	= mysqli_query($con, "SELECT SUM(percentual) FROM reward");
	$row 	= mysqli_fetch_array($soma);

	$num 	= $row['SUM(percentual)'];

	$x 		= mt_rand(1, $num);

	$lul = mysqli_query($con, "SELECT * FROM reward");

	while ($a = mysqli_fetch_object($lul))
	{
		$x = $x - $a->percentual;
		if($x <= 0)
		{
		    echo $a->nome;
		    break;
		}
			
	}
