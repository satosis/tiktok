
<?php $__env->startSection('content'); ?>
<?php
$path = url(config('app.admin_url')).'/sounds';
?>
<style>
.cat_select,.active_select{
    width:150px;
    float:right;
}
.fa-play{
    border: 1px solid #ccc;
    border-radius: 50%;
    height: 30px;
    width: 30px;
    padding: 7px 10px;
    margin-left: 10px;
    cursor:pointer;
}

.select2-container--default .select2-selection--single .select2-selection__rendered{
    background-color:#fff;
    padding:5px;
    /* padding-top:5px; */
    line-height:15px;
}
div.dt-buttons {
    clear: none;
    margin-left: 33px;
    display: initial;
}
</style>
<section class="rightside-main">
	<div class="container-fluid">
        <div class="page-top">
            <div class="page-header borderless ">
                <h4>Manage Sounds</h4>   
            </div>
            <div class="page-berdcrumb">
                <ul class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="<?php echo e(route('admin.dashboard')); ?>">
                            <i class="fa fa-home"></i> Dashboard
                        </a>
                    </li>
                    <!-- <li class="breadcrumb-item">
                        <a href="<?php echo e(route('admin.dashboard')); ?>">Dashboard</a>
                    </li> -->
                    <li class="breadcrumb-item">
                        <a href="<?php echo e(route('admin.sounds.index')); ?>">Sounds Management</a>
                    </li>
                    <!-- <li class="breadcrumb-item">
                        <a href="#">Manage Sounds</a>
                    </li> -->
                </ul>       
            </div>
        </div>
        <div class="card table-card ">
                    <div class="row card-header borderless ">
                        <div class="col-md-8 col-lg-8"><h3>Sounds</h3></div>
                        
                        <div class="col-md-4 col-lg-4 align-right"> 
                            <button id="add" class="btn btn-primary" onclick='document.location.href="<?php echo $path.'/create/'?>"'>Add New
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                                    <div class="col-md-3">
                                        <lable>Select Category : </label>
                                         &nbsp;
                                        <select class="cat_select form-control js-example-basic-multiple" name="category" >
                                            <option value="">---Select---</option>
                                            <?php
                                            
                                            foreach($categories as $cat){ ?>
                                                <option value="<?php echo $cat->cat_id; ?>"><?php echo $cat->cat_name; ?></option>
                                            <?php } 
                                                
                                            ?>
                                        </select>
                                    </div>  
                                    <div class="col-md-3 align-center">
                                        <h6 style="display:inline;">Search By Status :</h6>
                                        <select class="active_select form-control " name="active" >
                                            <option value="">---Select---</option>
                                            <option value="1">Active</option>
                                            <option value="0">Not Active</option>
                                           
                                        </select> 
                                    </div>
                                    <div class="col-md-4"></div>
                                    <div class="col-md-2 align-right">
                                    <!-- <form action="<?php echo e(route('admin.import')); ?>" method="POST" enctype="multipart/form-data"> -->
                                     <form method="POST" id="import_form" enctype="multipart/form-data">
                                        <!-- <?php echo csrf_field(); ?> -->
                                        <input type="file" name="file" class="import_file" style="display:none">
                                        <!-- <br> -->
                                       <input type="button" class="btn btn-success import_btn" value="Import File">
                                        <!--  <a class="btn btn-warning" href="<?php echo e(route('admin.export')); ?>">Export User Data</a> -->
                                    </form>
                                    </div> 
                                </div>
                                <hr></hr>
                        <div class="row">
                            <div class="col-lg-12 col-md-12">
                                <?php if($message = Session::get('success')): ?>
                                <div class="alert alert-success alert-block">
                                    <button type="button" class="close" data-dismiss="alert">×</button> 
                                    <strong><?php echo e($message); ?></strong>
                                    <?php Session::forget('success');?>
                                </div>
                                <?php endif; ?>
                                <?php if($message = Session::get('error')): ?>
                                <div class="alert alert-danger alert-block">
                                    <button type="button" class="close" data-dismiss="alert">×</button> 
                                    <strong><?php echo $message; ?></strong>
                                    <?php Session::forget('error');?>
                                </div>
                                <?php endif; ?>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12 col-md-12 table-responsive">
                                <table id="data_table" class="table cell-border compact hover order-column row-border stripe">
                                    <thead>
                                    <tr>
                                                <th width="10%">Action</th>
                                                <th width="5%" class="h_check">
                                                    <input type="checkbox" id="remember_me" name="key_m[]" class="red-check"/>
                                                </th>
                                                <th class="sorting">Sound Id</th>
                                                <th class="sorting">Title</th>
                                                <th class="sorting">Category</th>
                                                <th class="sorting">Sound Name</th>
                                                <th class="sorting">Tags</th>
                                                <th class="sorting">Album</th>
                                                <th class="sorting">Status</th>
                                                <th class="sorting">Duration</th>
                                            </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="row margin-tp-bt-10">
                            <div class="col-lg-12 col-md-12">
                                <button id="deleteSel" class="btn btn-danger">Delete Selected</button>
                            </div>
                        </div>

                    </div>
                </div>
