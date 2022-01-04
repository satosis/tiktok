<?php 
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class IndexController extends Controller
{
   public function index(Request $request){
        return '<script>
        (function() {
          var app = {
            launchApp: function() {
              window.location.replace("/open-app");
              this.timer = setTimeout(this.openWebApp, 100);
            },
        
            openWebApp: function() {
              window.location.replace("market://details?id=com.bidnite.android");
            }
          };
        
          app.launchApp();
        })();
        </script>';
    } 
    
    
    public function showVideo(Request $request){
        
        $video_de=base64_decode($request->video_id);
       
        $video_id=str_ireplace("yfmtythd84n4h","",$video_de);
		$video_res = DB::table('videos as v')
                        ->select(DB::raw('v.video,v.thumb,v.user_id,u.username,v.title,v.description'))
                        ->leftJoin('users as u', 'u.user_id', '=', 'v.user_id')
                        ->where('video_id',$video_id)
						   ->first();
						   if($video_res){
						       $video=$video_res->video;
    						   $thumb=$video_res->thumb; 
    						   $user_id=$video_res->user_id; 
    						   $title=$video_res->title; 
    						   $description=$video_res->description;
    						   $username=$video_res->username; 
                            return view('show-video',compact('video','thumb','user_id','username','description','title'));
						   }
						   
	}
    
}