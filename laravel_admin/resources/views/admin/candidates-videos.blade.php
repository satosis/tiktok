@extends('layouts.admin')
@section('content')
<?php
   if($action == 'edit'){
    $title = 'Edit Users';
    $readonly="";
}else if($action == 'add') {
    $title = 'Add Users';
    $readonly="";
}else if($action == 'view') {
    $title = 'View Users';
    $readonly='readonly';
}else{
    $title = 'Copy Users';
    $readonly="";
}
$currentPath = url(config('app.admin_url')).'/candidates/';
//$videoUpload=env('AWS_URL')."videos/".$id."/";
$videoUpload=url(config('app.video_path'))."/".$id."/";
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
                                    <a class="nav-link " href="<?php echo $currentPath.$action.'/'.$id ?>" ><i class="fa fa-home" aria-hidden="true"></i> &nbsp;General</a>
                                    <div class="slide"></div>
                                </li>
                            
                                <li class="nav-item col-md-6">
                                    <a class="nav-link active" href="<?php echo $currentPath.$action.'/videos/'.$id ?>" ><i class="fa fa-caret-square-o-right" aria-hidden="true"></i> &nbsp;Videos</a>
                                    <div class="slide"></div>
                                </li>
                                
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
                        <div class="row">
                        <div class="title_link"> 
                                    <h4><i class="fa fa-caret-square-o-right" aria-hidden="true"></i> Videos</h4>
                                </div> 
                                <div class="row video">  
                                    <?php foreach($videos as $video) {  ?>
                                    <div class="col-md-4 inner_video">
                                        <div class="video_div">
                                            <video width="100%" height="100%" controls>
                                                <source src="<?php echo $videoUpload.$video->video; ?>" type="video/mp4">
                                            </video>
                                            <!-- <img src="<?php //echo $videoUpload.'gif/'.$video->gif; ?>"> -->
                                        </div>
                                        <!-- <div class="title_heading"><?php //echo $video->title; ?></div> -->
                                    </div>
                                    <?php }?> 
                                </div>
                                @if($videos_total_count > 6)
                                <div class="row" style="margin:auto;">
                                     <div class="load_more">
                                     <i class="fa fa-spinner spinner" aria-hidden="true"></i> Load More..
                                    </div>
                                 </div> 
                                 @elseif($videos_total_count == 0)
                                 <div class="align-center">No Record..</div>   
                                 @endif  
                        
                        </div>
                            <input type="hidden" id="id" value="<?php echo $id ?>"> 
                            <input type="hidden" id="loaded_videos" value="<?php echo $loaded_videos; ?>">  
                            <input type="hidden" id="videos_total_count" value="<?php echo $videos_total_count; ?>">
                      </div>
                </div>
            </div>
        </div>
</section>
<script type="text/javascript">

$(function () {
    
    $(".popup img").click(function () {
        var $src = $(this).attr("src");
        $(".show").fadeIn();
        $(".img-show img").attr("src", $src);
    });
    
    $("span, .overlay").click(function () {
        $(".show").fadeOut();
    });
    
});
var offset=0;

$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
    }
});


$(".load_more").click(function(e){
    var id=$('#id').val()
    var loaded_videos=$('#loaded_videos').val();
    var videos_total_count=$('#videos_total_count').val();
    offset=offset+6;
    $('.spinner').show();
    $.ajax({
            url: "<?php echo $currentPath;?>loadMoreVideos",
            type:'POST',
            data: {offset:offset,id:id,loaded_videos:loaded_videos},
            success: function(res) {
                var data=JSON.parse(res);
                // alert(data.loaded_videos);
                if(data.html_data!=""){
                    $(".video").append(data.html_data);
                    $('#loaded_videos').val(data.loaded_videos);
                    $('.spinner').hide();
                    
                    if(videos_total_count<=data.loaded_videos){
                        $('.load_more').hide();
                    }
                }else{
                    $('.load_more').hide();
                }
            }
        }); 
    });
</script>
@endsection