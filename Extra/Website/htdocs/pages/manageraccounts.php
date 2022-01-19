<?php if ($conectado == 1 and $acesso_g >= 2) { ?>

  <?php
  $accounts     = mysqli_query($con, "SELECT * FROM accounts");
  $count_acc     = mysqli_num_rows($accounts);
  $characters   = mysqli_query($con, "SELECT * FROM actors");
  $count_char    = mysqli_num_rows($characters);
  ?>

  <div class="row">

    <div class="col-md-12">

      <div class="panel panel-default panel-table">
        <div class="panel-heading">
          <div class="row">
            <div class="col-lg-12">
              <h5 class="panel-title"><?php echo $lang['admaccounts']; ?></h5>
            </div>
            <div class="col-md-6">
              <div class="panel">
                <div class="panel-body">
                  <canvas id="myChart" width="400" height="300"></canvas>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <div class="panel">
                <div class="panel-body">
                  <canvas id="myChart2" width="400" height="300"></canvas>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="panel-body">

          <div class="card border-secondary">
            <div class="card-header">
              <?php echo $lang['characters']; ?>
            </div>
            <div class="card-body">
              <table id="example" style="width:100%" class="display">
                <thead>
                  <tr>
                    <th><em class="fa fa-cog"></em></th>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Account ID</th>
                    <th>Level</th>
                    <th>Gold</th>
                  </tr>
                </thead>
                <tbody>
                  <?php
                  $search   = mysqli_query($con, "SELECT * FROM actors");
                  $count    = mysqli_num_rows($search);
                  while ($row_search = mysqli_fetch_object($search)) { ?>
                    <tr>
                      <td align="center">
                        <button type="submit" name="okaypayment" data-toggle="modal" data-target="#editItem<?php echo $row_search->id; ?>" class="btn btn-info mb-1">
                          <em class="fas fa-edit"></em>
                        </button>
                      </td>
                      <td><?php echo $row_search->id ?></td>
                      <td><?php echo $row_search->name ?></td>
                      <td><?php echo $row_search->account_id ?></td>
                      <td><?php echo $row_search->level ?></td>
                      <td><?php echo $row_search->gold ?></td>
                    </tr>
                  <?php } ?>
                </tbody>
              </table>
            </div>
          </div>
          <?php $search2   = mysqli_query($con, "SELECT * FROM actors");
          while ($row_search2 = mysqli_fetch_object($search2)) { ?>
            <div class="modal fade" id="editItem<?php echo $row_search2->id; ?>" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog  modal-lg">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
                  </div>
                  <div class="modal-body">
                    <form action="/editplayer" method="post">
                      <div class="input-group mb-3">
                        <span class="input-group-text" id="id">id</span>
                        <input type="text" name="id" readonly="readonly" value="<?php echo $row_search2->id; ?>" class="form-control" placeholder="id" aria-describedby="id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="account_id">account_id</span>
                        <input type="text" name="account_id" value="<?php echo $row_search2->account_id; ?>" class="form-control" placeholder="account_id" aria-describedby="account_id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="slot_id">slot_id</span>
                        <input type="text" name="slot_id" value="<?php echo $row_search2->slot_id; ?>" class="form-control" placeholder="slot_id" aria-describedby="slot_id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="name">name</span>
                        <input type="text" name="name" value="<?php echo $row_search2->name; ?>" class="form-control" placeholder="name" aria-describedby="name">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="character_name">character_name</span>
                        <input type="text" name="character_name" value="<?php echo $row_search2->character_name; ?>" class="form-control" placeholder="character_name" aria-describedby="character_name">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="character_index">character_index</span>
                        <input type="text" name="character_index" value="<?php echo $row_search2->character_index; ?>" class="form-control" placeholder="character_index" aria-describedby="character_index">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="face_name">face_name</span>
                        <input type="text" name="face_name" value="<?php echo $row_search2->face_name; ?>" class="form-control" placeholder="face_name" aria-describedby="face_name">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="face_index">face_index</span>
                        <input type="text" name="face_index" value="<?php echo $row_search2->face_index; ?>" class="form-control" placeholder="face_index" aria-describedby="face_index">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="class_id">class_id</span>
                        <input type="text" name="class_id" value="<?php echo $row_search2->class_id; ?>" class="form-control" placeholder="class_id" aria-describedby="class_id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="sex">sex</span>
                        <input type="text" name="sex" value="<?php echo $row_search2->sex; ?>" class="form-control" placeholder="sex" aria-describedby="sex">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="level">level</span>
                        <input type="text" name="level" value="<?php echo $row_search2->level; ?>" class="form-control" placeholder="level" aria-describedby="level">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="exp">exp</span>
                        <input type="text" name="exp" value="<?php echo $row_search2->exp; ?>" class="form-control" placeholder="exp" aria-describedby="exp">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="hp">hp</span>
                        <input type="text" name="hp" value="<?php echo $row_search2->hp; ?>" class="form-control" placeholder="hp" aria-describedby="hp">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="mp">mp</span>
                        <input type="text" name="mp" value="<?php echo $row_search2->mp; ?>" class="form-control" placeholder="mp" aria-describedby="mp">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="mhp">mhp</span>
                        <input type="text" name="mhp" value="<?php echo $row_search2->mhp; ?>" class="form-control" placeholder="mhp" aria-describedby="mhp">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="mmp">mmp</span>
                        <input type="text" name="mmp" value="<?php echo $row_search2->mmp; ?>" class="form-control" placeholder="mmp" aria-describedby="mmp">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="atk">atk</span>
                        <input type="text" name="atk" value="<?php echo $row_search2->atk; ?>" class="form-control" placeholder="atk" aria-describedby="atk">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="def">def</span>
                        <input type="text" name="def" value="<?php echo $row_search2->def; ?>" class="form-control" placeholder="def" aria-describedby="def">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="int">int</span>
                        <input type="text" name="int" value="<?php echo $row_search2->int; ?>" class="form-control" placeholder="int" aria-describedby="int">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="res">res</span>
                        <input type="text" name="res" value="<?php echo $row_search2->res; ?>" class="form-control" placeholder="res" aria-describedby="res">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="agi">agi</span>
                        <input type="text" name="agi" value="<?php echo $row_search2->agi; ?>" class="form-control" placeholder="agi" aria-describedby="agi">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="luk">luk</span>
                        <input type="text" name="luk" value="<?php echo $row_search2->luk; ?>" class="form-control" placeholder="luk" aria-describedby="luk">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="points">points</span>
                        <input type="text" name="points" value="<?php echo $row_search2->points; ?>" class="form-control" placeholder="points" aria-describedby="points">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="guild_id">guild_id</span>
                        <input type="text" name="guild_id" value="<?php echo $row_search2->guild_id; ?>" class="form-control" placeholder="guild_id" aria-describedby="guild_id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="revive_map_id">revive_map_id</span>
                        <input type="text" name="revive_map_id" value="<?php echo $row_search2->revive_map_id; ?>" class="form-control" placeholder="revive_map_id" aria-describedby="revive_map_id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="revive_x">revive_x</span>
                        <input type="text" name="revive_x" value="<?php echo $row_search2->revive_x; ?>" class="form-control" placeholder="revive_x" aria-describedby="revive_x">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="revive_y">revive_y</span>
                        <input type="text" name="revive_y" value="<?php echo $row_search2->revive_y; ?>" class="form-control" placeholder="revive_y" aria-describedby="revive_y">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="map_id">map_id</span>
                        <input type="text" name="map_id" value="<?php echo $row_search2->map_id; ?>" class="form-control" placeholder="map_id" aria-describedby="map_id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="x">x</span>
                        <input type="text" name="x" value="<?php echo $row_search2->x; ?>" class="form-control" placeholder="x" aria-describedby="x">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="y">y</span>
                        <input type="text" name="y" value="<?php echo $row_search2->y; ?>" class="form-control" placeholder="y" aria-describedby="y">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="direction">direction</span>
                        <input type="text" name="direction" value="<?php echo $row_search2->direction; ?>" class="form-control" placeholder="direction" aria-describedby="direction">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="gold">gold</span>
                        <input type="text" name="gold" value="<?php echo $row_search2->gold; ?>" class="form-control" placeholder="gold" aria-describedby="gold">
                      </div>

                      <div class="input-group mb-3">
                        <input type="submit" class="btn btn-block btn-primary" value="Validar">
                      </div>
                    </form>
                  </div>
                </div>
              </div>
            </div>
          <?php } ?>
          <div class="card border-danger mt-4">
            <div class="card-header">
              <?php echo $lang['accounts']; ?>
            </div>
            <div class="card-body">
              <table id="example2" style="width:100%" class="display">
                <thead>
                  <tr>
                    <th><em class="fa fa-cog"></em></th>
                    <th class="hidden-xs">ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Cash</th>
                    <th>Group</th>
                  </tr>
                </thead>
                <tbody>
                  <?php
                  $searchacc   = mysqli_query($con, "SELECT * FROM accounts");
                  $count    = mysqli_num_rows($searchacc);
                  while ($row_searchacc = mysqli_fetch_object($searchacc)) { ?>
                    <tr>
                      <td align="center">
                        <button type="submit" name="okaypayment" data-toggle="modal" data-target="#editAcc<?php echo $row_searchacc->id; ?>" class="btn btn-info mb-1">
                          <em class="fas fa-edit"></em>
                        </button>
                      </td>
                      <td><?php echo $row_searchacc->id ?></td>
                      <td><?php echo $row_searchacc->username ?></td>
                      <td><?php echo $row_searchacc->email ?></td>
                      <td><?php echo $row_searchacc->cash ?></td>
                      <td><?php echo $row_searchacc->group ?></td>
                    </tr>
                  <?php } ?>
                </tbody>
              </table>
            </div>
          </div>
          <?php
          $searchacc2   = mysqli_query($con, "SELECT * FROM accounts");

          while ($row_searchacc2 = mysqli_fetch_object($searchacc2)) { ?>
            <div class="modal fade" id="editAcc<?php echo $row_searchacc2->id; ?>" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
              <div class="modal-dialog  modal-lg">
                <div class="modal-content">
                  <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
                  </div>
                  <div class="modal-body">
                    <form action="/editaccounts" method="post">
                      <div class="input-group mb-3">
                        <span class="input-group-text" id="id">id</span>
                        <input type="text" name="id" readonly="readonly" value="<?php echo $row_searchacc2->id; ?>" class="form-control" placeholder="id" aria-describedby="id">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="username">username</span>
                        <input type="text" name="username" value="<?php echo $row_searchacc2->username; ?>" class="form-control" placeholder="username" aria-describedby="username">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="email">email</span>
                        <input type="email" name="email" value="<?php echo $row_searchacc2->email; ?>" class="form-control" placeholder="email" aria-describedby="email">
                      </div>

                      <div class="input-group mb-3">
                        <span class="input-group-text" id="group">group</span>
                        <select name="group" class="form-control" aria-describedby="group">
                          <option <?php if ($row_searchacc2->group == 0) : echo "selected";
                                  endif; ?> value="0">Player</option>
                          <option <?php if ($row_searchacc2->group == 1) : echo "selected";
                                  endif; ?> value="1">Monitor</option>
                          <option <?php if ($row_searchacc2->group == 2) : echo "selected";
                                  endif; ?> value="2">Admin</option>
                        </select>

                        <?php

                        $date           = time();
                        $vip            = $row_searchacc2->vip_time;
                        $date1 = strftime("%Y-%m-%d", time());
                        $date2 = strftime("%Y-%m-%d", $vip);
                        $datetime1 = date_create($date1);
                        $datetime2 = date_create($date2);
                        $interval = date_diff($datetime1, $datetime2);
                        if ($date < $vip) {
                          $status_vip = 1;
                        } else {
                          $status_vip = 0;
                        }
                        ?>
                        <div class="input-group mt-3">
                          <span class="input-group-text" id="email">vip_time in days</span>
                          <input type="number" name="vip_time" value="<?php if ($status_vip == 1) : echo $interval->format('%a');
                                                                      else : echo "0";
                                                                      endif; ?>" class="form-control" placeholder="vip_time" aria-describedby="vip_time">
                        </div>

                        <div class="input-group mt-3">
                          <span class="input-group-text" id="cash">cash</span>
                          <input type="text" name="cash" value="<?php echo $row_searchacc2->cash; ?>" class="form-control" placeholder="cash" aria-describedby="cash">
                        </div>
                        <div class="input-group mt-3">
                          <input type="submit" class="btn btn-block btn-primary" value="Validar">
                        </div>
                      </div>
                    </form>
                    <blockquote class="blockquote"><?php echo $lang['history']; ?></blockquote>
                    <table class="table table-striped">

                      <tbody>
                        <?php $records  = mysqli_query($con, "SELECT * FROM records WHERE account_id = '$row_searchacc2->id' ORDER BY id DESC");
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
                </div>
              </div>
            </div>

          <?php } ?>

        </div>
      </div>

    </div>
  </div>

  <script src="js/chart.min.js"></script>
  <script src="js/jquery.dataTables.min.js"></script>
  <script>
    var ctx = document.getElementById('myChart').getContext('2d');
    var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['<?php echo $lang['characters'] ?>'],
        datasets: [{
          label: 'Estatísticas',
          data: [<?php echo $count_char ?>],
          backgroundColor: [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
          ],
          borderColor: [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: false
          }
        }
      }
    });

    var ctx = document.getElementById('myChart2').getContext('2d');
    var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['<?php echo $lang['accounts'] ?>'],
        datasets: [{
          label: 'Estatísticas',
          data: [<?php echo $count_acc ?>],
          backgroundColor: [
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
          ],
          borderColor: [
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: false
          }
        }
      }
    });

    $(document).ready(function() {
      $('#example').dataTable({
        /*
        "language": {
          "info": "Mostrando página _PAGE_ de _PAGES_",
          "search": "Buscar:",
          "zeroRecords": "Nada encontrado referente a busca",
          "paginate": {
            "first": "Primeiro",
            "next": "Próximo",
            "last": "Utimo",
            "previous": "Anterior"
          }
        } */
      });
      $('#example2').dataTable({
        /*
        "language": {
          "info": "Mostrando página _PAGE_ de _PAGES_",
          "search": "Buscar:"
        } */
      });
    });
  </script>

<?php } ?>