</div>
</div>
</section>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/buttons/1.6.2/js/dataTables.buttons.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js"></script>
<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js"></script>
<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/buttons/1.6.2/js/buttons.html5.min.js"></script>
<script type="text/javascript">
    var table;
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });
    $('.import_btn').click(function(){ $('.import_file').trigger('click'); });
    $(".import_file").change(function(){
    $.ajax({
        url: "<?php echo url('').'/'.config('app.admin_url');?>/import",
       type: "POST",
       processData: false,
       contentType: false,
        data: new FormData($('#import_form')[0]), 
        success: function(result){
            $('.import-success').show();
            $('#data_table').DataTable().draw(true);
            $(".import-success").delay(3000).fadeOut(500); 
        }});
    });
    $(document).ready(function() {

        $(document).on("click",".process", function() {          
            $("#user_id_hidden").val($(this).attr("data-val"));
        });

        $('#deleteSel').click(function(){
            var favorite = [];
            $.each($(".delete_box:checked"), function(){
                favorite.push($(this).attr('data-val'));
            });
            if(favorite != "") {
                if (confirm('Are you sure you want to delete ?')) {
                    var ids =favorite.join(",");
                    $.post('<?php echo $path;?>/delete','ids='+ids,function(data){
                        window.location = '<?php echo $path;?>';
                    });
                }
            } else {
                alert("Please select item to delete.")
            }
        });
        $(document).on('click','.deleteSelSingle',function(e){
            e.preventDefault();   
            if (confirm('Are you sure you want to delete ?')) {
                var favorite = [];
                favorite.push($(this).attr('data-val'));
                var ids =favorite.join(",");
                $.post('<?php echo $path;?>/delete','ids='+ids,function(data){
                    window.location = '<?php echo $path;?>';
                });
            }
        });
        var buttonCommon = {
        exportOptions: {
            format: {
                body: function ( data, row, column, node ) {
                    // Strip $ from salary column to make it numeric
                    return column === 5 ?
                        data.replace( /[$,]/g, '' ) :
                        data;
                }
            }
        }
    };
        table = $('#data_table').DataTable({
                "processing": true, //Feature control the processing indicator.
                "serverSide": true, //Feature control DataTables' server-side processing mode.
                "order": [], //Initial no order.

                // Load data for the table's content from an Ajax source
                "ajax": {
                    "url": "<?php echo $path;?>/server_processing",
                    "type": "POST",
                    data: function (d) {
                        d.category = $('.cat_select').val(),
                        d.active = $('.active_select').val()
                    }
                   // "data":{"type" : <?php //echo "'".$type."'"?>}
                },
                "language": {
                    "processing": "<img src='<?php echo url('')?>/assets/images/loading.gif'>",
                    "search": '<i class="fa fa-search"></i>',
                    "searchPlaceholder": "Search",
                    "paginate": {
                        "previous": '<i class="fa fa-angle-double-left"></i>',
                        "next": '<i class="fa fa-angle-double-right"></i>'
                    }
                },
    
                dom: 'lBfrtip',
		        buttons: [
		            $.extend( true, {}, buttonCommon, {
		                extend: 'excelHtml5',
		                text: 'Export Excel',
                        className: 'btn btn-warning',
		                title: 'Excel',
		                exportOptions: {
				            columns: 'th:not(:nth-child(1),:nth-child(2))',
	 						modifier: {
	 							page: 'all',
	 							search: 'none'
	                		}				        
				            
				        }
		            } ),
		            // $.extend( true, {}, buttonCommon, {
		            //     extend: 'pdfHtml5',
		            //     text: 'EXPORT USER DATA AS PDF',
		            //     title: 'USER DATA',
		            //     exportOptions: {
				    //         columns: 'th:not(:first-child)'
				    //     }
		            // } )
		        ],
                    
                "pageLength": 100,
                "lengthMenu": [ [10,20,30,50,100,-1], [10,20,30,50,100,"All"] ],
                //Set column definition initialisation properties.
                "columnDefs": [
                    {
                        "targets": [ 2 ],
                        "visible": false,
                        "searchable": false
                    },
                { 
                    "targets": [ 0,1 ], //first column / numbering column
                    "orderable": false, //set not orderable
                },
                { className: "actionss", "targets": [ 0 ] }, { className: "checkboxColumn", "targets": [ 1 ] }
                ],
                
            });
        $("#remember_me").parent().find('th').removeClass('sorting').addClass('sorting_disabled');
        $("#remember_me").click(function () {
            $(".delete_box").prop('checked', $(this).prop('checked'));
        });
        $(".delete_box").change(function(){
            if (!$(this).prop("checked")){
                $("#remember_me").prop("checked",false);
            }
        });
    });
  

    $('.cat_select').change(function(){
        $('#data_table').DataTable().draw(true);
     });
     $('.active_select').change(function(){
        $('#data_table').DataTable().draw(true);
     });

    function audio_file(sound_id){
         if(sound_id>0){
            $.post('<?php echo $path;?>/audio_play','id='+sound_id,function(data){
                       $('.audio_file_'+sound_id).html(data);
                    });
         }
     
    }
    
    function start_loading(){
        $('#overlay').show();
    }
    function stop_loading() {
        $('#overlay').hide();
    }
    function showError(id,errMsg){
        if($.isArray(errMsg)){
            var errHtml = "<ul>";
            $.each( errMsg, function( key, value ) {
                errHtml +='<li>'+value+'</li>';
            });
            errHtml+= '</ul>';
            $("#" + id ).html(errHtml).show();
        }else{
            $('#' + id).html(errMsg).show();
        }
        setTimeout(function(){
            $("#" + id ).html('').hide('slow');
        }, 5000);
    }
    function showSuccess(id,msg,modal_id){
        $('#' + id).html(msg).show();
        setTimeout(function(){
            $("#" + id ).html('').hide('slow');
            $('#'+ modal_id).modal('hide');
        }, 5000);
    }
</script>
<script>

$(document).ready(function() {
    $('.js-example-basic-multiple').select2();
});
// $(".import_btn").click(function(){
//   $("input").trigger(".import_file");
// });

</script>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.admin', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Hp\Downloads\leuke App Package\laravel_admin\resources\views/admin/sounds.blade.php ENDPATH**/ ?>