<section id="header">
    <div class="container-fluid">
        <nav class="navbar navbar-expand-lg navbar-light fixed-top">
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
              <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav mr-auto left-nav">
                    <li class="nav-item active">
                        <a class="nav-link" href="#" title="Rachel Allan Home">HOME <span class="sr-only">(current)</span></a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">COLLECTIONS</a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <?php 
                            $categories = MyFunctions::getCategories();
                            foreach ($categories as $category) {
                            ?>
                            <a class="dropdown-item" title="<?php echo $category->cat_name;?>" href="<?php echo $category->alias;?>"><?php echo $category->cat_name;?></a>
                            <?php }?>
                        </div>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">BRIDAL</a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" title="LO'ADORO BRIDAL" href="#">LO'ADORO BRIDAL</a>
                            <a class="dropdown-item" title="LO'ADORO COUTURE BRIDAL" href="#">LO'ADORO COUTURE BRIDAL</a>
                        </div>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" title="DESIGNER EVENTS" href="#">DESIGNER&nbsp;EVENTS</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" title="Rachel Allan Blog" href="#">BLOG</a>
                    </li>
                </ul>
                <div class="logo d-none d-lg-block">
                    <img src="<?php echo url('');?>/imgs/logo.png" alt="Rachel Allan Prom Dresses Designer" title="Rachel Allan Prom Dresses Designer">
                </div>
                <ul class="navbar-nav mr-auto right-nav">
                    <li class="nav-item">
                        <a class="nav-link" title="STORE LOCATOR" href="#">STORE&nbsp;LOCATOR</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" title="LOGIN" href="#">LOGIN</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" title="Register" href="#">REGISTER</a>
                    </li>
                    <li class="nav-item  d-none d-lg-block">
                        <a class="nav-link" title="Search Rachel Allan Collection" href="#" data-toggle="modal" data-target="#searchModal"><i class="fa fa-search " aria-hidden="true"></i></a>
                    </li>
                </ul>
            </div>
        </nav>
        <div class="logo d-lg-none position-fixed z-index-top">
            <img src="<?php echo url('');?>/imgs/logo.png" class="img-responsive" alt="Rachel Allan Prom Dresses Designer" title="Rachel Allan Prom Dresses Designer">
        </div>
        <div class="search d-lg-none position-fixed z-index-top">
            <a class="nav-link" href="#" data-toggle="modal" data-target="#searchModal"><i class="fa fa-search " aria-hidden="true"></i></a>
        </div>
        <div class="modal fade" id="searchModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form name="form" method="post" class="search-form">
                            <input type="text" name="q" id="q" class="search-field" autocomplete="off" placeholder="Type keyword(s) here"/><br/>
                            <input type="submit" name="cmdSearch" value="Search" class="search-btn"/>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>