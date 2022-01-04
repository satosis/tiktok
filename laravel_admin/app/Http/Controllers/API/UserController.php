<?php

namespace App\Http\Controllers\API;
use DateTime;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage; 
use Illuminate\Support\Facades\Hash;
use App\Helpers\Common\Functions;
use Intervention\Image\ImageManagerStatic as Image;
use Auth;
use Mail;
use Illuminate\Support\Facades\URL; 

class UserController extends Controller
{
    private function _error_string($errArray)
    {
        $error_string = '';
        foreach ($errArray as $key) {
            $error_string.= $key."\n";
        }
        return $error_string;
    }

    public function index(Request $request){

    }
    
     public function updateUserProfilePic(Request $request){
		$validator = Validator::make($request->all(), [ 
	            'user_id'          => 'required',              
	            'app_token'        => 'required',
	            'profile_pic'          => 'required|image|mimes:jpeg,png,jpg,gif,svg',             
	        ],[ 
	            'user_id.required'      => 'Id is required',
	            'app_token.required'    => 'App Token is required',
	            'profile_pic.required'	=> 'Profile Image is required',         

	        ]);

       if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
               
            $path = 'public/profile_pic/'.$request->user_id;
        
            $filenametostore = $request->file('profile_pic')->store($path);  
            Storage::setVisibility($filenametostore, 'public');
            $fileArray = explode('/',$filenametostore);  
            $fileName = array_pop($fileArray); 
            $functions->_cropImage(secure_asset(Storage::url('public/profile_pic/'.$request->user_id.'/'.$fileName)),500,500,0,0,$path.'/small',$fileName);
            $file_path = secure_asset(config('app.profile_path').$request->user_id."/".$fileName);
            $small_file_path = secure_asset(config('app.profile_path').$request->user_id."/small/".$fileName);
            if($file_path==""){
                $file_path=secure_asset(config('app.profile_path')).'default-user.png';
            }
            if($small_file_path==""){
                $small_file_path=secure_asset(config('app.profile_path')).'default-user.png';
            }
            
                $data =array(
                    'user_id'       => $request->user_id,
                    'image'         => $fileName
                                            
                ); 
                
                DB::table('users')
                    ->where('user_id',$request->user_id)
                    ->update(['user_dp'=>$fileName]);
                   
                $response = array("status" => "success",'msg'=>'Profile pic uploaded successfully' , 'large_pic' => $file_path ,'small_pic' => $small_file_path);
                                                    
            
            return response()->json($response); 
        
        }
    }
    
    public function fetchUserInformation(Request $request){
        $validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',
	    ],[ 
	        'user_id.required'      => 'User id is required',
	    ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
			$videoStoragePath  = secure_asset(config("app.video_path"));
	        $limit=15;
	        $userVideos = DB::table("videos as v")
	        				->select(DB::raw("video_id,case when v.user_id = 0  then concat('".$videoStoragePath."/',video) else concat('".$videoStoragePath."/',v.user_id,'/',video) end as video,case when thumb='' then '' else concat('".$videoStoragePath."/',v.user_id,'/thumb/',thumb) end as thumb,ifnull(case when gif='' then '' else concat('".$videoStoragePath."/',v.user_id,'/gif/',gif) end,'') as gif,ifnull(s.title,'') as sound_title,concat('@',u.username) as username,v.duration,v.user_id,v.tags,ifnull(v.created_at,'NA') as created_at,ifnull(v.updated_at,'NA') as updated_at,
	        				(CASE WHEN v.total_views >= 1000000000
        													 			THEN concat(FORMAT(v.total_views/1000000000,2),' ','B')
        													 	  WHEN v.total_views >= 1000000
        													 	  		THEN concat(FORMAT(v.total_views/1000000,2),' ','M')
        													 	  WHEN v.total_views >= 1000
        													 	  		THEN concat(FORMAT(v.total_views/1000,2),' ','K')
        													 	  ELSE
        													 	  		v.total_views
        													 	  END) as total_views,(CASE WHEN v.total_likes >= 1000000000
        													 			THEN concat(FORMAT(v.total_likes/1000000000,2),' ','B')
        													 	  WHEN v.total_likes >= 1000000
        													 	  		THEN concat(FORMAT(v.total_likes/1000000,2),' ','M')
        													 	  WHEN v.total_likes >= 1000
        													 	  		THEN concat(FORMAT(v.total_likes/1000,2),' ','K')
        													 	  ELSE
        													 	  		v.total_likes
        													 	  END) as total_likes"))
	        				->join("users as u","v.user_id","u.user_id")
	        				->leftJoin("sounds as s","s.sound_id","v.sound_id")
	        				->where("v.deleted",0)
	        				->where("v.user_id",$request->user_id)
	        				->where("v.enabled",1)
	        				->orderBy("v.video_id",'desc');
	        				
	        $userVideos = $userVideos->paginate($limit);
	        $totalVideos = $userVideos->total();
	        
	        $userRecord = DB::table('users')
            					->select(DB::raw("user_dp,user_id,fname,lname"))
            					->where('user_id',$request->user_id)
            					->first();
	        				
	        $name = $userRecord->fname." ".$userRecord->lname;
	        if(stripos($userRecord->user_dp,'https://')!==false){
                $file_path=$userRecord->user_dp;
                $small_file_path=$userRecord->user_dp;
            }else{
                $file_path = secure_asset(config('app.profile_path').$request->user_id."/".$userRecord->user_dp);
                 $small_file_path = secure_asset(config('app.profile_path').$request->user_id."/small/".$userRecord->user_dp);
            
                if($file_path==""){
                    $file_path=secure_asset(config('app.profile_path')).'default-user.png';
                }
                if($small_file_path==""){
                    $small_file_path=secure_asset(config('app.profile_path')).'default-user.png';
                }
            }
	        				
	        $userFollowers = DB::table("follow")
	        				->select(DB::raw("count(*) as totalFollowers"))
	        				->where("follow_to",$request->user_id)
	        				->first();
	        
	        $totalFollowers = '0';
	        if($userFollowers) {
	            $totalFollowers = Functions::digitsFormate($userFollowers->totalFollowers);
	        }
	        
	        $userFollowings = DB::table("follow")
	        				->select(DB::raw("count(*) as totalFollowing"))
	        				->where("follow_by",$request->user_id)
	        				->first();
	        				
	        $totalFollowing = '0';
	        if($userFollowings) {
	            $totalFollowing = Functions::digitsFormate($userFollowings->totalFollowing);
	        }
	        
	        $userVideosLikes = DB::table("videos")
	        				->select(DB::raw("ifnull(sum(total_likes),0) as totalVideosLike"))
	        				->where("deleted",0)
	        				->where("user_id",$request->user_id)
	        				->first();
	        
	        $totalVideosLike = 0;
	        if($userVideosLikes) {
	            $totalVideosLike = Functions::digitsFormate($userVideosLikes->totalVideosLike);    
	        }
	        
	        $followText = "Follow";
	        $blockText = "no";
	        if( isset($request->login_id) ) {
	            $checkFollowFolloing = DB::table("follow")
	        				->select(DB::raw("follow_id"))
	        				->where("follow_by",$request->login_id)
	        				->where("follow_to",$request->user_id)
	        				->first();
	        
    	        if($checkFollowFolloing) {
    	            $followText = "Following";
    	        }   
    	        
    	        $checkIsBloked = DB::table("blocked_users")
	        				->select(DB::raw("block_id"))
	        				->where("blocked_by",$request->login_id)
	        				->where("user_id",$request->user_id)
	        				->first();
	        	if($checkIsBloked) {
    	            $blockText = "yes";
    	        } 
	        }
	        
	        $response = array("status" => "success",'data' => $userVideos,'blocked'=>$blockText,'totalRecords'=>$totalVideos,'large_pic' => $file_path ,'small_pic' => $small_file_path,'name' => $name,'totalVideosLike'=>$totalVideosLike, 'totalFollowings' => $totalFollowing, 'totalFollowers' => $totalFollowers, 'followText' => $followText,'totalVideos'=>Functions::digitsFormate($totalVideos));
	        return response()->json($response); 	
        }
    }
    
    public function fetchLoginUserInformation(Request $request){
        $validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',
	        'app_token'        => 'required',
	    ],[ 
	        'user_id.required'      => 'User id is required',
	        'app_token.required'    => 'App Token is required',
	    ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
			$videoStoragePath  = secure_asset(config("app.video_path"));
	        $limit=9;
	        $userVideos = DB::table("videos as v")
	        				->select(DB::raw("video_id,case when v.user_id = 0  then concat('".$videoStoragePath."/',video) else concat('".$videoStoragePath."/',v.user_id,'/',video) end as video,case when thumb='' then '' else concat('".$videoStoragePath."/',v.user_id,'/thumb/',thumb) end as thumb,ifnull(case when gif='' then '' else concat('".$videoStoragePath."/',v.user_id,'/gif/',gif) end,'') as gif,ifnull(s.title,'') as sound_title,concat('@',u.username) as username,v.duration,v.user_id,v.tags,ifnull(v.created_at,'NA') as created_at,ifnull(v.updated_at,'NA') as updated_at,(CASE WHEN v.total_views >= 1000000000
        													 			THEN concat(FORMAT(v.total_views/1000000000,2),' ','B')
        													 	  WHEN v.total_views >= 1000000
        													 	  		THEN concat(FORMAT(v.total_views/1000000,2),' ','M')
        													 	  WHEN v.total_views >= 1000
        													 	  		THEN concat(FORMAT(v.total_views/1000,2),' ','K')
        													 	  ELSE
        													 	  		v.total_views
        													 	  END) as total_views,(CASE WHEN v.total_likes >= 1000000000
        													 			THEN concat(FORMAT(v.total_likes/1000000000,2),' ','B')
        													 	  WHEN v.total_likes >= 1000000
        													 	  		THEN concat(FORMAT(v.total_likes/1000000,2),' ','M')
        													 	  WHEN v.total_likes >= 1000
        													 	  		THEN concat(FORMAT(v.total_likes/1000,2),' ','K')
        													 	  ELSE
        													 	  		v.total_likes
        													 	  END) as total_likes"))
	        				->join("users as u","v.user_id","u.user_id")
	        				->leftJoin("sounds as s","s.sound_id","v.sound_id")
	        				->where("v.deleted",0)
	        				->where("v.user_id",$request->user_id)
	        				->where("v.enabled",1)
	        				->orderBy("v.video_id",'desc');
	        				
	        $userVideos = $userVideos->paginate($limit);
	        $totalVideos = $userVideos->total();
	        $userRecord = DB::table('users')
            					->select(DB::raw("user_dp,user_id,fname,lname"))
            					->where('user_id',$request->user_id)
            					->first();
	        				
	        $name = $userRecord->fname." ".$userRecord->lname;
	        if(stripos($userRecord->user_dp,'https://')!==false){
                $file_path=$userRecord->user_dp;
                $small_file_path=$userRecord->user_dp;
            }else{
                $file_path = secure_asset(config('app.profile_path').$request->user_id."/".$userRecord->user_dp);
                 $small_file_path = secure_asset(config('app.profile_path').$request->user_id."/small/".$userRecord->user_dp);
            
                if($file_path==""){
                    $file_path=secure_asset(config('app.profile_path')).'default-user.png';
                }
                if($small_file_path==""){
                    $small_file_path=secure_asset(config('app.profile_path')).'default-user.png';
                }
            }
	        				
	        $userFollowers = DB::table("follow")
	        				->select(DB::raw("count(*) as totalFollowers"))
	        				->where("follow_to",$request->user_id)
	        				->first();
	        
	        $totalFollowers = '0';
	        if($userFollowers) {
	            $totalFollowers = Functions::digitsFormate($userFollowers->totalFollowers);
	        }
	        
	        $userFollowings = DB::table("follow")
	        				->select(DB::raw("count(*) as totalFollowing"))
	        				->where("follow_by",$request->user_id)
	        				->first();
	        				
	        $totalFollowing = '0';
	        if($userFollowings) {
	            $totalFollowing = Functions::digitsFormate($userFollowings->totalFollowing);
	        }
	        
	        $userVideosLikes = DB::table("videos")
	        				->select(DB::raw("ifnull(sum(total_likes),0) as totalVideosLike"))
	        				->where("deleted",0)
	        				->where("user_id",$request->user_id)
	        				->first();
	        
	        $totalVideosLike = 0;
	        if($userVideosLikes) {
	            $totalVideosLike = Functions::digitsFormate($userVideosLikes->totalVideosLike);    
	        }
	        
	        $response = array("status" => "success",'data' => $userVideos,'totalRecords'=>$totalVideos,'large_pic' => $file_path ,'small_pic' => $small_file_path,'name' => $name,'totalVideosLike'=>$totalVideosLike, 'totalFollowings' => $totalFollowing, 'totalFollowers' => $totalFollowers,'totalVideos'=>Functions::digitsFormate($totalVideos));
	        return response()->json($response); 	
        }
    }
    
    public function followUnfollowUser(Request $request){
		$validator = Validator::make($request->all(), [ 
	            'follow_by'          => 'required',              
	            'app_token'        => 'required',
	            'follow_to'          => 'required'           
	        ],[ 
	            'follow_by.required'    => 'Follow by is required',
	            'app_token.required'    => 'App Token is required',
	            'follow_to.required'	=> 'Follow to is required',
	        ]);

       if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
            $token_res= $functions->validate_token($request->follow_by,$request->app_token);
			if($token_res>0) {
			    $followRecord = DB::table('follow')
                					->select(DB::raw("follow_id"))
                					->where('follow_by',$request->follow_by)
                					->where('follow_to',$request->follow_to)
                					->first();
                
                if($followRecord) {
                    DB::table('follow')->where('follow_id', $followRecord->follow_id)->delete();
                    $follow_text = "Follow";    
                } else {
                    $insertData = array();
					$insertData['follow_by'] = $request->follow_by;
					$insertData['follow_to'] = $request->follow_to;
					$insertData['follow_on'] = date("Y-m-d H:i:s");
					DB::table("follow")->insert($insertData);
					$follow_text = "Following";
                }	
                $userFollowers = DB::table("follow")
                			->select(DB::raw("count(*) as totalFollowers"))
                			->where("follow_to",$request->follow_to)
                			->first();
                
                $totalFollowers = '0';
                if($userFollowers) {
                    $totalFollowers = Functions::digitsFormate($userFollowers->totalFollowers);
                }
                
                $is_following_videos = 0;
                $followingVideos = DB::table("follow")
    		        						->select(DB::raw("follow_id"))
    		        						->where("follow_by",$request->follow_by)
    		        						->first(); 
                if($followingVideos) {
                    $is_following_videos = 1;
                }
                
    	        $userFollowersSql = DB::table("follow")
                    			->select(DB::raw("count(*) as totalFollowers"))
                    			->where("follow_to",$request->follow_by)
                    			->first();
	        
    	        $totalFollowersCount = '0';
    	        if($userFollowersSql) {
    	            $totalFollowersCount = Functions::digitsFormate($userFollowersSql->totalFollowers);
    	        }
    	        
    	        $userFollowingsSql = DB::table("follow")
    	        				->select(DB::raw("count(*) as totalFollowing"))
    	        				->where("follow_by",$request->follow_by)
    	        				->first();
    	        				
    	        $totalFollowingsCount = '0';
    	        if($userFollowingsSql) {
    	            $totalFollowingsCount = Functions::digitsFormate($userFollowingsSql->totalFollowing);
    	        }
                
			    $response = array("status" => "success",'followText'=>$follow_text,'totalFollowers'=>$totalFollowers, 'is_following_videos' => $is_following_videos,'total_followings' => $totalFollowingsCount, 'total_followers' => $totalFollowersCount);
			} else {
			    return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
			}   
            return response()->json($response); 
        }
    }
    
    public function FollowingUsersList(Request $request){
        $validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',
	        'app_token'        => 'required',
	    ],[ 
	        'user_id.required'      => 'User id is required',
	        'app_token.required'    => 'App Token is required',
	    ]);
     
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
            $token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0) {
			    $userDpPath = secure_asset(config('app.profile_path'));
                $limit = 10;
                $users = DB::table("users as u")->select(DB::raw("u.user_id,
                									case when u.user_dp !='' THEN case when INSTR(u.user_dp,'https://') > 0 THEN u.user_dp ELSE concat('".$userDpPath."/',u.user_id,'/small/',u.user_dp)  END ELSE '' END as user_dp,
                									concat('@',u.username) as username,u.fname,u.lname, case when f.follow_id > 0 THEN 'Following' ELSE 'Follow' END as followText"))
        											->join('follow as f', function ($join) use ($request){
        												$join->on('u.user_id','=','f.follow_to')
        												->where('f.follow_by',$request->user_id);
        											})
        											->where("u.deleted",0)
        											->where("u.active",1);
                
                if(isset($request->search) && $request->search!=""){
                    $search = $request->search;
                    $users = $users->where('u.username', 'like', '%' . $search . '%')->orWhere('u.fname', 'like', '%' . $search . '%')->orWhere('u.lname', 'like', '%' . $search . '%');
                }
                
                $users = $users->orderBy('u.user_id','desc');
                $users= $users->paginate($limit);
                $total_records=$users->total();   
        
                $response = array("status" => "success",'data' => $users,'total_records'=>$total_records);
			} else {
			     return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
			}
        } 
        return response()->json($response); 
    }
    
    public function submitReport(Request $request){
        $validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',
	        'app_token'        => 'required',
	        'video_id'        => 'required',
	    ],[ 
	        'user_id.required'      => 'User Id is required',
	        'app_token.required'    => 'App Token is required',
	        'video_id.required'    => 'Video Id is required',
	    ]);
     
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
            $token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0) {
                $insertData = array();
				$insertData['user_id'] = $request->user_id;
				$insertData['video_id'] = $request->video_id;
				$insertData['type'] = $request->type;
				$insertData['description'] = is_null($request->description) ? '' : $request->description;
				$insertData['report_on'] = date("Y-m-d H:i:s");
				DB::table("reports")->insert($insertData);
				
				$videoTotalReport = DB::table("videos")
    	        				->select(DB::raw("total_report"))
    	        				->where("video_id",$request->video_id)
    	        				->first();
    	        $total_report = 0;
    	        if($videoTotalReport) {
    	            $total_report = $videoTotalReport->total_report;
    	        }
    	        $total_report = $total_report + 1;
    	        DB::table("videos")->where('video_id',$request->video_id)->update(['total_report' => $total_report]);
                $response = array("status" => "success",'msg' => 'Thanks for reporting.If we find this content to be in violation of our Guidelines, we will remove it.');
			} else {
			     return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
			}
        } 
        return response()->json($response); 
    }
    
    public function deleteComment(Request $request){
        $validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',
	        'app_token'        => 'required',
	        'comment_id'        => 'required',
	        'video_id'        => 'required',
	    ],[ 
	        'user_id.required'      => 'User Id is required',
	        'app_token.required'    => 'App Token is required',
	        'comment_id.required'    => 'Comment Id is required',
	        'video_id.required'    => 'Video Id is required'
	    ]);
     
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
            $token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0) {
				DB::table('comments')->where('comment_id', $request->comment_id)->delete();
				$totalComments = DB::table("videos")
    	        				->select(DB::raw("total_comments"))
    	        				->where("video_id",$request->video_id)
    	        				->first();
    	        $total_comments = 0;
    	        if($totalComments) {
    	            $total_comments = $totalComments->total_comments;
    	        }
    	        $total_comments = $total_comments - 1;
    	        DB::table("videos")->where('video_id',$request->video_id)->update(['total_comments' => $total_comments]);
                $response = array("status" => "success",'total_comments'=>Functions::digitsFormate($total_comments));
			} else {
			     return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
			}
        } 
        return response()->json($response); 
    }
    
    public function FollowersList(Request $request){
        $validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',
	        'app_token'        => 'required',
	    ],[ 
	        'user_id.required'      => 'User id is required',
	        'app_token.required'    => 'App Token is required',
	    ]);
     
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
            $token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0) {
			    $userDpPath = secure_asset(config('app.profile_path'));
                $limit = 10;
                $users = DB::table("users as u")->select(DB::raw("u.user_id,
                									case when u.user_dp !='' THEN case when INSTR(u.user_dp,'https://') > 0 THEN u.user_dp ELSE concat('".$userDpPath."/',u.user_id,'/small/',u.user_dp)  END ELSE '' END as user_dp,
                									concat('@',u.username) as username,u.fname,u.lname, case when f2.follow_id > 0 THEN 'Following' ELSE 'Follow' END as followText"))
        											->join('follow as f', function ($join) use ($request){
        												$join->on('u.user_id','=','f.follow_by')
        												->where('f.follow_to',$request->user_id);
        											})
        											->leftJoin('follow as f2', function ($join) use ($request){
        												$join->on('u.user_id','=','f2.follow_to')
        												->where('f2.follow_by',$request->user_id);
        											})
        											->where("u.deleted",0)
        											->where("u.active",1);
                
                if(isset($request->search) && $request->search!=""){
                    $search = $request->search;
                    $users = $users->where('u.username', 'like', '%' . $search . '%')->orWhere('u.fname', 'like', '%' . $search . '%')->orWhere('u.lname', 'like', '%' . $search . '%');
                }
                
                $users = $users->orderBy('u.user_id','desc');
                $users= $users->paginate($limit);
                $total_records=$users->total();   
        
                $response = array("status" => "success",'data' => $users,'total_records'=>$total_records);
			} else {
			     return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
			}
        } 
        return response()->json($response); 
    }
    
    public function unique_user_id(){
        $characters = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	    $string     = "";

    	for($p = 0; $p < 15; $p++)
    	{
    		$string .= $characters[mt_rand(0, strlen($characters) - 1)];
        }
        
        $uniques_user_id_res = DB::table("unique_users_ids")->select("unique_token")->where('unique_token',$string)->first();
        if($uniques_user_id_res){
            $this->unique_user_id();
        }else{
            DB::table('unique_users_ids')->insert(['unique_token'=>$string]);   
        }
    
        $response = array("status" => "success" ,'unique_token' => $string);      
        return response()->json($response); 
    }
    
    public function blockUser(Request $request){
       $validator = Validator::make($request->all(), [ 
            'user_id'          => 'required',              
            'app_token'          => 'required',              
            'blocked_by'          => 'required',              
        ],[ 
            'user_id.required'   => 'User Id  is required.',
            'app_token.required'   => 'App Token  is required.',
            'blocked_by.required'   => 'Blocked By  is required.',
           
        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            $functions = new Functions();
            $token_res= $functions->validate_token($request->blocked_by,$request->app_token);
			if($token_res>0) {
                $res=DB::table('blocked_users')
                ->select(DB::raw('block_id'))
                ->where('user_id',$request->user_id)
                ->where('blocked_by',$request->blocked_by)
                ->get();
            if($res->isEmpty()){
        
                $data =array(
                    'user_id' => $request->user_id,
                    'blocked_by' => $request->blocked_by,
                    'blocked_on'  => date("Y-m-d H:i:s")                                                   
                ); 
                    DB::table('blocked_users')->insert($data);
                                
                    //followers
                    DB::table('follow')->where('follow_by', $request->user_id)->where('follow_to', $request->blocked_by)->delete();
                    DB::table('follow')->where('follow_to', $request->user_id)->where('follow_by', $request->blocked_by)->delete();
                    $response = array( "status" => "success", "msg" => "User blocked Successfully","block"=>'Unblocked');
                    
                //exit();
                }else{
                    DB::table('blocked_users')->where('user_id', $request->user_id)->where('blocked_by', $request->blocked_by)->delete();
                    $response = array( "status" => "success", "msg" => "User unblocked Successfully","block"=>'Block');
                }  
                return response()->json($response); 
            }else{
                return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
            }
        }
    }
}   