@extends('layouts.admin')
@section('content')
<?php
   if($action == 'edit'){
    $title = 'Edit User';
    $readonly="";
}else if($action == 'add') {
    $title = 'Add User';
    $readonly="";
}else if($action == 'view') {
    $title = 'View User';
    $readonly='readonly';
}else{
    $title = 'Copy User';
    $readonly="";
}

$currentPath = url(config('app.admin_url')).'/candidates/';
//$imageUpload=env('AWS_URL')."profile_pic/";
?>
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
                        <a href="{{ route('admin.dashboard')}}">Dashboard</a>
                    </li> -->
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.candidates.index')}}">Users Management</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a class="active" href="#"><?php echo $title;?></a>
                    </li>
                </ul>       
            </div>
        </div>
        <div class="card table-card ">
            <div class="row card-header borderless ">
                    <div class="col-md-12 col-lg-12">
                        <h3><?php echo $title;?></h3>
                    </div>
                    
                </div>
           
                    <div class="card-body">
                        <div class="row">
                        <div class="col-md-12 col-lg-12">
                            <ul class="row nav nav-tabs md-tabs" role="tablist">
                                <li class="col-md-6 nav-item">
                                    <a class="nav-link active" href="<?php echo $currentPath.$action.'/'.$id ?>" ><i class="fa fa-home" aria-hidden="true"></i> &nbsp;General</a>
                                    <div class="slide"></div>
                                </li>
                                <!-- <li class="nav-item">
                                    <a class="nav-link " href="<?php //echo $currentPath.$action.'/photos/'.$id ?>" ><i class="fa fa-camera" aria-hidden="true"></i> &nbsp;Photos</a>
                                    <div class="slide"></div>
                                </li> -->
                                <li class="nav-item col-md-6">
                                    <a class="nav-link" href="<?php echo $currentPath.$action.'/videos/'.$id ?>" ><i class="fa fa-caret-square-o-right" aria-hidden="true"></i> &nbsp;Videos</a>
                                    <div class="slide"></div>
                                </li>
                                <!--<li class="nav-item">
                                    <a class="nav-link" href="<?php //echo $currentPath.$action.'/audios/'.$id ?>" ><i class="fa fa-caret-right" aria-hidden="true"></i> &nbsp;Audios</a>
                                    <div class="slide"></div>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="<?php //echo $currentPath.$action.'/documents/'.$id ?>" ><i class="fa fa-file-image-o" aria-hidden="true"></i> &nbsp;Documents</a>
                                    <div class="slide"></div>
                                </li>-->
                            </ul>
                        </div>
                        </div>
                        <div class="row">
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
                        <!-- <div class="row"> -->
                        <?php
                                if($action == 'edit'){?>
                                   <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/candidates/'.$id)}}" method="post">
                                    {{ method_field('PUT') }}
                                <?php }else {?>
                                    <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/candidates')}}" method="post">
                                <?php }?>
                                    {{ csrf_field() }}
                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                        <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Username <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('username')!='' ){
                                                        $username = old('username');
                                                    }
                                                    else if( isset($candidate->username) && $candidate->username != ''){
                                                        $username = $candidate->username;
                                                    }else{
                                                        $username = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="username" value="<?php echo $username;?>" {{$readonly}}>
                                                </div>
                                            </div> 
                                            <div id='us_div' >
                                                <div class="form-group row">
                                                    <label class="col-sm-2 col-form-label">First Name <span class="requried">*</span></label>
                                                    <div class="col-sm-10">
                                                        <?php
                                                        if( old('fname')!='' ){
                                                            $fname = old('fname');
                                                        }
                                                        else if( isset($candidate->fname) && $candidate->fname != ''){
                                                            $fname = $candidate->fname;
                                                        }else{
                                                            $fname = '';
                                                        }
                                                        ?>
                                                        <input type="text" class="form-control" name="fname" value="<?php echo $fname;?>" {{$readonly}}>
                                                    </div>
                                                </div> 
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Last Name <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('lname')!='' ){
                                                        $lname = old('lname');
                                                    }
                                                    else if( isset($candidate->lname) && $candidate->lname != ''){
                                                        $lname = $candidate->lname;
                                                    }else{
                                                        $lname = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="lname" value="<?php echo $lname;?>" {{$readonly}}>
                                                </div>
                                            </div> 
                                             
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Email <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('email')!='' ){
                                                        $email = old('email');
                                                    }
                                                    else if( isset($candidate->email) && $candidate->email != ''){
                                                        $email = $candidate->email;
                                                    }else{
                                                        $email = '';
                                                    }
                                                    ?>
                                                    <input type="email" class="form-control" name="email" value="<?php echo $email;?>" {{$readonly}}>
                                                </div>
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Gender <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('gender')!='' ){
                                                        $gender = old('gender');
                                                    }
                                                    else if( isset($candidate->gender) && $candidate->gender != ''){
                                                        $gender = $candidate->gender;
                                                    }else{
                                                        $gender = '';
                                                    }
                                                    if($gender=='f'){
                                                        $gender='Female';
                                                    }elseif($gender=='m'){
                                                        $gender='Male';
                                                    }else{
                                                        $gender='Other';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="gender" value="<?php echo $gender;?>" {{$readonly}}>
                                                </div>
                                            </div>
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">DOB <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('dob')!='' ){
                                                        $dob = old('dob');
                                                    }
                                                    else if( isset($candidate->dob) && $candidate->dob != ''){
                                                        $dob = $candidate->dob;
                                                    }else{
                                                        $dob = '';
                                                    }
                                                   
                                                    ?>
                                                    <input type="text" class="form-control" name="dob" value="<?php echo date('d F,Y', strtotime($dob));?>" {{$readonly}}>
                                                </div>
                                            </div>
                                           
                                          <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Profile Pic <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                <?php if($candidate->user_dp ==""){ ?>
                                                        <img src="{{ asset('assets/images/profile.png') }}" alt="user image" width="100px">
                                                    <?php }elseif(stripos($candidate->user_dp,'https://')!==false){ ?>
                                                        <img src="<?php echo $candidate->user_dp; ?>" alt="user image" width="100px">
                                                    <?php }else{ ?>
                                                        <img src="<?php echo url(config('app.profile_path')).'/'.$candidate->user_id.'/'.$candidate->user_dp; ?>" alt="user image" width="100px">
                                                    <?php } ?> 
                                                </div>
                                            </div>
                                    </div>
                                    <div class="row margin-tp-bt-10">
                                        <div class="col-lg-12 col-md-12" <?php if($action == 'view'){ echo "style='display:none'"; }?>>                                        
                                           <button type="submit" class="btn btn-primary">Submit</button>
                                        </div>    
                                    </div> 
                                </form>  
                        
                        
                        <!-- </div> -->
                      </div>
                </div>
            </div>
        </div>
</section>
<script>
$(document).ready(function() {
    $('.js-example-basic-multiple').select2();
});
</script>
@endsection