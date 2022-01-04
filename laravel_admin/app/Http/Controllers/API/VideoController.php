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
use FFMpeg\Format\Video\X264;
use ProtoneMedia\LaravelFFMpeg\Support\FFMpeg;
use ProtoneMedia\LaravelFFMpeg\Support\ServiceProvider;
use App\Jobs\ConvertVideoForStreaming;
use ProtoneMedia\LaravelFFMpeg\Filesystem\Media;
use Auth;
use Mail;
use Illuminate\Support\Facades\URL;
use FFMpeg\Filters\Video\VideoFilters; 
use FFMpeg as FFMpeg1;
use FFProbe as FFProbe1;
use GifCreator\GifCreator;
use FFMpeg\Coordinate\TimeCode;
use Intervention\Image\ImageManagerStatic as Image;
use Owenoj\LaravelGetId3\GetId3;

class VideoController extends Controller
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
        //DB::enableQueryLog(); 
        $userDpPath = secure_asset(config('app.profile_path'));
        $videoStoragePath  = secure_asset(config("app.video_path"));
        $page_size = isset($request->page_size) ? $request->page_size : 10;
        /*ifnull( case when INSTR(u.user_dp,'https://') > 0 THEN u.user_dp ELSE concat('".$userDpPath."/',s.user_id,'/small/',u.user_dp) END,'".secure_asset('imgs/music-icon.png')."') as sound_image_url*/
        $videos = DB::table("videos as v")->select(DB::raw("v.video_id,v.sound_id,'".secure_asset('imgs/music-icon.png')."' as sound_image_url,v.user_id,v.description,v.title,case when u.user_dp!='' THEN case when INSTR(u.user_dp,'https://') > 0 THEN u.user_dp ELSE concat('".$userDpPath."/',v.user_id,'/small/',u.user_dp) END ELSE '' END as user_dp ,case when v.master_video = ''  then concat('".$videoStoragePath."/',v.user_id,'/',video) else concat('".$videoStoragePath."/',v.user_id,'/',master_video) end as video,case when thumb='' then '' else concat('".$videoStoragePath."/',v.user_id,'/thumb/',thumb) end as thumb,case when gif='' then '' else concat('".$videoStoragePath."/',v.user_id,'/gif/',gif) end as gif,ifnull(s.title,'') as sound_title,concat('@',u.username) as username,
                                                            v.privacy,v.duration,v.user_id,v.tags,ifnull(v.created_at,'NA') as created_at,ifnull(v.updated_at,'NA') as updated_at,
                                                            ifnull(l.like_id,0) as like_id,f2.follow_id as isFollowing,
                                                            (CASE WHEN v.total_likes >= 1000000000
        													 			THEN concat(FORMAT(v.total_likes/1000000000,2),' ','B')
        													 	  WHEN v.total_likes >= 1000000
        													 	  		THEN concat(FORMAT(v.total_likes/1000000,2),' ','M')
        													 	  WHEN v.total_likes >= 1000
        													 	  		THEN concat(FORMAT(v.total_likes/1000,2),' ','K')
        													 	  ELSE
        													 	  		v.total_likes
        													 	  END) as total_likes,
        													 (CASE WHEN v.total_comments >= 1000000000
        													 			THEN concat(FORMAT(v.total_comments/1000000000,2),' ','B')
        													 	  WHEN v.total_comments >= 1000000
        													 	  		THEN concat(FORMAT(v.total_comments/1000000,2),' ','M')
        													 	  WHEN v.total_comments >= 1000
        													 	  		THEN concat(FORMAT(v.total_comments/1000,2),' ','K')
        													 	  ELSE
        													 	  		v.total_comments
        													 	  END) as total_comments "))
											->leftJoin("users as u","v.user_id","u.user_id")
											->leftJoin("sounds as s","s.sound_id","v.sound_id")
											->leftJoin('likes as l', function ($join)use ($request){
												$join->on('l.video_id','=','v.video_id')
													->where('l.user_id',$request->login_id);
												});
											if($request->user_id > 0  && $request->user_id == $request->login_id) {
											    //$videos = $videos->whereRaw(DB::raw("v.privacy=1")); 
											    $videos = $videos->where("v.user_id","=", $request->user_id); 
											} else {
											    $videos = $videos->where("v.privacy","<>", "1");    
											}
											
											$videos = $videos->where("v.deleted",0)
											->where("v.enabled",1)
											->where("v.total_report","<",50);
        if($request->following == 1) {
            $videos = $videos->join('follow as f', function ($join)use ($request){
												$join->on('f.follow_to','=','v.user_id')
													->where('f.follow_by',$request->login_id);
												});
        }
        
        if(isset($request->search) && $request->search!=""){
            $search = $request->search;
            $videos = $videos->whereRaw(DB::raw("((v.title like '%" . $search . "%') or (v.tags like '%" . $search . "%'))"));
            //where('v.title', 'like', '%' . $search . '%')->orWhere('v.tags', 'like', '%' . $search . '%')->orWhere('v.tags', 'like', '%' . $search . '%');
        }
        if(isset($request->user_id) && $request->user_id>0) {
            $videos = $videos->where('v.user_id',$request->user_id);        
        }
        if($request->video_id>0){
            $videos = $videos->orderBy(DB::raw('v.video_id='.$request->video_id),'desc');
            
        }
        
        $is_following_videos = 0;
        if($request->login_id > 0) {
            $videos = $videos->leftJoin('blocked_users as bu1', function ($join)use ($request){
    												$join->on('v.user_id','=','bu1.user_id');
    												$join->whereRaw(DB::raw(" ( bu1.blocked_by=".$request->login_id." OR bu1.user_id=".$request->login_id." )" ));
												});
												
            $videos = $videos->leftJoin('blocked_users as bu2', function ($join)use ($request){
    												$join->on('v.user_id','=','bu2.blocked_by');
    												$join->whereRaw(DB::raw(" ( bu2.blocked_by=".$request->login_id." OR bu2.user_id=".$request->login_id." )" ));
												});
            $videos = $videos->leftJoin('follow as f2', function ($join) use ($request){
        												$join->on('v.user_id','=','f2.follow_to')
        												->where('f2.follow_by',$request->login_id);
        											});
            $videos = $videos->whereRaw( DB::Raw(' bu1.block_id is null and bu2.block_id is null '));
            if($request->user_id != $request->login_id) {
                $videos = $videos->whereRaw( DB::Raw(' CASE WHEN (f2.follow_id is not null ) THEN (v.privacy=2 OR v.privacy=0) ELSE v.privacy=0 END '));
            }
            
            $login_id = $request->login_id;
            $followingVideos = DB::table("follow")
				        						->select(DB::raw("follow_id"))
				        						->where("follow_by",$request->login_id)
				        						->first(); 
            if($followingVideos) {
                $is_following_videos = 1;
            }
        }  else {
            $videos = $videos->leftJoin('follow as f2', function ($join) use ($request){
        												$join->on('v.user_id','=','f2.follow_to')
        												->where('f2.follow_by',$request->login_id);
        											});
            $videos = $videos->where("v.privacy","<>",2);        
        }
        
        
        $videos = $videos->orderBy("v.video_id","desc");
        $videos= $videos->paginate($page_size);
        //dd(DB::getQueryLog());
        $response = array("status" => "success",'data' => $videos, 'is_following_videos' => $is_following_videos);
        return response()->json($response); 
    }
    
    public function uploadVideo(Request $request){
        $validator = Validator::make($request->all(), [ 
            'user_id'          => 'required',              
            'app_token'          => 'required', 
            'description' => 'required', 
            'video'          => 'required|mimes:mp4,mov,ogg,qt',  
            'thumbnail_file' => 'required|image|mimes:jpeg,png,jpg,gif,svg', 
            'gif_file' => 'required|image|mimes:gif',
        ],[ 
            'user_id.required'   => 'User Id  is required.',
            'app_token.required'   => 'App Token is required.',
            'description.required'   => 'Description is required',
            'video.required'   => 'Video is required',
            'thumbnail_file.required'   => 'Thumbnail File is required',
            'gif_file.required'   => 'Gif File is required',
        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
        	$functions = new Functions();
			$token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0){
				//video file upload
				$videoPath = 'public/videos/'.$request->user_id;
				$videoFilePath = $request->file('video')->store($videoPath);            
	            Storage::setVisibility($videoFilePath, 'public');
	            $videoFileArray = explode('/',$videoFilePath);  
	            $videoFileName = array_pop($videoFileArray); 
	            $videoFileUrl = secure_asset(config('app.video_path').$request->user_id."/".$videoFileName);
	            
	            //thumb file upload
	            $thumbPath = 'public/videos/'.$request->user_id.'/thumb';
				$thumbFilePath = $request->file('thumbnail_file')->store($thumbPath);            
	            Storage::setVisibility($thumbFilePath, 'public');
	            $thumbFileArray = explode('/',$thumbFilePath);  
	            $thumbFileName = array_pop($thumbFileArray); 
	            $thumbFileUrl = secure_asset(config('app.video_path').$request->user_id."/thumb/".$thumbFileName);
	            
	            //gif file upload
	            $gifPath = 'public/videos/'.$request->user_id.'/gif';
				$gifFilePath = $request->file('gif_file')->store($gifPath);            
	            Storage::setVisibility($gifFilePath, 'public');
	            $gifFileArray = explode('/',$gifFilePath);  
	            $gifFileName = array_pop($gifFileArray); 
	            $gifFileUrl = secure_asset(config('app.video_path').$request->user_id."/gif/".$gifFileName);
	            $hashtags='';
	             if(isset($request->description)) {
	                if(stripos($request->description,'#')!==false) {
	                   $str = $request->description;
                        preg_match_all('/#([^\s]+)/', $str, $matches);
                        $hashtags = implode(',', $matches[1]);
	                }
	            }
	            
	            if($hashtags!='') {
	                $data['tags'] = $hashtags;
	            }
	            $data['user_id'] = $request->user_id;
	            $data['video'] = $videoFileName;
	            $data['thumb'] = $thumbFileName;
	            $data['gif'] = $gifFileName;
	            $data['description'] = $request->description;
	            $data['duration'] = 15;
	            $data['sound_id'] = $request->sound_id;
	            $data['created_at'] = date('Y-m-d H:i:s');
	            $data['updated_at'] = date('Y-m-d H:i:s');
	                
	            $video_id = DB::table('videos')->insertGetId($data);
	            $response = array("status" => "success",'msg'=>'Video uploaded successfully' , 'video' => $videoFileUrl,'thumb' => $thumbFileName,'gif' => $gifFileName);
	            return response()->json($response);
            
			}else{
	            return response()->json([
	                "status" => "error", "msg" => "Unauthorized user!"
	            ]);
            }
        }
    }
    
    
    
    public function videoLikes(Request $request){
    	$validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',              
	        'app_token'        => 'required',
	        'video_id'    => 'required'
	    ],[ 
	        'user_id.required'      => 'User Id is required',
	        'app_token.required'    => 'App Token is required',
	        'video_id.required'      => 'Video id is required',       
	    ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
        	$functions = new Functions();
			$token_res= $functions->validate_token($request->user_id,$request->app_token);
			$total_likes = 0;
			if($token_res>0){
				
				$fetchTotalVideoLikes = DB::table("videos")
				        						->select(DB::raw("total_likes"))
				        						->where("video_id",$request->video_id)
				        						->first();
				        						
				$total_likes = $fetchTotalVideoLikes->total_likes;
				$checkExistLike = DB::table("likes")
				        				->select("like_id")
				        				->where("user_id",$request->user_id)
				        				->where("video_id",$request->video_id)
				        				->first();
				if($checkExistLike) {
					DB::table('likes')->where('like_id', $checkExistLike->like_id)->delete();
					$total_likes = $total_likes - 1;
					$response = array("status" => "success",'is_like'=>0 , 'total_likes' => Functions::digitsFormate($total_likes));
				} else {
					$insertData = array();
					$insertData['user_id'] = $request->user_id;
					$insertData['video_id'] = $request->video_id;
					$insertData['liked_on'] = date("Y-m-d H:i:s");
					DB::table("likes")->insert($insertData);
					$total_likes = $total_likes + 1;
					$response = array("status" => "success",'is_like'=>1 , 'total_likes' => Functions::digitsFormate($total_likes));
				}
				DB::table("videos")->where('video_id',$request->video_id)->update(['total_likes' => $total_likes]);
				return response()->json($response);
			} else {
				return response()->json([
					"status" => "error", "msg" => "Unauthorized user!"
				]);
			}
        }
    }
    
    public function addComment(Request $request){
    	$validator = Validator::make($request->all(), [ 
	        'user_id'          => 'required',              
	        'app_token'        => 'required',
	        'video_id'    => 'required',
	        'comment' => 'required',
	    ],[ 
	        'user_id.required'      => 'User Id is required',
	        'app_token.required'    => 'App Token is required',
	        'video_id.required'      => 'Video id is required',
	        'comment.required'      => 'Comment is required',
	    ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
        	$functions = new Functions();
			$token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0){
			    
			    $fetchTotalVideoComments = DB::table("videos")
				        						->select(DB::raw("total_comments"))
				        						->where("video_id",$request->video_id)
				        						->first();
				        						
			    $total_comments = $fetchTotalVideoComments->total_comments;
			    $total_comments = $total_comments + 1;
			    $data = array();
			    $data['video_id'] = $request->video_id;
			    $data['user_id'] = $request->user_id;
			    $data['comment'] = $request->comment;
			    $data['added_on'] = date("Y-m-d H:i:s");
			    $data['updated_on'] = date("Y-m-d H:i:s");
			    DB::table("comments")->insertGetId($data);
			    DB::table("videos")->where('video_id',$request->video_id)->update(['total_comments' => $total_comments]);
			    $response = array("status" => "success", "total_comments" => Functions::digitsFormate($total_comments));
			} else {
			    return response()->json([
					"status" => "error", "msg" => "Unauthorized user!"
				]);
			}
			return response()->json($response);
        }
    }
    
    public function fetchVideoComments(Request $request){
    	$validator = Validator::make($request->all(), [ 
	        'video_id'    => 'required'
	    ],[ 
	        'video_id.required'      => 'Video id is required',       
	    ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
        	$functions = new Functions();
			$limit = 15;
			$comments = DB::table("comments as c")
        						->select(DB::raw("c.*,u.user_id,u.username,u.user_dp"))
        						->join("users as u","c.user_id","u.user_id")
        						->where("c.video_id",$request->video_id)
        						->where("c.active",1)
        						->orderBy("c.added_on","desc")
        						->paginate($limit);
			$total_records=$comments->total();        						
			$data= array();
			if(count($comments) > 0) {
				foreach($comments as $key => $comment) {
					$data[$key]['name'] = $comment->username;
					if(stripos($comment->user_dp,'https://')!==false){
		                $file_path=$comment->user_dp;
		            }else{
		                $file_path = secure_asset(config('app.profile_path').$comment->user_id."/small/".$comment->user_dp);
			            if($file_path==""){
			                $file_path=secure_asset(config('app.profile_path')).'default-user.png';
			            }
		            }
					$data[$key]['pic'] = $file_path;
					$data[$key]['comment'] = (strlen($comment->comment) > 100) ? substr($comment->comment,0,100).'..' : $comment->comment;
					$data[$key]['comment_id'] = $comment->comment_id;
					$data[$key]['user_id'] = $comment->user_id;
					$data[$key]['timing'] = Functions::time_elapsed_string($comment->added_on);
				}
			}
			$response = array("status" => "success", "data" => $data,'total_records'=>$total_records);
			return response()->json($response);
        }
    }
    
    public function uploadVideo2(Request $request){
    
        $validator = Validator::make($request->all(), [ 
            'user_id'          => 'required',              
            'app_token'          => 'required', 
            'video'          => 'required|mimes:mp4,mov,ogg,qt',  
        
        ],[ 
            'user_id.required'   => 'User Id  is required.',
            'app_token.required'   => 'App Token is required.',
            'video.required'   => 'Video is required',

        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
           
        	$functions = new Functions();
			$token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0){
               
                $time_folder=time();
                $videoPath = 'public/videos/'.$request->user_id;
			   
				$hashtags='';
	            if(isset($request->description)) {
	                if(stripos($request->description,'#')!==false) {
	                   $str = $request->description;

                        preg_match_all('/#([^\s]+)/', $str, $matches);
                        
                        $hashtags = implode(',', $matches[1]);
                        
                        //var_dump($hashtags);
                       
	                }else{
	                    $hashtags='';
	                }
				}

                $videoFileName=$request->file('video')->getClientOriginalName();
                $request->video->storeAs("public/videos/".$request->user_id, $videoFileName);
                $multiCurl = array();
            	// multi handle
            	$mh = curl_multi_init();
            
            	$mediaOpener = FFMpeg::open('public/videos/'.$request->user_id.'/'.$videoFileName);
            	$video_duration = $mediaOpener->getDurationInSeconds();
            	$pic_frames = array();
            	$secds = 0;
            	$nudity = array();
            	$images = [];
            	do{
            		
            		$pic_frames[] = $secds;
            		$secds = $secds+3;
            		
            	}while($secds<$video_duration);
                // dd($pic_frames);
            	foreach ($pic_frames as $key => $seconds) {
            		$mediaOpener = $mediaOpener->getFrameFromSeconds($seconds)
            		->export()
            		->save('public/videos/'.$request->user_id.'/'."thumb_{$key}.jpg");
            		$imgName = secure_url('storage/videos/'.$request->user_id.'/'. "thumb_{$key}.jpg");
            // 		echo $imgName."<br/>";
            		$images[] = storage_path('app/public/videos/'.$request->user_id.'/'."thumb_{$key}.jpg");
            		$fetchURL = 'http://api.rest7.com/v1/detect_nudity.php?url='.$imgName;
            // 		echo $fetchURL."<br>";
            		$multiCurl[$key] = curl_init();
            		curl_setopt($multiCurl[$key], CURLOPT_URL,$fetchURL);
            		curl_setopt($multiCurl[$key], CURLOPT_HEADER,0);
            		curl_setopt($multiCurl[$key], CURLOPT_RETURNTRANSFER,1);
            		curl_multi_add_handle($mh, $multiCurl[$key]);
            	}
            
            	$index=null;
            	do {
            		curl_multi_exec($mh,$index);
            	} while($index > 0);
            	// get content and remove handles
            	foreach($multiCurl as $k => $ch) {
            		$result = json_decode(curl_multi_getcontent($ch),true);
            
            		if($result['nudity']==true && $result['nudity_percentage']>=0.5){
            	   // 	print_r($result);
            			$nudity[] = $result['nudity_percentage'];
            // 		echo $images[$k];
            		    
            		}
            		unlink($images[$k]);
            		curl_multi_remove_handle($mh, $ch);
            	}
            	// close
            	curl_multi_close($mh);
            	
            	if(count($nudity)>0){
            	     $response = array("status" => "failed","msg"=>"Your video contains nudity and is flagged by our system. It can't be uploaded.");
                    return response()->json($response);
            	}
			    $sound_id=0;
				if($request->sound_id>0){
				    $sound_id=$request->sound_id;
				    DB::table("sounds")->where("sound_id",$sound_id)->update([
                      'used_times'=> DB::raw('used_times+1'), 
                    ]);
					$soundName = DB::table("sounds")
					->select(DB::raw("sound_name,user_id"))
					->where("sound_id",$request->sound_id)
					->first();
					
					$video_media = FFMpeg::open('public/videos/'.$request->user_id.'/'.$videoFileName);
					$video_duration = $video_media->getDurationInSeconds();
				
					 $soundPath = 'public/'. $soundName->sound_name;
					
				
					 if($soundName->user_id>0){
					    $soundPathFile = "app/public/sounds/".$soundName->user_id.'/';
					 }else{
						$soundPathFile = "app/public/sounds/";
					 }
					 

					$ffmpeg = FFMpeg1\FFMpeg::create();
					$audio = $ffmpeg->open(storage_path($soundPathFile.$soundName->sound_name));
					$audio->filters()->clip(FFMpeg1\Coordinate\TimeCode::fromSeconds(0), FFMpeg1\Coordinate\TimeCode::fromSeconds($video_duration));
					$audio_format =  new X264('aac', 'libx264');

				// Extract the audio into a new file as mp3
					$audio->save($audio_format, 'storage/'. $soundName->sound_name);
					FFMpeg::fromDisk('local')
							->open([$videoPath.'/'.$videoFileName, $soundPath])
							->export()
							->addFormatOutputMapping(new X264('libmp3lame', 'libx264'), Media::make('local', 'public/videos/'.$request->user_id.'/'.$time_folder.'/'.$videoFileName), ['0:v', '1:a'])
							->save();

					unlink(storage_path()."/app/public/".$soundName->sound_name);	
				// 	 $soundPath = 'public/sounds/';
				// 	 if($soundName->user_id>0){
				// 	    $soundPath .= $soundName->user_id.'/';
				// 	 }
				// 	 $soundPath .= $soundName->sound_name;
					 
				// 	FFMpeg::fromDisk('local')
				// 			->open([$videoPath.'/'.$videoFileName, $soundPath])
				// 			->export()
				// 			->addFormatOutputMapping(new X264('libmp3lame', 'libx264'), Media::make('local', 'public/videos/'.$request->user_id.'/'.$time_folder.'/'.$videoFileName), ['0:v', '1:a'])
				// 			->save();
	

				}else{
					$format = new X264('aac', 'libx264');
					
					FFMpeg::fromDisk('local')
							->open($videoPath.'/'.$videoFileName)
							->export()
							->toDisk('local')
							->inFormat($format)
							//->inFormat(new \FFMpeg\Format\Audio\Aac)
							->save('public/sounds/'.$request->user_id.'/'.$time_folder.'.aac');
					
						$audio_media = FFMpeg::open('public/sounds/'.$request->user_id.'/'.$time_folder.'.aac');

						$audio_duration = $audio_media->getDurationInSeconds();
						
						$track = new GetId3($request->file('video'));
                        $title=$track->getTitle();
                        $album=$track->getAlbum();
						$artist=$track->getArtist();
							
						$audioData = array(
							'user_id' => $request->user_id,
							'cat_id' => 0,
							'title' 	=> ($title!=null) ? $title : "",
							'album' 	=> ($album!=null) ? $album : "",
							'artist' 	=> ($artist!=null) ? $artist : "",
							'sound_name' => $time_folder.'.aac',
							'tags'     => $hashtags,
							'duration' =>$audio_duration,
							'used_times' =>1,
							'created_at' => date('Y-m-d H:i:s')
						); 
						
						$s_id=DB::table('sounds')->insertGetId($audioData);
						$sound_id=$s_id;
					$videoFileName=$request->file('video')->getClientOriginalName();
                	$request->video->storeAs("public/videos/".$request->user_id.'/'.$time_folder, $videoFileName);
				}
				
				$file_path= "public/videos/".$request->user_id.'/'. $time_folder.'/'.$videoFileName;
                $c_path=  $this->getCleanFileName($time_folder.'/master.m3u8');
			
                
				FFMpeg::fromDisk('local')
						->open($videoPath.'/'.$videoFileName)
						->getFrameFromSeconds(0)
						->export()
						->toDisk('local')
						->save('public/videos/'.$request->user_id.'/thumb/'.$time_folder.'.jpg');
				
				 $v_path=storage_path("app/public/videos/".$request->user_id.'/'.$videoFileName);
				
				 $gif_path=storage_path("app/public/videos/".$request->user_id."/gif");
                 $gif_storage_path=$gif_path.'/'.$time_folder.'.gif';
				

                $media = FFMpeg::open('public/videos/'.$request->user_id.'/'.$videoFileName);
				$duration = $media->getDurationInSeconds();
				
				$ffmpeg = FFMpeg1\FFMpeg::create();
    			$video = $ffmpeg->open($v_path);

				// This array holds our "points" that we are going to extract from the
				// video. Each one represents a percentage into the video we will go in
				// extracitng a frame. 0%, 10%, 20% ..
				$points = range(0,100,50);
				//dd($points);
				$temp = storage_path() . "/thumb";
				// This will hold our finished frames.
				$frames = [];

				foreach ($points as $point) {

					// Point is a percent, so get the actual seconds into the video.
					$time_secs = floor($duration * ($point / 100));

					// Created a var to hold the point filename.
					$point_file = "$temp/$point.jpg";

					// Extract the frame.
					$frame = $video->frame(TimeCode::fromSeconds($time_secs));
					$frame->save($point_file);

					// If the frame was successfully extracted, resize it down to
					// 320x200 keeping aspect ratio.
					if (file_exists($point_file)) {
						$img = Image::make($point_file)->resize(400, 300, function ($constraint) {
							$constraint->aspectRatio();
							$constraint->upsize();
						});

						$img->save($point_file, 40);
						$img->destroy();
					}

					// If the resize was successful, add it to the frames array.
					if (file_exists($point_file)) {
						$frames[] = $point_file;
					}
				}

				// If we have frames that were successfully extracted.
				if (!empty($frames)) {

					// We show each frame for 100 ms.
					$durations = array_fill(0, count($frames), 25);

					// Create a new GIF and save it.
					$gc = new GifCreator();
					$gc->create($frames, $durations, 0);
					file_put_contents($gif_storage_path, $gc->getGif());

					// Remove all the temporary frames.
					foreach ($frames as $file) {
						unlink($file);
					}
				}
				unlink(storage_path()."/app/public/videos/".$request->user_id.'/'.$videoFileName);
				
                $data =array(
	                'user_id'       => $request->user_id,
	                'video'         => $time_folder.'/'.$videoFileName,
	                'thumb'         => $time_folder.'.jpg',
	                'gif'         => $time_folder.'.gif',
	                //'title' => ($request->title==null)?'' : $request->title,
	                'description' => ($request->description==null)? '' : $request->description,
	                'duration'    => $duration,
					'sound_id'     => $sound_id,
					'tags'      => $hashtags,
	                'created_at' => date('Y-m-d H:i:s'),
	                'updated_at' => date('Y-m-d H:i:s')
	            );
	           
                $v_id=DB::table('videos')->insertGetId($data);  
                $video = array(
                    'disk'          => 'local',
                    'original_name' => $request->video->getClientOriginalName(),
                    'path'          => $file_path,
                    'c_path'        => $c_path,
                    'title'         => $request->title,
                    'video_id'      => $v_id,
                    'user_id'       => $request->user_id
                );
                
                ConvertVideoForStreaming::dispatch($video);
                FFMpeg::cleanupTemporaryFiles();
                // $data =array(
                //     'master_video' => $c_path,
                //     'updated_at' => date('Y-m-d H:i:s')
                // );
                // DB::table('videos')->where('video_id',$v_id)->update($data);
                $full_video_path=secure_url('storage/videos/'.$request->user_id.'/'. $time_folder.'/'.$videoFileName);
                $full_thumb_path=secure_url('storage/videos/'.$request->user_id.'/thumb/'. $time_folder.'.jpg');
                $response = array("status" => "success",'msg'=>'Your video will be available shortly after we process it','file_path'=>$full_video_path,'video_id'=>$v_id,'thumb_path'=>$full_thumb_path);
                return response()->json($response);
            }
        }
    }
    
    public function filterUploadVideo(Request $request){
        
        $validator = Validator::make($request->all(), [
            'user_id'          => 'required',              
            'app_token'          => 'required', 
            'video'          => 'required|mimes:mp4,mov,ogg,qt',  
        
        ],[
            'user_id.required'   => 'User Id  is required.',
            'app_token.required'   => 'App Token is required.',
            'video.required'   => 'Video is required',

        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
       
        	$functions = new Functions();
			$token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0){
               
                $time_folder=time();
                $videoPath = 'public/videos/'.$request->user_id;
			   
				$hashtags='';
	            if(isset($request->description)) {
	                if(stripos($request->description,'#')!==false) {
	                   $str = $request->description;

                        preg_match_all('/#([^\s]+)/', $str, $matches);
                        
                        $hashtags = implode(',', $matches[1]);
                        
                        //var_dump($hashtags);
                       
	                }else{
	                    $hashtags='';
	                }
				}

                $videoFileName=$request->file('video')->getClientOriginalName();
                $request->video->storeAs("public/videos/".$request->user_id, $videoFileName);
                $multiCurl = array();
            	// multi handle
            	$mh = curl_multi_init();
            
            	$mediaOpener = FFMpeg::open('public/videos/'.$request->user_id.'/'.$videoFileName);
            	$video_duration = $mediaOpener->getDurationInSeconds();
            	$pic_frames = array();
            	$secds = 0;
            	$nudity = array();
            	$images = [];
            	do{
            		
            		$pic_frames[] = $secds;
            		$secds = $secds+3;
            		
            	}while($secds<$video_duration);
                // dd($pic_frames);
            	foreach ($pic_frames as $key => $seconds) {
            		$mediaOpener = $mediaOpener->getFrameFromSeconds($seconds)
            		->export()
            		->save('public/videos/'.$request->user_id.'/'."thumb_{$key}.jpg");
            		$imgName = secure_url('storage/videos/'.$request->user_id.'/'. "thumb_{$key}.jpg");
            		echo $imgName."<br/>";
            		$images[] = storage_path('app/public/videos/'.$request->user_id.'/'."thumb_{$key}.jpg");
            		$fetchURL = 'http://api.rest7.com/v1/detect_nudity.php?url='.$imgName;
            // 		echo $fetchURL."<br>";
            		$multiCurl[$key] = curl_init();
            		curl_setopt($multiCurl[$key], CURLOPT_URL,$fetchURL);
            		curl_setopt($multiCurl[$key], CURLOPT_HEADER,0);
            		curl_setopt($multiCurl[$key], CURLOPT_RETURNTRANSFER,1);
            		curl_multi_add_handle($mh, $multiCurl[$key]);
            	}
            
            	$index=null;
            	do {
            		curl_multi_exec($mh,$index);
            	} while($index > 0);
            	// get content and remove handles
            	foreach($multiCurl as $k => $ch) {
            		$result = json_decode(curl_multi_getcontent($ch),true);
                    print_r($result);
            		if($result['nudity']==true && $result['nudity_percentage']>=0.65){
            	    	print_r($result);
            			$nudity[] = $result['nudity_percentage'];
            // 		echo $images[$k];
            		    
            		}
                    
            		unlink($images[$k]);
            		curl_multi_remove_handle($mh, $ch);
            	}
            	// close
            	curl_multi_close($mh);
            	
            	if(count($nudity)>0){
            	     $response = array("status" => "failed","msg"=>"Your video contains nudity and is flagged by our system. It can't be uploaded.");
                    return response()->json($response);
            	}
			    $sound_id=0;
				if($request->sound_id>0){
				    $sound_id=$request->sound_id;
				    DB::table("sounds")->where("sound_id",$sound_id)->update([
                      'used_times'=> DB::raw('used_times+1'), 
                    ]);
					$soundName = DB::table("sounds")
					->select(DB::raw("sound_name,user_id"))
					->where("sound_id",$request->sound_id)
					->first();
					
					$video_media = FFMpeg::open('public/videos/'.$request->user_id.'/'.$videoFileName);
					$video_duration = $video_media->getDurationInSeconds();
				
					 $soundPath = 'public/'. $soundName->sound_name;
					
				
					 if($soundName->user_id>0){
					    $soundPathFile = "app/public/sounds/".$soundName->user_id.'/';
					 }else{
						$soundPathFile = "app/public/sounds/";
					 }
					 

					$ffmpeg = FFMpeg1\FFMpeg::create();
					$audio = $ffmpeg->open(storage_path($soundPathFile.$soundName->sound_name));
					$audio->filters()->clip(FFMpeg1\Coordinate\TimeCode::fromSeconds(0), FFMpeg1\Coordinate\TimeCode::fromSeconds($video_duration));
					$audio_format =  new X264('aac', 'libx264');

				// Extract the audio into a new file as mp3
					$audio->save($audio_format, 'storage/'. $soundName->sound_name);
					FFMpeg::fromDisk('local')
							->open([$videoPath.'/'.$videoFileName, $soundPath])
							->export()
							->addFormatOutputMapping(new X264('libmp3lame', 'libx264'), Media::make('local', 'public/videos/'.$request->user_id.'/'.$time_folder.'/'.$videoFileName), ['0:v', '1:a'])
							->save();

					unlink(storage_path()."/app/public/".$soundName->sound_name);	
				// 	 $soundPath = 'public/sounds/';
				// 	 if($soundName->user_id>0){
				// 	    $soundPath .= $soundName->user_id.'/';
				// 	 }
				// 	 $soundPath .= $soundName->sound_name;
					 
				// 	FFMpeg::fromDisk('local')
				// 			->open([$videoPath.'/'.$videoFileName, $soundPath])
				// 			->export()
				// 			->addFormatOutputMapping(new X264('libmp3lame', 'libx264'), Media::make('local', 'public/videos/'.$request->user_id.'/'.$time_folder.'/'.$videoFileName), ['0:v', '1:a'])
				// 			->save();
	

				}else{
					$format = new X264('aac', 'libx264');
					
					FFMpeg::fromDisk('local')
							->open($videoPath.'/'.$videoFileName)
							->export()
							->toDisk('local')
							->inFormat($format)
							//->inFormat(new \FFMpeg\Format\Audio\Aac)
							->save('public/sounds/'.$request->user_id.'/'.$time_folder.'.aac');
					
						$audio_media = FFMpeg::open('public/sounds/'.$request->user_id.'/'.$time_folder.'.aac');

						$audio_duration = $audio_media->getDurationInSeconds();
						
						$track = new GetId3($request->file('video'));
                        $title=$track->getTitle();
                        $album=$track->getAlbum();
						$artist=$track->getArtist();
							
						$audioData = array(
							'user_id' => $request->user_id,
							'cat_id' => 0,
							'title' 	=> ($title!=null) ? $title : "",
							'album' 	=> ($album!=null) ? $album : "",
							'artist' 	=> ($artist!=null) ? $artist : "",
							'sound_name' => $time_folder.'.aac',
							'tags'     => $hashtags,
							'duration' =>$audio_duration,
							'used_times' =>1,
							'created_at' => date('Y-m-d H:i:s')
						); 
						
						$s_id=DB::table('sounds')->insertGetId($audioData);
						$sound_id=$s_id;
					$videoFileName=$request->file('video')->getClientOriginalName();
                	$request->video->storeAs("public/videos/".$request->user_id.'/'.$time_folder, $videoFileName);
				}
				
				$file_path= "public/videos/".$request->user_id.'/'. $time_folder.'/'.$videoFileName;
                $c_path=  $this->getCleanFileName($time_folder.'/master.m3u8');
			
                
				FFMpeg::fromDisk('local')
						->open($videoPath.'/'.$videoFileName)
						->getFrameFromSeconds(0)
						->export()
						->toDisk('local')
						->save('public/videos/'.$request->user_id.'/thumb/'.$time_folder.'.jpg');
				
				 $v_path=storage_path("app/public/videos/".$request->user_id.'/'.$videoFileName);
				
				 $gif_path=storage_path("app/public/videos/".$request->user_id."/gif");
                 $gif_storage_path=$gif_path.'/'.$time_folder.'.gif';
				

                $media = FFMpeg::open('public/videos/'.$request->user_id.'/'.$videoFileName);
				$duration = $media->getDurationInSeconds();
				
				$ffmpeg = FFMpeg1\FFMpeg::create();
    			$video = $ffmpeg->open($v_path);

				// This array holds our "points" that we are going to extract from the
				// video. Each one represents a percentage into the video we will go in
				// extracitng a frame. 0%, 10%, 20% ..
				$points = range(0,100,50);
				//dd($points);
				$temp = storage_path() . "/thumb";
				// This will hold our finished frames.
				$frames = [];

				foreach ($points as $point) {

					// Point is a percent, so get the actual seconds into the video.
					$time_secs = floor($duration * ($point / 100));

					// Created a var to hold the point filename.
					$point_file = "$temp/$point.jpg";

					// Extract the frame.
					$frame = $video->frame(TimeCode::fromSeconds($time_secs));
					$frame->save($point_file);

					// If the frame was successfully extracted, resize it down to
					// 320x200 keeping aspect ratio.
					if (file_exists($point_file)) {
						$img = Image::make($point_file)->resize(400, 300, function ($constraint) {
							$constraint->aspectRatio();
							$constraint->upsize();
						});

						$img->save($point_file, 40);
						$img->destroy();
					}

					// If the resize was successful, add it to the frames array.
					if (file_exists($point_file)) {
						$frames[] = $point_file;
					}
				}

				// If we have frames that were successfully extracted.
				if (!empty($frames)) {

					// We show each frame for 100 ms.
					$durations = array_fill(0, count($frames), 25);

					// Create a new GIF and save it.
					$gc = new GifCreator();
					$gc->create($frames, $durations, 0);
					file_put_contents($gif_storage_path, $gc->getGif());

					// Remove all the temporary frames.
					foreach ($frames as $file) {
						unlink($file);
					}
				}
				unlink(storage_path()."/app/public/videos/".$request->user_id.'/'.$videoFileName);
				
                $data = array(
	                'user_id'     => $request->user_id,
	                'video'       => $time_folder.'/'.$videoFileName,
	                'thumb'       => $time_folder.'.jpg',
	                'gif'         => $time_folder.'.gif',
	                //'title' => ($request->title==null) ? '' : $request->title,
	                'description' => ($request->description==null)? '' : $request->description,
	                'duration'    => $duration,
					'sound_id'    => $sound_id,
					'tags'        => $hashtags,
	                'created_at'  => date('Y-m-d H:i:s'),
	                'updated_at'  => date('Y-m-d H:i:s')
	            );
	           
                $v_id = DB::table('videos')->insertGetId($data);
                
                $video = array(
                    'disk'          => 'local',
                    'original_name' => $request->video->getClientOriginalName(),
                    'path'          => $file_path,
                    'c_path'        => $c_path,
                    'title'         => $request->title,
                    'video_id'      => $v_id,
                    'user_id'       => $request->user_id
                );
                
                ConvertVideoForStreaming::dispatch($video);
                
                FFMpeg::cleanupTemporaryFiles();
                // $data =array(
                //     'master_video' => $c_path,
                //     'updated_at' => date('Y-m-d H:i:s')
                // );
                // DB::table('videos')->where('video_id',$v_id)->update($data);
                $full_video_path=secure_url('storage/videos/'.$request->user_id.'/'. $time_folder.'/'.$videoFileName);
                $full_thumb_path=secure_url('storage/videos/'.$request->user_id.'/thumb/'. $time_folder.'.jpg');
                $response = array("status" => "success",'msg'=>'Your video will be available shortly after we process it','file_path'=>$full_video_path,'video_id'=>$v_id,'thumb_path'=>$full_thumb_path);
                return response()->json($response);
            }
        }
    }
    
    
     private function getCleanFileName($filename){
        return preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename) . '.m3u8';
    }
    
    public function hashTagVideos(Request $request){
     
        $userDpPath = secure_asset(config('app.profile_path'));
        $videoStoragePath  = secure_asset(config("app.video_path"));
        $limit = 9;
        $videos = DB::table("videos as v")->select(DB::raw("v.video_id, case when u.user_dp!='' THEN case when INSTR(u.user_dp,'https://') > 0 THEN u.user_dp ELSE concat('".$userDpPath."/',v.user_id,'/small/',u.user_dp) END ELSE '' END as user_dp,ifnull(case when gif='' then '' else concat('".$videoStoragePath."/',v.user_id,'/gif/',gif) end,'') as gif,concat('@',u.username) as username,
                                                            v.tags"))
											->join("users as u","v.user_id","u.user_id")
											->where("v.deleted",0)
											->where("v.enabled",1)
											->where("v.user_id",'<>',$request->user_id);
        
       if($request->user_id > 0) {
            $videos = $videos->leftJoin('blocked_users as bu', function ($join)use ($request){
												$join->on('v.user_id','=','bu.user_id')->orOn('v.user_id','=','bu.blocked_by')
													->whereRaw(DB::raw(" (bu.blocked_by=".$request->user_id." OR bu.user_id=".$request->user_id.")" ));
												});
			$videos = $videos->whereRaw( DB::Raw(' bu.block_id is null '));									
       }
        if(isset($request->search) && $request->search!=""){
            $search = $request->search;
            $videos = $videos->whereRaw(DB::raw("((v.title like '%" . $search . "%') or (v.tags like '%" . $search . "%') or (concat('@',u.username) like '%" . $search . "%') or (u.fname like '%" . $search . "%') or (u.lname like '%" . $search . "%') or (v.description like '%" . $search . "%'))"));
        }
        $videos = $videos->orderBy("v.video_id","desc");
        $videos= $videos->paginate($limit);
        $total_records=$videos->total();   
        
        $tagBannersPath = secure_asset(config('app.tag_banners'));
        $videoTagBanners = DB::table("video_tags")
        						->select(DB::raw("tag_id,tag as tag_name,concat('".$tagBannersPath."/',banner) as banner"))
        						->orderBy("tag_id","desc")
        						->get();
        
        $videoTagBannersData = array();
        if( count($videoTagBanners) > 0 ) {
            foreach($videoTagBanners as $key=>$value) {
                $videoTagBannersData[$key]['tag_id'] = $value->tag_id;
                $videoTagBannersData[$key]['tag'] = $value->tag_name;
                $videoTagBannersData[$key]['banner'] = $value->banner;
            }
        }
        $response = array("status" => "success",'data' => $videos,'total_records'=>$total_records,'tagBanners' => $videoTagBannersData);
        return response()->json($response); 
        
    }
    
    public function mostViewedVideoUsers(Request $request){
        
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
                $videoStoragePath  = secure_asset(config("app.video_path"));
                $limit = 15;
                $users = DB::table("users as u")->select(DB::raw("u.user_id,max(v.video_id) as video_id,
                									case when u.user_dp !='' THEN case when INSTR(u.user_dp,'https://') > 0 THEN u.user_dp ELSE concat('".$userDpPath."/',v.user_id,'/small/',u.user_dp)  END ELSE '' END as user_dp,
                									ifnull(case when max(gif)='' then '' else concat('".$videoStoragePath."/',v.user_id,'/gif/',max(gif)) end,'') as gif,
                									concat('@',u.username) as username, case when f.follow_id > 0 THEN 'Following' ELSE 'Follow' END as followText"))
        											->join('videos as v', function ($join) use ($request){
        												$join->on('v.user_id','=','u.user_id')
        												->orderBy('max(v.total_views)')
        												->limit(1);
        											})
        											->leftJoin('follow as f', function ($join) use ($request){
        												$join->on('u.user_id','=','f.follow_to')
        												->where('f.follow_by',$request->user_id);
        											})
        											->where("v.deleted",0)
        											->where("v.enabled",1)
        											->where("u.deleted",0)
        											->where("u.active",1)
        											->where("u.user_id",'<>',$request->user_id)
        											->where("f.follow_id",null)
        											->groupBY("u.user_id","f.follow_id");
                
                if(isset($request->search) && $request->search!=""){
                    $search = $request->search;
                    $users = $users->whereRaw(DB::raw("((v.title like '%" . $search . "%') or (v.tags like '%" . $search . "%') or (u.username like '%" . $search . "%') or (u.fname like '%" . $search . "%') or (u.lname like '%" . $search . "%'))"));
                    //where('v.title', 'like', '%' . $search . '%')->orWhere('v.tags', 'like', '%' . $search . '%')->orWhere('v.tags', 'like', '%' . $search . '%')->orWhere('u.username', 'like', '%' . $search . '%')->orWhere('u.fname', 'like', '%' . $search . '%')->orWhere('u.lname', 'like', '%' . $search . '%');
                }
                
                $users = $users->orderBy("u.user_id","desc");
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
    
    public function video_enabled(Request $request){
        $validator = Validator::make($request->all(), [ 
			'video_id'          => 'required',
			'description'    => 'required'
        ],[  
            'video_id.required'   => 'Video Id is required',
            'description.required'   => 'Description is required',
        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
		}else{
		        $hashtags='';
		        $title='';
		        $users_res = DB::table("users as u")
								->select(DB::raw("u.username as username,v.sound_id as sound_id"))
								->join("videos as v","v.user_id","u.user_id")
								->where('v.video_id',$request->video_id)
								->first();
				$sound_res = DB::table("sounds")
								->select(DB::raw("sound_id,cat_id"))
								->where('sound_id',$users_res->sound_id)
								->first();
				
	            if(isset($request->description)) {
	                if(stripos($request->description,'#')!==false) {
	                   $str = $request->description;

                        preg_match_all('/#([^\s]+)/', $str, $matches);
                        
                        $hashtags = implode(',', $matches[1]);
                         $title = implode('-', $matches[1]);
                        //var_dump($hashtags);
                       
	                }else{
	                    $hashtags='';
	                    if(stripos($request->description,' ')!==false) {
							$desc=explode(' ',$request->description);
					
							$title=$desc[0].'-'.$desc[1];
						}
						else{
							$title=$request->description;
						}
	                }
	            }
	         	$title=$users_res->username.'-'.$title;
				 if( $sound_res->cat_id==0 ){
					$audio['tags'] = $hashtags;
					$audio['title'] = $title;
					DB::table("sounds")->where('sound_id',$users_res->sound_id)->update($audio);
				}
	        
	            $data['tags'] = $hashtags;
	            $data['title'] = $title;
	            $data['enabled'] = '1';
	            $data['description'] = $request->description;
	            $data['privacy'] = $request->privacy;
			DB::table("videos")->where('video_id',$request->video_id)->update($data);
			$response = array("status" => "success",'msg'=> 'Video enabled Successfully.');
            return response()->json($response);
		}
	}
	
	public function deleteVideo(Request $request){
	   // print_r($request->all());
	   // exit;
        $validator = Validator::make($request->all(), [ 
			'video_id'          => 'required',
			'user_id'    => 'required'
        ],[  
            'video_id.required'   => 'Video Id is required',
            'user_id.required'   => 'User Id is required',
        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
		}else{
		    $functions = new Functions();
            $token_res= $functions->validate_token($request->user_id,$request->app_token);
			if($token_res>0) {
    	        $data['deleted'] = '1';
    	   		DB::table("videos")->where('video_id',$request->video_id)->update($data);
    			$response = array("status" => "success",'msg'=> 'Video deleted Successfully.');
    			
                return response()->json($response);
    		}else{
    		    $response = array("status" => "Failed",'msg'=> 'App Token Not Verify');
    		    return response()->json();
    		}
		}
	}
	
	public function video_views(Request $request){
        $validator = Validator::make($request->all(), [ 
            'video_id'          => 'required', 
        ],[ 
            'video_id.required'   => 'Video Id is required',
        ]);

		if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
            if($request->unique_token){
                $unique_res = DB::table('unique_users_ids')
				->select(DB::raw('unique_id'))
				->where('unique_token',$request->unique_token)
				->first();
				$unique_id=$unique_res->unique_id;
            }else{
                $unique_id=0;
            }
            //DB::enableQueryLog(); 	
// 			$check_view = DB::table('video_views')
// 					->select(DB::raw('view_id'))
// 					->where('video_id',$request->video_id)
// 					->where(DB::raw('(user_id='.$request->user_id.' or unique_id='.$unique_id.')'))
// 					->whereDate('viewed_on','=',date('Y-m-d'))
// 					->first(); 
            $check_view =DB::select("select view_id from `video_views` where `video_id` = $request->video_id and (user_id=$request->user_id or unique_id=$unique_id) and
            DATE(`viewed_on`) = '".date('Y-m-d')."' limit 1");
			//dd($check_view);
			$views=0;
			$views_res = DB::table('videos')
				->select(DB::raw('total_views'))
				->where('video_id',$request->video_id)
				->first();
				
			$views=$views_res->total_views;
			
			if(empty($check_view)){
				DB::table('video_views')->insert(['user_id' => $request->user_id,'video_id'=>$request->video_id,'viewed_on'=>date('Y-m-d H:i:s'),'unique_id'=>$unique_id]);
				$views=$views+1;
				DB::table('videos')->where('video_id',$request->video_id)->update(['total_views' => $views]);
			}
             // dd(DB::getQueryLog()); 
			$response = array("status" => "success",'total_views'=> $views);
			return response()->json($response);
         
        }
	}
	
	
}   