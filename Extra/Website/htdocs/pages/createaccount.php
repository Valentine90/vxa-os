  <div class="row">
    <div class="col-md-12 my-4">
      <div class="card card-signup z-depth-0">
        <div class="card-body">
          <h3 class="card-title"><?php echo $lang['createaccount'] ?></h3>
          <p class="slogan"><?php echo $lang['msgaccount'] ?></p>
          <form action="/validaccount" method="post">
            <div class="md-form mat-4">
              <input type="text" id="username" minlength="3" maxlength="13" required="required" name="login" placeholder="<?php echo $lang['user'] ?>" class="form-control">
              <hr>
            </div>

            <div class="md-form mat-2">
              <input type="email" id="email" maxlength="40" required="required" name="email" placeholder="<?php echo $lang['email'] ?>" class="form-control">
              <hr>
            </div>

            <div class="md-form mat-2">
              <input type="password" id="password" minlength="3" required="required" name="pass" placeholder="<?php echo $lang['senha'] ?>" class="form-control">
              <hr>
            </div>

            <div class="md-form mat-2">
              <input type="password" id="password2" minlength="3" required="required" name="pass2" placeholder="<?php echo $lang['repeatpass'] ?>" class="form-control">
              <hr>
            </div>

            <div class="card-foter text-right">
              <button type="submit" name="cad" class="btn btn-primary" style="width: 140px;"><?php echo $lang['bt_validar'] ?></button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>