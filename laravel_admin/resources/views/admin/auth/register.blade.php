@extends('layouts.admin_login')
@section('content')
<style type="text/css">
    .help-block{
        color: #e73d4a;
    }
</style> 
<form class="login-form" method="POST" action="{{ route('admin.register') }}"> 
   {{ csrf_field() }}          
   <h3 class="form-title font-green">Sign Up</h3>                              
   @if ($message = Session::get('error'))
   <div class="alert alert-danger alert-block">
    <button type="button" class="close" data-dismiss="alert">×</button> 
    <strong>{{ $message }}</strong>
</div>
@endif
<div class="form-group">                
    <label class="control-label visible-ie8 visible-ie9">Name</label>
    <input id="name" type="text" class="form-control" name="name" value="{{ old('name') }}" required autofocus type="text" autocomplete="off" placeholder="Your Name">
    @if ($errors->has('name'))
    <span class="help-block">
        <strong>{{ $errors->first('name') }}</strong>
    </span>
    @endif
</div>
<div class="form-group">   
    <label class="control-label visible-ie8 visible-ie9">Email</label>
    <input id="email" type="email" class="form-control" name="email" value="{{ old('email') }}" required autofocus type="text" autocomplete="off" placeholder="Your email">
    @if ($errors->has('email'))
    <span class="help-block">
        <strong>{{ $errors->first('email') }}</strong>
    </span>
    @endif
</div>
<div class="form-group">
    <label class="control-label visible-ie8 visible-ie9">Password</label>                  
    <input id="password" type="password" class="form-control" name="password" required autocomplete="off" placeholder="Password">
    @if ($errors->has('password'))
    <span class="help-block">
        <strong>{{ $errors->first('password') }}</strong>
    </span>
    @endif
</div>
<div class="form-group ">
    <label class="control-label visible-ie8 visible-ie9">{{ __('Confirm Password') }}</label>                  
    <input id="password-confirm" type="password" class="form-control" name="password_confirmation" required>
    @if ($errors->has('password_confirmation'))
    <span class="help-block">
        <strong>{{ $errors->first('password_confirmation') }}</strong>
    </span>
    @endif
</div>

<div class="form-actions" style="text-align: center;">
    <button type="submit" class="btn green uppercase">Register</button>
</div>              
</form>     
@endsection