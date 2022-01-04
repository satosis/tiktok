<?php 
$menu_options = request()->route()->getAction();
$MainValues = substr($menu_options['controller'], strrpos($menu_options['controller'], "\\") + 1);
$MainSettings = explode('@', $MainValues);
$controller = $MainSettings[0];
$action = $MainSettings[1];  
?>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Leuke - Adminstrator</title>
	<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="Leuke" />
    <meta name="keywords" content="Leuke, admin Admin">
    <meta name="_token" content="<?php echo e(csrf_token()); ?>" /> 

	<!-- Stylesheets -->

	<link rel="stylesheet" href="<?php echo e(asset('css/bootstrap.min.css')); ?>"/>
	<link rel="stylesheet" href="<?php echo e(asset('css/font-awesome.min.css')); ?>"/>
	<link rel="stylesheet" href="<?php echo e(asset('css/style.css')); ?>"/>
	<link rel="stylesheet" href="<?php echo e(asset('css/style1.css')); ?>"/>
	<!-- Style.css -->
	<link href="https://fonts.googleapis.com/css2?family=Fjalla+One&display=swap" rel="stylesheet">
	<link rel="icon" href="<?php echo e(asset('imgs/favicon.ico')); ?>" type="image/x-icon">
	<script type="text/javascript" src="<?php echo e(asset('files/jquery/js/jquery.min.js')); ?>"></script>
    <script type="text/javascript" src="<?php echo e(asset('files/jquery-ui/js/jquery-ui.min.js')); ?>"></script>
    <script type="text/javascript" src="<?php echo e(asset('files/popper.js/js/popper.min.js')); ?>"></script>
    <script type="text/javascript" src="<?php echo e(asset('files/bootstrap/js/bootstrap.min.js')); ?>"></script>
	<link href="<?php echo e(asset('datatables/datatables.min.css')); ?>" rel="stylesheet" type="text/css" />
<!--     <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css"> -->
    <link href="<?php echo e(asset('datatables/plugins/bootstrap/datatables.bootstrap.css')); ?>" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="<?php echo e(asset('js/jquery.dataTables.js')); ?>"></script>
	
	<script src="<?php echo e(asset('files/amchart/amcharts.js')); ?>"></script>
    <script src="<?php echo e(asset('files/amchart/serial.js')); ?>"></script>
    <script src="<?php echo e(asset('files/amchart/light.js')); ?>"></script>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.7/css/select2.min.css" rel="stylesheet" />
	<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.7/js/select2.min.js"></script>
</head>
<body >
	<section class="no-pad"> 
		<div class="main">	
		<!-- topbar -->	
		<div class="container-fluid">
			<div class="row topbar">
				<div class="col-lg-2">
					<img src="<?php echo e(asset('storage/uploads/logos/'.MyFunctions::getLogo())); ?>" alt=""  class="logo"/>					
				</div>
				<div class="col-lg-10">
					<div class="top-rightside">
					  <ul>
					  	<li class="dropdown">
							<a class="dropdown-toggle"
							data-toggle="dropdown"
							href="#">
								<i class="fa fa-user" aria-hidden="true"></i>
							</a>
							<ul class="dropdown-menu">
								<li> <i class="fa fa-cog" aria-hidden="true"></i> 
									<a href="<?php echo e(url(config('app.admin_url').'/settings')); ?>" class="anchor" style="display: inline !important;background-color: white;" >
                                        Setting
									</a>
								</li>
								<li> <i class="fa fa-sign-out" aria-hidden="true"></i> 
									<a href="<?php echo e(route('admin.logout')); ?>" >
										Logout
									</a>
								</li>
							</ul>
						</li>
					 	 <!-- <li><i class="fa fa-user" aria-hidden="true"></i></li> -->
					  	<li><i class="fa fa-bell" aria-hidden="true"></i></li>					  	
					  </ul>
					<!-- <div class="search-container">
					    <form action="/action_page.php">
					      <input class="top-search" type="text" placeholder="Search.." name="search">
					      <button class="top-search-b" type="submit"><i class="fa fa-search"></i></button>
					    </form>
					  </div>
					  
					
					</div> -->
					
				</div>
				</div>
			</div>
		<!-- topbar -->	
		<div class="row">
			
		<!-- left menu -->	
		<div class="container-fluid">	
		<div class="row">
            <?php echo $__env->make('includes.admin.sidebar', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?>
				
		<!-- left menu -->		
		<!-- rightside-main -->
		<div class="col-lg-10 no-pad right-main">
             <?php echo $__env->yieldContent('content'); ?>
        </div>
		<!-- rightside-main -->			
				</div>
				</div>	
			</div>	
			</div>	
			
			
			
			
		
	</section>
		
	<!-- <script src="js/bootstrap.min.js"></script> -->
    <script src="<?php echo e(asset('js/bootstrap.min.js')); ?>"></script>

	<script>
		$( document ).ready(function() {
		var url = window.location;
			$('ul li a').filter(function() {
				return this.href == url;
			}).addClass('active').closest('.sub-menu').addClass('show').parent().removeClass('collapsed');

		});
</script>

</body>
</html>
<?php /**PATH C:\Users\Hp\Downloads\leuke App Package\laravel_admin\resources\views/layouts/admin.blade.php ENDPATH**/ ?>