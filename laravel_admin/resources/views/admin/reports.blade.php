@extends('layouts.admin')
@section('content')
<?php
$path = url(config('app.admin_url')).'/reports';
?>
<section class="rightside-main">
	<div class="container-fluid">
        <div class="page-top">
            <div class="page-header borderless ">
                <h4>Manage Reports</h4>   
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
                        <a href="{{ route('admin.reports.index')}}">Reports Management</a>
                    </li>
                    <!-- <li class="breadcrumb-item">
                        <a href="#">Manage Reports</a>
                    </li> -->
                </ul>       
            </div>
        </div>
        <div class="card table-card ">
            <div class="row card-header borderless ">
                    <div class="col-md-8 col-lg-8">
                        <h3>Reports</h3>
                    </div>
                    <!-- <div class="col-md-4 col-lg-4 align-right"> 
                        <button id="add" class="btn btn-primary" onclick='document.location.href="<?php echo $path.'/create/'?>"'>Add New
                        </button>
                    </div> -->
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
                                                <th class="sorting">Video Title</th>
                                            <th class="sorting">Report Type</th>
                                            <th class="sorting">Report By</th>
                                            
                                            <th class="sorting">Description</th>
                                            <th class="sorting">Report On</th>
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
<script type="text/javascript">
    var table;
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
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
        table = $('#data_table').DataTable({
                "processing": true, //Feature control the processing indicator.
                "serverSide": true, //Feature control DataTables' server-side processing mode.
                "order": [], //Initial no order.

                // Load data for the table's content from an Ajax source
                "ajax": {
                    "url": "<?php echo $path;?>/server_processing",
                    "type": "POST",
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
                "dom": '<"top"flp<"clear">>rt<"bottom"ip<"clear">>',
                "pageLength": <?php echo config('app.admin_records');?>,
                "lengthMenu": [ [10,20,30,50,100,-1], [10,20,30,50,100,"All"] ],
                //Set column definition initialisation properties.
                "columnDefs": [
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
@endsection