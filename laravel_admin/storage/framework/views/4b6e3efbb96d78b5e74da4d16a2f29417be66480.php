<?php $__env->startSection('content'); ?>
<style type="text/css">
    .help-block{
        color: #e73d4a;
    }
</style> 
<form class="login-form" method="POST" action="<?php echo e(route('admin.register')); ?>"> 
   <?php echo e(csrf_field()); ?>          
   <h3 class="form-title font-green">Sign Up</h3>                              
   <?php if($message = Session::get('error')): ?>
   <div class="alert alert-danger alert-block">
    <button type="button" class="close" data-dismiss="alert">×</button> 
    <strong><?php echo e($message); ?></strong>
</div>
<?php endif; ?>
<div class="form-group">                
    <label class="control-label visible-ie8 visible-ie9">Name</label>
    <input id="name" type="text" class="form-control" name="name" value="<?php echo e(old('name')); ?>" required autofocus type="text" autocomplete="off" placeholder="Your Name">
    <?php if($errors->has('name')): ?>
    <span class="help-block">
        <strong><?php echo e($errors->first('name')); ?></strong>
    </span>
    <?php endif; ?>
</div>
<div class="form-group">   
    <label class="control-label visible-ie8 visible-ie9">Email</label>
    <input id="email" type="email" class="form-control" name="email" value="<?php echo e(old('email')); ?>" required autofocus type="text" autocomplete="off" placeholder="Your email">
    <?php if($errors->has('email')): ?>
    <span class="help-block">
        <strong><?php echo e($errors->first('email')); ?></strong>
    </span>
    <?php endif; ?>
</div>
<div class="form-group">
    <label class="control-label visible-ie8 visible-ie9">Password</label>                  
    <input id="password" type="password" class="form-control" name="password" required autocomplete="off" placeholder="Password">
    <?php if($errors->has('password')): ?>
    <span class="help-block">
        <strong><?php echo e($errors->first('password')); ?></strong>
    </span>
    <?php endif; ?>
</div>
<div class="form-group ">
    <label class="control-label visible-ie8 visible-ie9"><?php echo e(__('Confirm Password')); ?></label>                  
    <input id="password-confirm" type="password" class="form-control" name="password_confirmation" required>
    <?php if($errors->has('password_confirmation')): ?>
    <span class="help-block">
        <strong><?php echo e($errors->first('password_confirmation')); ?></strong>
    </span>
    <?php endif; ?>
</div>

<div class="form-actions" style="text-align: center;">
    <button type="submit" class="btn green uppercase">Register</button>
</div>              
</form>     
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.admin_login', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Hp\Downloads\leuke App Package\laravel_admin\resources\views/admin/auth/register.blade.php ENDPATH**/ ?>