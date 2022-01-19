<?php
if (isset($_GET['id'])) {
    $name           = $_GET['id'];
    $sel_person     = mysqli_query($con, "SELECT * FROM actors WHERE name = '$name'");
    $row_p          = mysqli_fetch_object($sel_person);
    $ac             = mysqli_query($con, "SELECT * FROM accounts WHERE id = " . $row_p->account_id . "");
    $row_ac         = mysqli_fetch_object($ac);
    $ban            = mysqli_query($con, "SELECT * FROM ban_list WHERE account_id = " . $row_p->account_id . "");
    $row_ban        = mysqli_fetch_object($ban);
    $count_ban      = mysqli_num_rows($ban);
    $aguild         = mysqli_query($con, "SELECT * FROM guilds WHERE id = " . $row_p->guild_id . "");
    $row_guild      = mysqli_fetch_object($aguild);
    $date           = time();
    $vip            = $row_ac->vip_time;
    if ($date < $vip) {
        $status_vip = 1;
    } else {
        $status_vip = 0;
    }

    $armors         = str_replace('@', '', file_get_contents('wiki/json/Armors.json'));
    $weapons        = str_replace('@', '', file_get_contents('wiki/json/Weapons.json'));
    $rarmors        = json_decode($armors);
    $rweapons       = json_decode($weapons);

    $eq             = mysqli_query($con, "SELECT * FROM actor_equips WHERE actor_id = " . $row_p->id . " ORDER BY slot_id");
}
?>
<link rel="stylesheet" type="text/css" href="css/char.css">
<div class="profile">
    <div class="profile-header">
        <div class="profile-header-cover"></div>
        <div class="profile-header-content">
            <div class="profile-header-img">
                <?php
                $char_img = "wiki/imgs/Characters/" . $row_p->character_name . ".png";
                list($width_img, $height_img) = getimagesize($char_img);
                if (strstr($row_p->character_name, '$') == true) :
                    $width_end = $width_img / 3;
                    $height_end = $height_img / 4;
                else :
                    $width_end = $width_img / 12;
                    $height_end = $height_img / 8;
                endif;

                $x = ($row_p->character_index % 4 * 3 + 1) * $width_end;
                $y = ($row_p->character_index / 4 * 4) * $height_end;

                $w_f = $width_end."px";
                $h_f = $height_end."px";

                $im = "url(" . $char_img . ")";

                ?>
                <div class="sprite" style="background-position: <?php echo "-" . $x . "px -" . $y . "px" ?>;">
                </div>

                <style>
                    .sprite {
                        background-image: <?php echo $im; ?>;
                        background-size: auto;
                        background-repeat: no-repeat;
                        width: <?php echo $w_f; ?>;
                        height: <?php echo $h_f; ?>;
                        max-width: 100%;
                        margin: auto;
                    }
                </style>


            </div>
            <ul class="profile-header-tab nav nav-tabs nav-tabs-v2">
                <li class="nav-item">
                    <a class="nav-link">
                        <div class="nav-field"><?php echo $lang['level']; ?></div>
                        <div class="nav-value"> <?php echo $row_p->level; ?></div>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link">
                        <div class="nav-field"><?php echo $lang['sex']; ?></div>
                        <?php if ($row_p->sex == 1) { ?>
                            <div class="nav-value"><?php echo $lang['female']; ?></div>
                        <?php } else { ?>
                            <div class="nav-value"><?php echo $lang['male']; ?></div>
                        <?php } ?>
                    </a>
                </li>
                <?php if ($row_p->guild_id != 0) { ?>
                    <li class="nav-item">
                        <a href="/guild/<?php echo $row_guild->name; ?>" class="nav-link">
                            <div class="nav-field"><?php echo $lang['guild']; ?></div>
                            <div class="nav-value"> <?php echo $row_guild->name; ?></div>
                        </a>
                    </li>
                <?php } ?>
            </ul>

        </div>
    </div>

    <div class="profile-container">
        <div class="profile-sidebar">
            <div class="desktop-sticky-top">
                <h4><?php echo $row_p->name; ?></h4>
                <?php if ($row_ac->group > 0) { ?>
                    <p>
                        <font style="color:chocolate"><i class="fas fa-dragon"></i> <strong><?php echo $lang['staff']; ?></strong></font>
                    </p>
                <?php } ?>
                <?php if ($status_vip == 1) { ?>
                    <p>
                        <font color="#6A5ACD"><i class="fas fa-medal"></i> <strong><?php echo $lang['playervip']; ?></strong></font>
                    </p>
                <?php } ?>
                <div class="progress">
                    <div class="progress-bar bg-danger" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">HP <?php echo $row_p->mhp; ?></div>
                </div>
                <div class="progress mt-1">
                    <div class="progress-bar bg-primary" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">MP <?php echo $row_p->mmp; ?></div>
                </div>
                <hr class="mt-1 mb-1" />
                <div>
                    <strong><?php echo $lang['lastlogin']; ?>:</strong> <?php echo utf8_encode(strftime('' . $lang['data'] . '', $row_p->last_login)) ?>
                </div>
                <hr class="mt-1 mb-1" />
                <div>
                    <strong><?php echo $lang['creationdata']; ?>:</strong> <?php echo utf8_encode(strftime('' . $lang['data'] . '', $row_p->creation_date)) ?>
                </div>
                <?php if ($count_ban == 1) { ?>
                    <div>
                        <strong style="color:#DC143C;font-weight: bold;"><?php echo $lang['ban']; ?>:</strong> <?php echo utf8_encode(strftime('' . $lang['data'] . '', $row_ban->ban_date)) ?>
                    </div>
                <?php } ?>

                <?php if ($row_p->online == 1) { ?>
                    <hr class="mt-1 mb-1" />
                    <div>
                        <strong>Status:</strong>
                        <font style="color:#1E90FF;font-weight: bold;"><?php echo $lang['onon']; ?></font>
                    </div>
                <?php } else { ?>
                    <hr class="mt-1 mb-1" />
                    <div>
                        <strong>Status:</strong>
                        <font style="color:#DC143C;font-weight: bold;"><?php echo $lang['onoff']; ?></font>
                    </div>
                <?php } ?>
            </div>
        </div>

        <div class="profile-content">
            <div class="row">
                <div class="col-lg-12">
                    <div class="tab-content p-0">
                        <div class="tab-pane fade active show" id="profile-followers">
                            <h5><i><?php echo $lang['comment']; ?>:</i></h5>
                            <p><?php echo htmlspecialchars($row_p->comment); ?></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>