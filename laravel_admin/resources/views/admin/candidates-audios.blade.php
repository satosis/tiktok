@extends('layouts.admin')
@section('content')
<?php
   if($action == 'edit'){
    $title = 'Edit Candidate';
    $readonly="";
}else if($action == 'add') {
    $title = 'Add Candidate';
    $readonly="";
}else if($action == 'view') {
    $title = 'View Candidate';
    $readonly='readonly';
}else{
    $title = 'Copy Candidate';
    $readonly="";
}
$currentPath = url(config('app.admin_url')).'/candidates/';
$audioUpload='/../bollywood/public/assets/audios/';
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
                        <a href="{{ route('admin.candidates.index')}}">Candidates Management</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.candidates.index')}}">Manage Candidates</a>
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
                            <ul class="nav nav-tabs md-tabs" role="tablist">
                                <li class="nav-item">
                                    <a class="nav-link " href="<?php echo $currentPath.$action.'/'.$id ?>" ><i class="fa fa-home" aria-hidden="true"></i> &nbsp;General</a>
                                    <div class="slide"></div>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link " href="<?php echo $currentPath.$action.'/photos/'.$id ?>" ><i class="fa fa-camera" aria-hidden="true"></i> &nbsp;Photos</a>
                                    <div class="slide"></div>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="<?php echo $currentPath.$action.'/videos/'.$id ?>" ><i class="fa fa-caret-square-o-right" aria-hidden="true"></i> &nbsp;Videos</a>
                                    <div class="slide"></div>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link active" href="<?php echo $currentPath.$action.'/audios/'.$id ?>" ><i class="fa fa-caret-right" aria-hidden="true"></i> &nbsp;Audios</a>
                                    <div class="slide"></div>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="<?php echo $currentPath.$action.'/documents/'.$id ?>" ><i class="fa fa-file-image-o" aria-hidden="true"></i> &nbsp;Documents</a>
                                    <div class="slide"></div>
                                </li>
                            </ul>
                            
                            <div class="card-block photos">      
                                <div class="title_link">
                                    <h4><i class="fa fa-caret-right" aria-hidden="true"></i> Audios </h4>
                                </div>                        
                                
                                <div class="row audio">
                                    <?php foreach($audios as $audio) {  ?>
                                    <div class="col-md-4 align-center">
                                        <audio width="100%" height="auto" controls>
                                            <source src="<?php echo $audioUpload.$audio->audio ?>" type="audio/mpeg">
                                        </audio>
                                        <div class="title_heading"><?php echo $audio->title; ?></div>
                                    </div>
                                    <?php }?> 
                                </div> 
                                @if($audios_total_count > 3)
                                <div class="row aa">
                                     <div class="load_more">
                                     <i class="fa fa-spinner spinner" aria-hidden="true"></i> Load More
                                    </div>
                                 </div>
                                 @elseif($audios_total_count == 0)
                                 <div class="align-center">No Record.. </div>
                                 @endif
                            </div> 
                            <input type="hidden" id="id" value="<?php echo $id ?>">      
                        </div>
                    </div>                    
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
var offset=0;

$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
    }
});

$(".load_more").click(function(e){
    var id=$('#id').val()
    offset=offset+3;
    $('.spinner').show();
    $('.aa').hide();
    $.ajax({
                url: "<?php echo $currentPath;?>loadMoreAudios",
                type:'POST',
                data: {offset:offset,id:id},
                success: function(data) {
                    if(data!=""){
                        $(".audio").append(data);
                        $('.spinner').hide();
                    }else{
                        $('.load_more').hide();
                    }
                    
                }
               
            });
});
</script>
@endsection