
<?php $__env->startSection('content'); ?>
<?php
    if($action == 'edit'){
        $title = 'Settings';
        $readonly="";
    }
?>
<section class="rightside-main">
    <div class="container-fluid">
        <div class="page-top">
            <div class="page-header borderless">
                <h4><?php echo $title; ?></h4>   
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
                        <a href="<?php echo e(route('admin.categories.index')); ?>"><?php echo e($title); ?></a>
                    </li>
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
                                <?php if(count($errors) > 0): ?>
                                <div class="alert alert-danger">
                                    <ul>
                                    <?php $__currentLoopData = $errors->all(); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $error): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                                        <li><?php echo e($error); ?></li>
                                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                                    </ul>
                                </div>
                                <?php endif; ?>
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
                        <!-- <div class="row"> -->
                           
                        <?php
                                if($action == 'edit'){?>
                                   <form role="form" action="<?php echo e(url( config('app.admin_url') .'/settings/'.$id)); ?>" method="post" enctype="multipart/form-data">
                                    <?php echo e(method_field('PUT')); ?>

                                <?php }else {?>
                                    <form role="form" action="<?php echo e(url( config('app.admin_url') .'/categories')); ?>" method="post" enctype="multipart/form-data">
                                <?php }?>
                                    <?php echo e(csrf_field()); ?>

                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Company Name</label>
                                                <div class="col-sm-5">
                                                    <?php
                                                    if(old('site_name')!=''){
                                                        $site_name = old('site_name');
                                                    }
                                                    else if( isset($settings->site_name) && $settings->site_name != ''){
                                                        $site_name = $settings->site_name;
                                                    }else{
                                                        $site_name = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="site_name" value="<?php echo $site_name; ?>">
                                                </div> 
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Address</label>
                                                <div class="col-sm-5">
                                                    <?php
                                                    if(old('site_address')!=''){
                                                        $site_address = old('site_address');
                                                    }
                                                    else if( isset($settings->site_address) && $settings->site_address != ''){
                                                        $site_address = $settings->site_address;
                                                    }else{
                                                        $site_address = '';
                                                    }
                                                    ?>
                                                    <textarea name="site_address" class="form-control"><?php echo e($site_address); ?></textarea>
                                                </div> 
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Phone</label>
                                                <div class="col-sm-5">
                                                    <?php
                                                    if(old('site_phone')!=''){
                                                        $site_phone = old('site_phone');
                                                    }
                                                    else if( isset($settings->site_phone) && $settings->site_phone != ''){
                                                        $site_phone = $settings->site_phone;
                                                    }else{
                                                        $site_phone = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="site_phone" value="<?php echo $site_phone; ?>">
                                                </div> 
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Email</label>
                                                <div class="col-sm-5">
                                                    <?php
                                                    if(old('site_email')!=''){
                                                        $site_email = old('site_email');
                                                    }
                                                    else if( isset($settings->site_email) && $settings->site_email != ''){
                                                        $site_email = $settings->site_email;
                                                    }else{
                                                        $site_email = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="site_email" value="<?php echo $site_email; ?>">
                                                </div> 
                                            </div> 
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Logo</label>
                                                <div class="col-sm-5">
                                                    <?php
                                                    if( old('site_logo')!='' ){
                                                        $site_logo = old('site_logo');
                                                    }
                                                    else if( isset($settings->site_logo) && $settings->site_logo != ''){
                                                        $site_logo = $settings->site_logo;
                                                    }else{
                                                        $site_logo = '';
                                                    }
                                                    ?>
                                                    <?php if($action!='view'): ?> <input type="file" class="form-control" name="site_logo"> <?php endif; ?>
                                                    <input type="hidden" class="form-control" name="old_site_logo" value="<?php echo $site_logo;?>" readonly>
                                                    <?php if($site_logo!=""): ?>
                                                    <img src="<?php echo asset('storage/uploads/logos/'.$site_logo);?>" width="130px">
                                                    <?php endif; ?>
                                                </div>  
                                            </div>   
                                        </div>
                                    </div>
                                    <div class="row margin-tp-bt-10">
                                        <input type="hidden" name="id" value="<?php echo (isset($id)) ? $id : 0; ?>">
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
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.admin', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH E:\Wamp64\www\leuke-app\resources\views/admin/settings-create.blade.php ENDPATH**/ ?>