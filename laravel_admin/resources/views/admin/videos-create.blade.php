@extends('layouts.admin')
@section('content')
<?php
   if($action == 'edit'){
    $title = 'Edit Video';
    $readonly="";
}else if($action == 'add') {
    $title = 'Add Video';
    $readonly="";
}else if($action == 'view') {
    $title = 'View Video';
    $readonly='readonly';
}else{
    $title = 'Copy Video';
    $readonly="";
}
$path = url('').'/'.config('app.admin_url').'/videos';
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
                            <i class="feather icon-home"></i>
                        </a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.dashboard')}}">Dashboard</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.videos.index')}}">Videos Management</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="#"><?php echo $title;?></a>
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
                                   <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/videos/'.$id)}}" method="post" enctype="multipart/form-data">
                                    {{ method_field('PUT') }}
                                <?php }else {?>
                                    <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/videos')}}" method="post" enctype="multipart/form-data">
                                <?php }?>
                                    {{ csrf_field() }}
                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Username <span class="requried">*</span></label>
                                                <div class="col-sm-10 main_cat">
                                                    <?php
                                                      if( isset($video->user_id) && $video->user_id > 0){
                                                        $user_id=$video->user_id;
                                                    }else{
                                                        $user_id = 0;
                                                    } ?>
                                                    <select class="form-control js-example-basic-multiple" name="user_id" {{$readonly}}>
                                                        <option value="0">---Select---</option>
                                                        <?php
                                                        if($user_id>0){
                                                            foreach($users as $u){ ?>
                                                            <option <?php if($user_id==$u->user_id){ echo "selected";}?> value="<?php echo $u->user_id; ?>"><?php echo $u->username; ?></option>
                                                        <?php } 
													}else{
                                                    	foreach($users as $u){ ?>
                                                        <option value="<?php echo $u->user_id; ?>"><?php echo $u->username; ?></option>
                                                    <?php } 
                                                       }
                                                    ?>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Sound <span class="requried">*</span></label>
                                                <div class="col-sm-10 main_cat">
                                                    <?php
                                                      if( isset($video->sound_id) && $video->sound_id > 0){
                                                        $sound_id=$video->sound_id;
                                                    }else{
                                                        $sound_id = 0;
                                                    } ?>
                                                    <select class="form-control js-example-basic-multiple" name="sound_id" {{$readonly}}>
                                                        <option value="0">---Select---</option>
                                                        <?php
                                                        if($sound_id>0){
                                                            foreach($sounds as $sound){ ?>
                                                            <option <?php if($sound_id==$sound->sound_id){ echo "selected";}?> value="<?php echo $sound->sound_id; ?>"><?php echo $sound->title; ?></option>
                                                        <?php } 
													}else{
                                                    	foreach($sounds as $sound){ ?>
                                                        <option value="<?php echo $sound->sound_id; ?>"><?php echo $sound->title; ?></option>
                                                    <?php } 
                                                       }
                                                    ?>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Title </label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('title')!='' ){
                                                        $title = old('title');
                                                    }
                                                    else if( isset($video->title) && $video->title != ''){
                                                        $title = $video->title;
                                                    }else{
                                                        $title = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="title" value="<?php echo $title;?>" {{$readonly}}>
                                                </div>
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Description </label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('description')!='' ){
                                                        $description = old('description');
                                                    }
                                                    else if( isset($video->description) && $video->description != ''){
                                                        $description = $video->description;
                                                    }else{
                                                        $description = '';
                                                    }
                                                    ?>
                                                    <textarea name="description" class="form-control" {{$readonly}}><?php echo $description;?></textarea>
                                                    <!-- <input type="text" class="form-control" name="title" value="<?php //echo $title;?>" {{$readonly}}> -->
                                                </div>
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Video <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('video')!='' ){
                                                        $video1 = old('video');
                                                    }
                                                    else if( isset($video->video) && $video->video != ''){
                                                        $video1 = $video->video;
                                                        $thumb= $video->thumb;
                                                        $gif= $video->gif;
                                                    }else{
                                                        $video1 = '';
                                                        $thumb='';
                                                        $gif='';
                                                    }
                                                    if(isset($video->user_id) && $video->user_id!=''){
                                                        $user_id=$video->user_id;
                                                    }else{
                                                        $user_id=0;
                                                    }
                                                    if(isset($video->duration) && $video->duration!=''){
                                                        $duration=$video->duration;
                                                    }else{
                                                        $duration=0;
                                                    }
                                                    ?>
                                                    <input type="file" class="form-control" name="video" value="<?php echo $video1;?>" {{$readonly}}>
                                                    <input type="hidden" name="old_video" value="<?php echo $video1; ?>">
                                                    <input type="hidden" name="old_thumb" value="<?php echo $thumb; ?>">
                                                    <input type="hidden" name="old_gif" value="<?php echo $gif; ?>">
                                                    <input type="hidden" name="old_duration" value="<?php echo $duration; ?>">
                                                    <input type="hidden" name="id" value="<?php echo (isset($id)) ? $id : 0; ?>">
                                                </div>
                                                <label class="col-sm-2 col-form-label"></label>
                                                <div class="col-sm-10">
                                                    <?php if(isset($video->gif) && $video->gif!=""){
                                                        $gif=$video->gif;
                                                    }else{
                                                        $gif="";
                                                    } ?>
                                                    <?php if($gif!=""){ ?>
                                                    <img width="100" height="150" src="<?php echo url('storage/videos/'.$user_id.'/gif/'.$gif); ?>" >
                                                    <?php } ?>
                                                </div>
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
<script type="text/javascript">
  $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });
    $(document).ready(function() {

        $(document).on("change","#main_cat_id", function() {          
            var main_cat=$(this).val();
            $.post('<?php echo $path;?>/select_cat','main_cat='+main_cat,function(data){
                $('#cat_id').html(data);
                    //window.location = '<?php //echo $path;?>';
                });
        });
        $('#main_cat_id').select2();
        $('#cat_id').select2();
    });
</script>
@endsection