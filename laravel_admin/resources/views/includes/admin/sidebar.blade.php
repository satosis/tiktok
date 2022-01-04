<div class="col-lg-2 main-side-div">
        <div class="side-menu">
        <div class="profile">
            <img src="{{ asset('imgs/user-pic.png') }}" alt="" />
            <h3><?php MyFunctions::getName();?></h3>
        </div>
            <ul class="side_link_ul">
                <!-- <h2>Dashboard</h2> -->
                <li class="main_li"> <i class="fa fa-home" aria-hidden="true"></i> 
                    <a href="{{ route('admin.dashboard')}}" >
                        Dashboard
                    </a>
                </li>
                <li class="main_li"> <i class="fa fa-list-ul" aria-hidden="true"></i> 
                    <a href="{{ url('categories')}}" >
                        Categories
                    </a>
                </li>
                <li class="main_li"> <i class="fa fa-music" aria-hidden="true"></i> 
                    <a href="{{ url('sounds')}}" >
                        Sounds
                    </a>
                </li>

                <li data-toggle="collapse" data-target="#users_menu" class="collapsed main_li">
                  <a href="#"><i class="fa fa-users"></i> Users <span class="arrow"></span></a>
                    <ul class="sub-menu collapse" id="users_menu">
                        <li> <i class="fa fa-angle-right" aria-hidden="true"></i> 
                            <a href="{{ url('candidates/1')}}" >
                                Active
                            </a>
                        </li>
                        <li> <i class="fa fa-angle-right" aria-hidden="true"></i> 
                            <a href="{{ url('candidates/0')}}" >
                                Inactive
                            </a>
                        </li>
                    </ul>
                </li>  
            
                <li class="main_li"> <i class="fa fa-video-camera" aria-hidden="true"></i> 
                    <a href="{{ url('videos')}}" >
                        Videos
                    </a>
                </li>
                <li class="main_li"> <i class="fa fa-tag" aria-hidden="true"></i> 
                    <a href="{{ url('tags')}}" >
                        Tags
                    </a>
                </li>
                <li class="main_li"> <i class="fa fa-file" aria-hidden="true"></i> 
                    <a href="{{ url('reports')}}" >
                        Reports
                    </a>
                </li>
                <li class="main_li"> <i class="fa fa-gear" aria-hidden="true"></i> 
                    <a href="{{ url('settings')}}" >
                        Settings
                    </a>
                </li>
                <li class="main_li"> <i class="fa fa-sign-out" aria-hidden="true"></i> 
                    <a href="{{ route('admin.logout') }}" >
                        Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>