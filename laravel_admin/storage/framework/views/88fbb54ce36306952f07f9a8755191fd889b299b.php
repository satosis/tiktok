<?php $__env->startSection('content'); ?>
<style>
.login_div h2{
    letter-spacing:0px;
    box-shadow: 0px 0px 8px #ccc;
    padding-bottom:5px;
}
</style>
<section class="no-pad">                   	
                   	<div class="container-fluid">
                   	<div class="row">
                   		<div class="col-lg-4 col-md-4 login_div">
                         
                   			<div class="card">
                               <div class="col-lg-12 login_logo">
                                    <img src="<?php echo e(asset('imgs/logo-blue.jpg')); ?>" alt="" width="40%"/>					
                                </div>
                   				<div class="form-main">
                                   <?php if($message = Session::get('error')): ?>
                                        <div class="alert alert-danger background-danger">
                                            <button type="button" class="close" data-dismiss="alert">×</button> 
                                            <strong><?php echo e($message); ?></strong>
                                        </div>
                                    <?php endif; ?>
                                   <h2 class="text-center">Sign In</h2>
                                   <form method="POST" action="<?php echo e(route('admin.loginPost')); ?>"> 
                                    <?php echo e(csrf_field()); ?>

                                        <h4>Enter Your Email</h4>
                                        <input type="text" class="form-control" id="name" name="name" value="<?php echo e(old('name')); ?>" required placeholder="Username">
                                        <?php if($errors->has('name')): ?>
                                            <span class="help-block"><?php echo e($errors->first('name')); ?></span>
                                        <?php endif; ?>
                                        <h4>Enter Your Password</h4>
                                        <input id="password" type="password" class="form-control" name="password" required placeholder="Password">
                                        <?php if($errors->has('password')): ?>
                                            <span class="help-block"><?php echo e($errors->first('password')); ?></span>
                                            <?php endif; ?>  
                                        <div class="row">
                                            <button type="submit" class="col-md-12 btn btn-primary">Submit</button>
                                        </div>
                                    </form>
                   					
                   				</div>
                   				
                   			</div>
                   			
                   		</div>
                   		</div>
                           </div>
</section>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.admin_login', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Hp\Downloads\leuke App Package\laravel_admin\resources\views/admin/auth/login.blade.php ENDPATH**/ ?>