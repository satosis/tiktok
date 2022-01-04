<!DOCTYPE html>
<html lang="en">
<head>
	<title>Webadmin </title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<!-- Stylesheets -->

	<link rel="stylesheet" href="{{ asset('css/bootstrap.min.css') }}"/>
	<link rel="stylesheet" href="{{ asset('css/font-awesome.min.css') }}"/>
	<link rel="stylesheet" href="{{ asset('css/style.css') }}"/>
	
	<link href="https://fonts.googleapis.com/css2?family=Fjalla+One&display=swap" rel="stylesheet">
<style>
    body{
        background-color: #095cac;
    }
    .login_logo{
        /* background-color: #095cac; */
        padding-top:15px;
        text-align:center
    }
    .login_div{
        position: absolute;
    right: 0;
    left: 0;
    margin: auto;
    top:8rem;
    
    }
</style>

</head>
<body >
	<section class="no-pad"> 
		<div class="main">	
				
		<!-- left menu -->	
		<div class="container-fluid">	
		<div class="row">
           	
		<!-- left menu -->		
		<!-- rightside-main -->
		<div class="col-lg-12 no-pad">
             @yield('content')
        </div>
		<!-- rightside-main -->			
				</div>
				</div>	
			</div>	
			</div>	
	</section>
		
	<!-- <script src="js/bootstrap.min.js"></script> -->
    <script src="{{ asset('js/bootstrap.min.js') }}"></script>

	

</body>
</html>
