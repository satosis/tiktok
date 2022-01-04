@extends('layouts.admin')
@section('content')
<?php
$title = 'Change Password';

$currentPath = url(config('app.admin_url')).'/candidates/';
?>
<div class="page-header">
    <div class="page-block">
        <div class="row align-items-center">
            <div class="col-md-8">
                <div class="page-header-title">
                    <h4 class="m-b-10"><?php echo $title;?></h4>
                </div>
                <ul class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.dashboard')}}">
                            <i class="feather icon-home"></i>
                        </a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.dashboard')}}">Dashboard</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.candidates.index')}}">User Management</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.candidates.index')}}">Manage Users</a>
                    </li>                    
                    <li class="breadcrumb-item">
                        <a href="#"><?php echo $title;?></a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</div>
<div class="pcoded-inner-content">
    <div class="main-body">
        <div class="page-wrapper">
            <div class="page-body">                
                <div class="row">                     
                    <div class="col-lg-12 col-md-12">
                        <div class="card">                           
                            <div class="card-header">
                                <h3><?php echo $title;?></h3> 
                            </div>
                            <div class="card-block general">                              
                                <div class="row margin-tp-bt-10">
                                    <div class="col-lg-12 col-md-12">
                                        @if (count($errors) > 0)
                                        <div class="alert alert-danger">
                                            <ul>
                                            @foreach ($errors->all() as $error)
                                                <li>{{ $error }}</li>
                                            @endforeach
                                            </ul>
                                        </div>
                                        @endif
                                    </div>
                                </div>
                               
                                   <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/candidates/updatePassword/'.$id)}}" method="post">
                                
                                    {{ csrf_field() }}
                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                            <div id='us_div' >
                                                <div class="form-group row">
                                                    <label class="col-sm-2 col-form-label">Password <span class="requried">*</span></label>
                                                    <div class="col-sm-10">
                                                        <?php
                                                        if( old('password')!='' ){
                                                            $password = old('password');
                                                        }else{
                                                            $password = '';
                                                        }
                                                        ?>
                                                        <input type="text" class="form-control" name="password" value="<?php echo $password;?>" >
                                                    </div>
                                                </div> 
                                                <div class="form-group row">
                                                    <label class="col-sm-2 col-form-label">Confirm Password <span class="requried">*</span></label>
                                                    <div class="col-sm-10">
                                                        <?php
                                                        if( old('confirm_password')!='' ){
                                                            $confirm_password = old('confirm_password');
                                                        }else{
                                                            $confirm_password = '';
                                                        }
                                                        ?>
                                                        <input type="text" class="form-control" name="confirm_password" value="<?php echo $confirm_password;?>" >
                                                    </div>
                                                </div> 
                                            </div> 
                                         </div>
                                    <div class="row margin-tp-bt-10">
                                        <div class="col-lg-12 col-md-12" >                                        
                                           <button type="submit" class="btn btn-primary">Submit</button>
                                        </div>    
                                    </div> 
                                </form>                                           
                            </div>
                        </div>
                    </div>                    
                </div>
            </div>
        </div>
    </div>
</div>
@endsection