
<?php $__env->startSection('content'); ?>
<?php
   if($action == 'edit'){
    $title = 'Edit Category';
    $readonly="";
}else if($action == 'add') {
    $title = 'Add Category';
    $readonly="";
}else if($action == 'view') {
    $title = 'View Category';
    $readonly='readonly';
}else{
    $title = 'Copy Category';
    $readonly="";
}
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
                        <a href="<?php echo e(route('admin.dashboard')); ?>">
                            <i class="fa fa-home"></i> Dashboard
                        </a>
                    </li>
                    <!-- <li class="breadcrumb-item">
                        <a href="<?php echo e(route('admin.dashboard')); ?>">Dashboard</a>
                    </li> -->
                    <li class="breadcrumb-item">
                        <a href="<?php echo e(route('admin.categories.index')); ?>">Categories Management</a>
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
                            </div>
                        </div>
                        <!-- <div class="row"> -->
                           
                        <?php
                                if($action == 'edit'){?>
                                   <form role="form" action="<?php echo e(url( config('app.admin_url') .'/categories/'.$id)); ?>" method="post">
                                    <?php echo e(method_field('PUT')); ?>

                                <?php }else {?>
                                    <form role="form" action="<?php echo e(url( config('app.admin_url') .'/categories')); ?>" method="post">
                                <?php }?>
                                    <?php echo e(csrf_field()); ?>

                                    <div class="row">
                                        <div class="col-lg-12 col-md-12">
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Category Name <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('cat_name')!='' ){
                                                        $cat_name = old('cat_name');
                                                    }
                                                    else if( isset($category->cat_name) && $category->cat_name != ''){
                                                        $cat_name = $category->cat_name;
                                                    }else{
                                                        $cat_name = '';
                                                    }
                                                    ?>
                                                    <input type="text" class="form-control" name="cat_name" value="<?php echo $cat_name;?>" <?php echo e($readonly); ?>>
                                                </div>
                                            </div>
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Rank <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( old('rank')!='' ){
                                                        $rank = old('rank');
                                                    }
                                                    else if( $action != 'add'){
                                                        if($category->rank == '0'){
                                                                $rank="0";
                                                        }else{
                                                            $rank = $category->rank;
                                                        }
                                                        
                                                    }else{
                                                        $rank = '';
                                                    }
                                                    ?>
                                                    <input type="number" class="form-control" name="rank" value="<?php echo $rank;?>" <?php echo e($readonly); ?>>
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
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.admin', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Hp\Downloads\leuke App Package\laravel_admin\resources\views/admin/categories-create.blade.php ENDPATH**/ ?>