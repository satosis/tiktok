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
$imageUpload=env('AWS_URL')."photos/".$id."/";
?>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/fancyapps/fancybox@3.5.7/dist/jquery.fancybox.min.css" />
<script src="https://cdn.jsdelivr.net/gh/fancyapps/fancybox@3.5.7/dist/jquery.fancybox.min.js"></script>

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
                                    <a class="nav-link active" href="<?php echo $currentPath.$action.'/photos/'.$id ?>" ><i class="fa fa-camera" aria-hidden="true"></i> &nbsp;Photos</a>
                                    <div class="slide"></div>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="<?php echo $currentPath.$action.'/videos/'.$id ?>" ><i class="fa fa-caret-square-o-right" aria-hidden="true"></i> &nbsp;Videos</a>
                                    <div class="slide"></div>
                                </li>
                    
                            </ul>
                            
                            <div class="card-block photos"> 
                                <div class="title_link">     
                                    <h4><i class="fa fa-camera" aria-hidden="true"></i> Photos </h4>          
                                </div> 
                                <div class="row pics">  
                                    <?php foreach($photos as $photo) {  ?>
                                    <div class="col-md-3 inner_pics">
                                    	<div class="photo_div">
                                        	<a data-fancybox="gallery" href="<?php echo $imageUpload.$photo->file?>"><img src="<?php echo $imageUpload.$photo->file?>" class="img-responsive img-fluid m-b-10"></a>
                                    	</div>
                                    </div>
                                    <?php }?> 
                                 </div>
                                 @if($photos_total_count > 4)
                                 <div class="row">
                                     <div class="load_more">
                                     <i class="fa fa-spinner spinner" aria-hidden="true"></i> Load More..
                                    </div>
                                 </div>
                                 @elseif($photos_total_count == 0)
                                 <div class="align-center">
                                     No Record...
                                 </div>
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
    offset=offset+8;
    $('.spinner').show();
    $.ajax({
                url: "<?php echo $currentPath;?>loadMore",
                type:'POST',
                data: {offset:offset,id:id},
                success: function(data) {
                    if(data!=""){
                        $(".pics").append(data);
                        $('.spinner').hide();
                    }
                    else{
                        $('.load_more').hide();
                    }
                }
            });
});
</script>
@endsection