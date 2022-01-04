@extends('layouts.admin')
@section('content')
<?php
    $title = "Change Password";
?>
<style>

.main_cat .select2-container--default .select2-selection--single {
    background-color: #fff; 
    border: 0px solid #aaa;
     border-radius: 0px;
     width : 100%;
     padding:5px;
}
.main_cat .select2-container--default .select2-selection--single .select2-selection__rendered {
    background: #fff;
    padding: 5px;
    height: 40px;
    border: 1px solid #ccc;
}
.main_cat .select2-selection__choice,.main_cat .select2-selection__choice__remove{
    color:#fff;
}

</style>
<section class="rightside-main">
    <div class="container-fluid">
        <div class="page-top">
            <div class="page-header borderless ">
                <h4><?php echo $title;?></h4>   
            </div>
            <div class="page-berdcrumb">
                <ul class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.dashboard')}}">
                            <i class="fa fa-home"></i> Dashboard
                        </a>
                    </li>
                    <!-- <li class="breadcrumb-item">
                        <a href="{{ route('admin.sounds.index')}}">Sounds Management</a>
                    </li> -->
                    <li class="breadcrumb-item">
                        <a class="active" href="#"><?php echo $title;?></a>
                    </li>
                </ul>       
            </div>
        </div>
        <div class="card table-card ">
            <div class="row card-header borderless ">
                    <div class="col-md-8 col-lg-8">
                        <h3><?php echo $title;?></h3>
                    </div>
                </div>
           
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-12 col-md-12">
                                 @if ($message = Session::get('success'))
                                       <div class="alert alert-success alert-block">
                                            <button type="button" class="close" data-dismiss="alert">×</button> 
                                            <strong>{{ $message }}</strong>
                                            <?php Session::forget('success');?>
                                        </div>
                                @endif
                                @if ($message = Session::get('error'))
                                    <div class="alert alert-danger alert-block">
                                        <button type="button" class="close" data-dismiss="alert">×</button> 
                                        <strong>{!! $message !!}</strong>
                                        <?php Session::forget('error');?>
                                    </div>
                                    @endif
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
                <form class="form-horizontal" role="form" action="{{route('admin.change_password.update')}}" method="post" id="form_sample_1">
                 {{ csrf_field() }}
                    <div class="form-body">
                        <div class="form-group">
                            <label class="col-md-3 control-label">Old Password <span class="required" aria-required="true"> * </span></label>
                            <div class="col-md-3">
                            <input type="password" name="old_password" id="old_password" class="form-control" placeholder="Old Password" autofocus value="">                         
                            </div>
                        </div>  
                        <div class="form-group">
                            <label class="col-md-3 control-label">New Password <span class="required" aria-required="true"> * </span></label>
                            <div class="col-md-3">
                            <input type="password" name="new_password" id="new_password" class="form-control" placeholder="New Password" autofocus value="">                           
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-md-3 control-label">Confirm Password <span class="required" aria-required="true"> * </span></label>
                            <div class="col-md-3">
                            <input type="password" name="confirm_password" class="form-control" placeholder="Confirm Password" autofocus value="">                                   
                            </div>
                        </div>    
                                                                                     
                    </div>
                     <div class="row margin-tp-bt-10">
                                        <div class="col-lg-12 col-md-12" >                                        
                                           <button type="submit" class="btn btn-primary">Submit</button>
                                           <button type="button" class="btn default" onclick="document.location.href='{{ route('admin.dashboard') }}'">Cancel</button>
                                        </div>    
                                    </div> 
                </form>
            
                        
                        <!-- </div> -->
                      </div>
                </div>
            </div>
        </div>
</section>
@endsection