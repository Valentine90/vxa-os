<!--                                              
 ___  ___  ___  ___  ___  ___  ___  ___  ___  
(___)(___)(___)(___)(___)(___)(___)(___)(___) 
       _  _  _  _     __    __   ____         
      / )( \( \/ )   / _\  /  \ / ___)        
      \ \/ / )  (   /    \(  O )\___ \        
       \__/ (_/\_)  \_/\_/ \__/ (____/        
 ___  ___  ___  ___  ___  ___  ___  ___  ___  
(___)(___)(___)(___)(___)(___)(___)(___)(___) 

-->


<?php

if ($conectado == 1) {

  $date           = time();

  $vip            = $check_vip;

  if ($date < $vip) {
    $status_vip = 1;
  } else {
    $status_vip = 0;
  }

  $dia  = strftime("%d", $check_vip);
  $mes  = strftime("%m", $check_vip);
  $ano  = strftime("%Y", $check_vip);
  $hora = strftime("%H", $check_vip);
  $min  = strftime("%M", $check_vip);
  $sec  = strftime("%S", $check_vip);
  $date1 = strftime("%Y-%m-%d", time());
  $date2 = strftime("%Y-%m-%d", $vip);
  $datetime1 = date_create($date1);
  $datetime2 = date_create($date2);
  $interval = date_diff($datetime1, $datetime2);


?>



  <div class="row">

    <div class="col-2 mt-2 text-center">

      <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical">

        <!-- ---------------------------------------------

                BOTÃO ADD DIAMANTES // ADD CASH BUTTON

           ------------------------------------------------>
        <?php if ($acesso_g == 2) { ?>

          <a class="nav-link active" id="v-pills-profile-tab" data-toggle="pill" href="#v-pills-admin" role="tab" aria-controls="v-pills-profile" aria-selected="false"><i class="fas fa-tools"></i></a>

        <?php } ?>

        <!-- ---------------------------------------------

                BOTÃO INFORMAÇÕES DA CONTA // ACCOUNT INFORMATION BUTTON

           ------------------------------------------------>

        <a class="nav-link <?php if ($acesso_g == 0) { ?>active <?php } ?>" id="v-pills-home-tab" data-toggle="pill" href="#v-pills-info" role="tab" aria-controls="v-pills-home" aria-selected="true"><i class="fas fa-info"></i></a>

        <a class="nav-link" id="v-pills-profile-tab" data-toggle="pill" href="#v-pills-comment" role="tab" aria-controls="v-pills-profile" aria-selected="false"><i class="fas fa-comments"></i></a>

        <a class="nav-link" id="v-pills-profile-tab" data-toggle="pill" href="#v-pills-shield" role="tab" aria-controls="v-pills-profile" aria-selected="false"><i class="fas fa-user-shield"></i></a>

        <a class="nav-link" id="v-pills-profile-tab" data-toggle="pill" href="#v-pills-payment" role="tab" aria-controls="v-pills-profile" aria-selected="false"><i class="fas fa-file-invoice"></i></a>

      </div>
    </div>

    <div class="col-10">

      <div class="tab-content" id="v-pills-tabContent">


        <div class="tab-pane fade <?php if ($acesso_g == 0) { ?>show active <?php } ?>" id="v-pills-info" role="tabpanel" aria-labelledby="v-pills-home-tab">
          <?php if ($status_vip == 1) { ?>
            <p class="mt-3">
              <i class="fas fa-award"></i> <strong><?php echo $lang['msgexpvip']; ?> <?php echo $interval->format('%a dias'); ?> </strong><a href="/shop"><button type="button" class="btn btn-info btn-sm">Renovar</button></a>
            </p>
          <?php } else { ?>
            <p class="mt-3">
              <strong><?php echo $lang['msgsemvip']; ?></strong>
              <a href="/shop"><button type="button" class="btn btn-info btn-sm"><?php echo $lang['bt_vantagens']; ?></button></a>
              <?php echo $lang['ou']; ?>
              <a href="/shop"><button type="button" class="btn btn-info btn-sm"><?php echo $lang['bt_renovar']; ?></button></a>
            </p>
          <?php } ?>
          <hr>
          <blockquote class="blockquote"><?php echo $lang['history']; ?></blockquote>
          <table class="table table-striped">

            <tbody>
              <?php $records  = mysqli_query($con, "SELECT * FROM records WHERE account_id = '$contaid' ORDER BY id DESC");
              while ($r_rec = mysqli_fetch_object($records)) { ?>
                <tr>
                  <td><i class="far fa-clipboard"></i> <small><?php echo $r_rec->purchase_id; ?></small></td>
                  <td><small><?php echo $r_rec->text; ?></small></td>
                  <td><small><?php echo utf8_encode(strftime('' . $lang['data'] . '', $r_rec->date)); ?></small></td>
                </tr>
              <?php } ?>
            </tbody>
          </table>

        </div>

        <div class="tab-pane fade" id="v-pills-comment" role="tabpanel" aria-labelledby="v-pills-profile-tab">
          
            <?php
            $comment_p = mysqli_query($con, "SELECT * FROM actors WHERE account_id = $contaid");
            while ($row_comment = mysqli_fetch_object($comment_p)) : ?>
            <form action="/editcomment" class="form" method="post">
              <input type="hidden" name="id" value="<?php echo $row_comment->id; ?>">
              <div class="form-group">
                <label for="comment">
                  <h5><i><?php echo $lang['commentpanel']; ?> <?php echo $row_comment->name; ?></i></h5>
                </label>
                <textarea class="form-control" name="comment"><?php echo $row_comment->comment; ?></textarea>
              </div>
              <div class="form-group">
              <input type="submit" class="btn btn-primary btn-block" value="<?php echo $lang['bt_validar']; ?>">
            </div>
          </form>
            <?php endwhile; ?>
        </div>

        <!-- ---------------------------------------------

             MUDAR SENHA DA CONTA  // CHANGE PASSWORD

          ------------------------------------------------>
        <div class="tab-pane fade" id="v-pills-shield" role="tabpanel" aria-labelledby="v-pills-profile-tab">
          <blockquote class="blockquote  mt-3">
            <strong><?php echo $lang['msgaltsenha']; ?></strong>
          </blockquote>
          <form action="/changerpass" method="post">
            <div class="form-group">
              <label for="senha1"><?php echo $lang['msgsenhaatual']; ?></label>
              <input type="password" class="form-control" required="required" id="senha1" name="senha1" placeholder="<?php echo $lang['msgsenhaatual']; ?>">
            </div>
            <div class="form-group">
              <label for="senha2"><?php echo $lang['msgnovasenha1']; ?></label>
              <input type="password" class="form-control" required="required" id="senha2" name="senha2" placeholder="<?php echo $lang['msgnovasenha1']; ?>">
            </div>
            <div class="form-group">
              <label for="senha3"><?php echo $lang['msgnovasenha2']; ?></label>
              <input type="password" class="form-control" required="required" id="senha3" name="senha3" placeholder="<?php echo $lang['msgnovasenha2']; ?>">
            </div>
            <button type="submit" class="btn btn-dark btn-sm"><?php echo $lang['bt_validar']; ?></button>
          </form>
        </div>
        <!-- ---------------------------------------------

             JANELA DE COMPROVANTES  // PAYMENT VOUCHER WINDOW PLAYER

          ------------------------------------------------>
        <div class="tab-pane fade" id="v-pills-payment" role="tabpanel" aria-labelledby="v-pills-profile-tab">
          <blockquote class="blockquote  mt-3">
            <strong><?php echo $lang['payvoucherinfo']; ?></strong>
          </blockquote>
          <form action="/payment_voucher" method="post" enctype="multipart/form-data">
            <div class="form-group">
              <input type="text" class="form-control" id="loginbuy" required="required" name="loginbuy" placeholder="<?php echo $lang['loginbuy']; ?>">
            </div>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
              </div>
              <div class="custom-file">
                <input type="file" name="arquivo" required="required" class="custom-file-input" id="inputGroupFile01" aria-describedby="inputGroupFileAddon01">
                <label class="custom-file-label" for="inputGroupFile01"><?php echo $lang['msgvoucherfile']; ?></label>
              </div>
            </div>
            <div class="form-group">
              <input type="number" class="form-control" required="required" id="amountbuy" name="amountbuy" placeholder="<?php echo $lang['amountbuy']; ?>">
            </div>
            <button type="submit" class="btn btn-dark btn-sm"><?php echo $lang['bt_validar']; ?></button>
          </form>
        </div>


        <?php if ($acesso_g == 2) { ?>
          <div class="tab-pane fade show active" id="v-pills-admin" role="tabpanel" aria-labelledby="v-pills-messages-tab">
            <div class="row mt-2">

              <div class="col-lg-12">
                <ul class="list-group">
                  <li class="list-group-item text-white bg-dark"><strong><i class="fas fa-store"></i> <?php echo $lang['admin']; ?></strong></li>

                  <li class="list-group-item">
                    <button type="button" class="btn btn-dark btn-block" width="100%" data-toggle="modal" data-target="#addcash">
                      <i class="far fa-gem"> </i> <?php echo $lang['admcash']; ?>
                    </button>
                  </li>

                  <li class="list-group-item">
                    <button type="button" class="btn btn-success btn-block" data-toggle="modal" data-target="#payvoucher">
                      <?php
                      $pay_s  = mysqli_query($con, "SELECT * FROM payment_voucher WHERE reader = '0'");
                      $c_pay  = mysqli_num_rows($pay_s);
                      ?>
                      <i class="fas fa-file-invoice"></i> <?php echo $lang['payvoucher']; ?> <span class="badge badge-pill badge-light"><?php echo $c_pay; ?></span>
                    </button>
                  </li>

                  <li class="list-group-item">
                    <a href="/managershop">
                      <button type="button" class="btn btn-secondary btn-block">
                        <i class="fas fa-store"></i> <?php echo $lang['managershop']; ?></span>
                      </button>
                    </a>
                  </li>

                  <li class="list-group-item">
                    <a href="/managernews">
                      <button type="button" class="btn btn-info btn-block">
                        <i class="fas fa-newspaper"></i> <?php echo $lang['admnews']; ?>
                      </button>
                    </a>
                  </li>

                  <li class="list-group-item">
                    <a href="/manageraccounts">
                      <button type="button" class="btn btn-warning btn-block" width="100%" data-toggle="modal" data-target="#addcash">
                        <i class="fas fa-users-cog"></i> <?php echo $lang['admaccounts']; ?>
                      </button>
                    </a>
                  </li>

                  <li class="list-group-item">
                    <a href="/configs">
                      <button type="button" class="btn btn-danger btn-block" width="100%">
                        <i class="fas fa-cogs"></i> <?php echo $lang['admconfig']; ?>
                      </button>
                    </a>
                  </li>

                </ul>
              </div>
            </div>
          </div>

          <!-- ---------------------------------------------

                    JANELA ADD DIAMANTES // ADD CASH WINDOW

              ------------------------------------------------>
          <div class="modal fade" id="addcash" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel"><?php echo $lang['admcash']; ?></h5>
                  <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
                </div>
                <div class="modal-body">


                  <strong><?php echo $lang['titleaddcash']; ?></strong>
                  <form action="/v" method="post" class="form-inline">

                    <div class="form-group mx-sm-2 mb-2">
                      <label for="inputLogin" class="sr-only"><?php echo $lang['login']; ?></label>
                      <input type="text" name="login" class="form-control" id="inputLogin" required="required" placeholder="<?php echo $lang['login']; ?>">
                    </div>
                    <div class="form-group mx-sm-2 mb-2">
                      <label for="inputCash" class="sr-only"><?php echo $lang['login']; ?></label>
                      <input type="number" name="amount" class="form-control" id="inputCash" required="required" placeholder="<?php echo $lang['msgamount']; ?>">
                    </div>
                    <button type="submit" name="addcash" class="btn btn-success mb-1"><?php echo $lang['bt_validar']; ?></button>
                  </form>


                  <strong><?php echo $lang['titletakeoutcash']; ?></strong>
                  <form action="/v" method="post" class="form-inline">

                    <div class="form-group mx-sm-2 mb-2">
                      <label for="inputLogin" class="sr-only"><?php echo $lang['login']; ?></label>
                      <input type="text" name="login" class="form-control" id="inputLogin" required="required" placeholder="<?php echo $lang['login']; ?>">
                    </div>
                    <div class="form-group mx-sm-2 mb-2">
                      <label for="inputCash" class="sr-only"><?php echo $lang['login']; ?></label>
                      <input type="number" name="amount" class="form-control" id="inputCash" required="required" placeholder="<?php echo $lang['msgamount']; ?>">
                    </div>
                    <button type="submit" name="takeoutcash" class="btn btn-danger mb-2"><?php echo $lang['bt_validar']; ?></button>
                  </form>
                </div>
                <div class="modal-footer">
                  <button type="button" class="btn btn-secondary" data-dismiss="modal"><?php echo $lang['bt_close']; ?></button>
                </div>
              </div>
            </div>
          </div>

          <!-- ----------------------------------------------------------

                JANELA COMPROVANTE DE PAGAMENTOS // PAYMENTS VOUCHER WINDOW

              --------------------------------------------------------------->
          <div class="modal fade " id="payvoucher" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
              <div class="modal-content">
                <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel"><?php echo $lang['payvoucher']; ?></h5>
                  <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
                </div>
                <div class="modal-body">
                  <small>
                    <table class="table">
                      <thead>
                        <tr>
                          <th scope="col">ID</th>
                          <th scope="col"><?php echo $lang['login']; ?></th>
                          <th scope="col"><?php echo $lang['amount']; ?></th>
                          <th scope="col"><?php echo $lang['image']; ?></th>
                          <th scope="col">#</th>
                        </tr>
                      </thead>
                      <tbody>
                        <?php

                        $pay_s2  = mysqli_query($con, "SELECT * FROM payment_voucher ORDER BY id DESC LIMIT 0,50");

                        while ($row_pay = mysqli_fetch_object($pay_s2)) { ?>
                          <form action="/v" method="post">
                            <tr>
                              <td>
                                <div class="form-group input-group-sm">
                                  <input type="text" class="form-control" id="idbuy" name="idbuy" readonly="readonly" value="<?php echo $row_pay->id; ?>">
                                </div>
                              </td>
                              <td>
                                <div class="form-group input-group-sm">
                                  <input type="text" class="form-control" id="loginbuy" name="loginbuy" readonly="readonly" value="<?php echo $row_pay->account_id; ?>">
                                </div>
                              </td>
                              <td>
                                <div class="form-group input-group-sm">
                                  <input type="text" class="form-control" id="amountbuy" name="amountbuy" readonly="readonly" value="<?php echo $row_pay->amount; ?>">
                                </div>
                              </td>
                              <td>
                                <a href="imgs/payments_voucher/<?php echo $row_pay->img; ?>" data-toggle="lightbox" data-title="<?php echo $row_pay->account_id; ?>" data-footer="<?php echo $row_pay->amount . $cash_name; ?>">
                                  [<?php echo $lang['msgviewimg']; ?>]
                                </a>
                              </td>
                              <td>
                                <button type="submit" name="okaypayment" class="btn btn-success btn-sm mb-1" <?php if ($row_pay->okay == 1) {
                                                                                                                echo "disabled";
                                                                                                              } ?>><?php echo $lang['bt_toapprove']; ?></button>
                              </td>
                            </tr>
                          </form>
                        <?php   } ?>
                      </tbody>
                    </table>
                  </small>


                </div>


                <div class="modal-footer">
                  <button type="button" class="btn btn-secondary" data-dismiss="modal"><?php echo $lang['bt_close']; ?></button>
                </div>
              </div>
            </div>
          </div>
        <?php } ?>


        <div class="tab-pane fade" id="v-pills-settings" role="tabpanel" aria-labelledby="v-pills-settings-tab">...</div>

      </div>
    </div>
  </div>
  <script src="js/ekko-lightbox.min.js"></script>


<?php } else { ?>
  <script type="text/javascript">
    window.setTimeout("location.href='/inicio';", 1);
  </script>


<?php } ?>