@extends('layouts.admin_login')
@section('content')
<style>
.login_div h2{
    letter-spacing:0px;
    box-shadow: 0px 0px 8px #ccc;
    padding-bottom:5px;
}
</style>
<section class="no-pad">                   	
                   	<div class="container-fluid">
                   	<div class="row">
                   		<div class="col-lg-4 col-md-4 login_div">
                         
                   			<div class="card">
                               <div class="col-lg-12 login_logo">
                                    <img src="{{ asset('imgs/logo-blue.jpg') }}" alt="" width="40%"/>					
                                </div>
                   				<div class="form-main">
                                   @if ($message = Session::get('error'))
                                        <div class="alert alert-danger background-danger">
                                            <button type="button" class="close" data-dismiss="alert">×</button> 
                                            <strong>{{ $message }}</strong>
                                        </div>
                                    @endif
                                   <h2 class="text-center">Sign In</h2>
                                   <form method="POST" action="{{ route('admin.loginPost') }}"> 
                                    {{ csrf_field() }}
                                        <h4>Enter Your Email</h4>
                                        <input type="text" class="form-control" id="name" name="name" value="{{ old('name') }}" required placeholder="Username">
                                        @if ($errors->has('name'))
                                            <span class="help-block">{{ $errors->first('name') }}</span>
                                        @endif
                                        <h4>Enter Your Password</h4>
                                        <input id="password" type="password" class="form-control" name="password" required placeholder="Password">
                                        @if ($errors->has('password'))
                                            <span class="help-block">{{ $errors->first('password') }}</span>
                                            @endif  
                                        <div class="row">
                                            <button type="submit" class="col-md-12 btn btn-primary">Submit</button>
                                        </div>
                                    </form>
                   					
                   				</div>
                   				
                   			</div>
                   			
                   		</div>
                   		</div>
                           </div>
</section>
@endsection