@extends('layouts.admin')
@section('content')
<div class="page-header">
    <div class="page-block">
        <div class="row align-items-center">
            <div class="col-md-8">
                <div class="page-header-title">
                    <h4 class="m-b-10">View Category</h4>
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
                        <a href="#">View Candidate</a>
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
                                <h3>View Producer</h3> 
                            </div>
                            <div class="card-block"> 
                                <div class="row">
                                    <div class="col-lg-12 col-md-12">
                                        <div class="form-group row">
                                            <label class="col-sm-2 col-form-label">Show In <span class="requried">*</span></label>
                                            <div class="col-sm-10">
                                                <?php
                                                if( isset($category->show_in) && $category->show_in != ''){
                                                    $show_in = $category->show_in;
                                                }else{
                                                    $show_in = '';
                                                }
                                                if($show_in == 'US') echo "USA";
                                                else if ($show_in == 'UK') echo "UK";
                                                else if($show_in == 'BT') echo "BOTH";
                                                ?>                                                
                                            </div>
                                        </div>
                                        <div id='uk_div' style="<?php if($show_in == 'BT' || $show_in == 'UK') echo "display: block;";else echo "display: none;";?>">
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Category Name (UK) <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( isset($category->uk_cat_name) && $category->uk_cat_name != ''){
                                                        $uk_cat_name = $category->uk_cat_name;
                                                    }else{
                                                        $uk_cat_name = '';
                                                    }
                                                    echo $uk_cat_name;?>
                                                </div>
                                            </div> 
                                        </div>
                                        <div id='us_div' style="<?php if($show_in == 'BT' || $show_in == 'US') echo "display: block;";else echo "display: none;";?>">
                                            <div class="form-group row">
                                                <label class="col-sm-2 col-form-label">Category Name (USA) <span class="requried">*</span></label>
                                                <div class="col-sm-10">
                                                    <?php
                                                    if( isset($category->cat_name) && $category->cat_name != ''){
                                                        $cat_name = $category->cat_name;
                                                    }else{
                                                        $cat_name = '';
                                                    }
                                                    echo $cat_name;?>
                                                </div>
                                            </div> 
                                        </div>                                                                                  
                                        <div class="form-group row">
                                            <label class="col-sm-2 col-form-label">Parent Id</label>
                                            <div class="col-sm-10">
                                            <?php
                                            if( isset($category->parent_cat_name) && $category->parent_cat_name != ''){
                                                $parent_cat_name = $category->parent_cat_name;
                                            }else{
                                                $parent_cat_name = '';
                                            }
                                            echo $parent_cat_name;
                                            ?>                                            
                                        </div>
                                    </div>                                        
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Rank <span class="requried">*</span></label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->rank) && $category->rank != ''){
                                                $rank = $category->rank;
                                            }else{
                                                $rank = '';
                                            }
                                            echo $rank;?>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Login Required</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->login_required) && $category->login_required != ''){
                                                $login_required = $category->login_required;
                                            }else{
                                                $login_required = '0';
                                            } 
                                            if($login_required==1) echo 'Yes';
                                            else echo 'No';
                                            ?>                                             
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Visible</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->visible) && $category->visible != ''){
                                                $visible = $category->visible;
                                            }else{
                                                $visible = '0';
                                            }
                                            if($visible==1) echo 'Yes';
                                            else echo 'No'; 
                                            ?>                                           
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Top Description (USA) </label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->top_description) && $category->top_description != ''){
                                                $top_description = $category->top_description;
                                            }else{
                                                $top_description = '';
                                            }
                                            echo $top_description;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Top Description (UK) </label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->uk_top_description) && $category->uk_top_description != ''){
                                                $uk_top_description = $category->uk_top_description;
                                            }else{
                                                $uk_top_description = '';
                                            }
                                            $uk_top_description;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Bottom Description (USA) </label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->description) && $category->description != ''){
                                                $description = $category->description;
                                            }else{
                                                $description = '';
                                            }
                                            echo $description;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Bottom Description (UK) </label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->uk_description) && $category->uk_description != ''){
                                                $uk_description = $category->uk_description;
                                            }else{
                                                $uk_description = '';
                                            }
                                            echo $uk_description;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Alias</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->alias) && $category->alias != ''){
                                                $alias = $category->alias;
                                            }else{
                                                $alias = '';
                                            }
                                            echo $alias;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Meta Title</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->meta_title) && $category->meta_title != ''){
                                                $meta_title = $category->meta_title;
                                            }else{
                                                $meta_title = '';
                                            }
                                            echo $meta_title;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Meta Keyword</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->meta_keyword) && $category->meta_keyword != ''){
                                                $meta_keyword = $category->meta_keyword;
                                            }else{
                                                $meta_keyword = '';
                                            }
                                            echo $meta_keyword;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">Meta Description</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->meta_description) && $category->meta_description != ''){
                                                $meta_description = $category->meta_description;
                                            }else{
                                                $meta_description = '';
                                            }
                                            echo $meta_description;?>
                                        </div>
                                    </div> 
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">OG Title</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->og_title) && $category->og_title != ''){
                                                $og_title = $category->og_title;
                                            }else{
                                                $og_title = '';
                                            }
                                            echo $og_title;?>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-2 col-form-label">OG Description</label>
                                        <div class="col-sm-10">
                                            <?php
                                            if( isset($category->og_description) && $category->og_description != ''){
                                                $og_description = $category->og_description;
                                            }else{
                                                $og_description = '';
                                            }
                                            echo $og_description;?>
                                        </div>
                                    </div> 
                                </div>                                        
                            </div>                                                            
                        </div>
                    </div>
                </div>                    
            </div>
        </div>
    </div>
</div>
</div>
<style type="text/css">
    .ppbt span {
        position: relative !important;
    }
    .column_header{      
        color: grey !important;
        border:1px solid #e7e7e7 !important;
        /*background: url(../sort_both.png) center right no-repeat;*/
    }
    .table-bordered{
        border:1px solid #e7e7e7 !important;
    }  
    .margin-tp-bt-10{
        margin:10px 0;
    }
    .h_check{
        text-align: center;
    }
    #data_table td:first-child a {
        margin: 0 15px !important;
    }
    .requried{
        color:red;
    }
</style>
@endsection