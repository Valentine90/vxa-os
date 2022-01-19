<?php if ($conectado == 1 and $acesso_g >= 2) { ?>

	<section class="py-3 header">
		<div class="row">
			<form action="/validconfigs" method="post">
				<div class="col-md-12">
					<blockquote>
						<h3><?php echo $lang['configs']; ?></h3>
					</blockquote>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['ipserver'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['ipserver'][1]; ?>"><?php echo $lang['ipserver'][1]; ?></span>
						<input type="text" name="ipserver" value="<?php echo $config->ipserver; ?>" class="form-control" placeholder="<?php echo $lang['ipserver'][1]; ?>" aria-describedby="<?php echo $lang['ipserver'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['portserver'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['portserver'][1]; ?>"><?php echo $lang['portserver'][1]; ?></span>
						<input type="text" name="portserver" value="<?php echo $config->portserver; ?>" class="form-control" placeholder="<?php echo $lang['portserver'][1]; ?>" aria-describedby="<?php echo $lang['portserver'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['titlesite'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['titlesite'][1]; ?>"><?php echo $lang['titlesite'][1]; ?></span>
						<input type="text" name="titlesite" value="<?php echo $config->titlesite; ?>" class="form-control" placeholder="<?php echo $lang['titlesite'][1]; ?>" aria-describedby="<?php echo $lang['titlesite'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['maxnews'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['maxnews'][1]; ?>"><?php echo $lang['maxnews'][1]; ?></span>
						<input type="text" name="maxnews" value="<?php echo $config->maxnews; ?>" class="form-control" placeholder="<?php echo $lang['maxnews'][1]; ?>" aria-describedby="<?php echo $lang['maxnews'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['cashname'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['cashname'][1]; ?>"><?php echo $lang['cashname'][1]; ?></span>
						<input type="text" name="cashname" value="<?php echo $config->cashname; ?>" class="form-control" placeholder="<?php echo $lang['cashname'][1]; ?>" aria-describedby="<?php echo $lang['cashname'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['maxrank'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['maxrank'][1]; ?>"><?php echo $lang['maxrank'][1]; ?></span>
						<input type="text" name="maxrank" value="<?php echo $config->maxrank; ?>" class="form-control" placeholder="<?php echo $lang['maxrank'][1]; ?>" aria-describedby="<?php echo $lang['maxrank'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['maxrankguild'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['maxrankguild'][1]; ?>"><?php echo $lang['maxrankguild'][1]; ?></span>
						<input type="text" name="maxrankguild" value="<?php echo $config->maxrankguild; ?>" class="form-control" placeholder="<?php echo $lang['maxrankguild'][1]; ?>" aria-describedby="<?php echo $lang['maxrankguild'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['maxitemstore'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['maxitemstore'][1]; ?>"><?php echo $lang['maxitemstore'][1]; ?></span>
						<input type="text" name="maxitemstore" value="<?php echo $config->maxitemstore; ?>" class="form-control" placeholder="<?php echo $lang['maxitemstore'][1]; ?>" aria-describedby="<?php echo $lang['maxitemstore'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['downloadlink'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['downloadlink'][1]; ?>"><?php echo $lang['downloadlink'][1]; ?></span>
						<input type="text" name="downloadlink" value="<?php echo $config->downloadlink; ?>" class="form-control" placeholder="<?php echo $lang['downloadlink'][1]; ?>" aria-describedby="<?php echo $lang['downloadlink'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['discount'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['discount'][1]; ?>"><?php echo $lang['discount'][1]; ?></span>
						<input type="text" name="discount" value="<?php echo $config->discount; ?>" class="form-control" placeholder="<?php echo $lang['discount'][1]; ?>" aria-describedby="<?php echo $lang['discount'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['languages'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['languages'][1]; ?>"><?php echo $lang['languages'][1]; ?></span>
						<input type="text" name="languages" value="<?php echo $config->languages; ?>" class="form-control" placeholder="<?php echo $lang['languages'][1]; ?>" aria-describedby="<?php echo $lang['languages'][1]; ?>">
					</div>
				</div>
				<div class="col-md-12">
					<small><?php echo $lang['langdefault'][2]; ?></small>
					<div class="input-group mb-3">
						<span class="input-group-text" id="<?php echo $lang['langdefault'][1]; ?>"><?php echo $lang['langdefault'][1]; ?></span>
						<input type="text" name="langdefault" value="<?php echo $config->langdefault; ?>" class="form-control" placeholder="<?php echo $lang['langdefault'][1]; ?>" aria-describedby="<?php echo $lang['langdefault'][1]; ?>">
					</div>
				</div>
				<button type="submit" class="btn btn-primary btn-block">Salvar</button>
			</form>
		</div>
	</section>

<?php } ?>