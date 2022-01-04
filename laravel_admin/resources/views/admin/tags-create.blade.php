@extends('layouts.admin')
@section('content')
<?php
   if($action == 'edit'){
    $title = 'Edit Tag';
    $readonly="";
}else if($action == 'add') {
    $title = 'Add Tag';
    $readonly="";
}else if($action == 'view') {
    $title = 'View Tag';
    $readonly='readonly';
}else{
    $title = 'Copy Tag';
    $readonly="";
}
$path = url('').'/'.config('app.admin_url').'/tags';
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
                        <a href="{{ route('admin.tags.index')}}">Tags Management</a>
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
                        <?php
                                if($action == 'edit'){?>
                                   <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/tags/'.$id)}}" method="post" enctype="multipart/form-data">
                                    {{ method_field('PUT') }}
                                <?php }else {?>
                                    <form class="form-horizontal" role="form" action="{{url( config('app.admin_url') .'/tags')}}" method="post" enctype="multipart/form-data">
                                <?php }?>
                                    {{ csrf_field() }}
                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                            
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Tag <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('tag')!='' ){
                                                        $tag_title = old('tag');
                                                    }
                                                    else if( isset($tag->tag) && $tag->tag != ''){
                                                        $tag_title = $tag->tag;
                                                    }else{
                                                        $tag_title = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="tag" value="<?php echo $tag_title;?>" {{$readonly}}>
                                                </div>
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Banner <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('banner')!='' ){
                                                        $banner = old('banner');
                                                    }
                                                    else if( isset($tag->banner) && $tag->banner != ''){
                                                        $banner = $tag->banner;
                                            
                                                    }else{
                                                        $banner = '';
                                                      
                                                    }
                                                   
                                                    ?>
                                                    <input type="file" class="form-control" name="banner" value="<?php echo $banner;?>" {{$readonly}}>
                                                    <input type="hidden" name="old_banner" value="<?php echo $banner; ?>">
                                                   
                                                    <input type="hidden" name="id" value="<?php echo (isset($id)) ? $id : 0; ?>">
                                                </div>
                                                <label class="col-sm-2 col-form-label"></label>
                                                <div class="col-sm-10">
                                                 
                                                    <?php if($banner!=""){ ?>
                                                    <img width="150"src="<?php echo url('storage/banners/'.$banner); ?>" >
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