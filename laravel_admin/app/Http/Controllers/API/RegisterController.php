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

use Auth;
use Mail;
use Illuminate\Support\Facades\URL; 

class RegisterController extends Controller
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
        $before_date = date('Y-m-d', strtotime('-13 years'));
     
        $validator = Validator::make($request->all(), [ 
            'email'          => 'required_without:mobile|sometimes|nullable|email',
            'mobile'         => 'required_without:email',
            // 'dob'            => 'required|before_or_equal:'.$before_date,                               
        ],
        [
            'email.required_without'   => 'Email is required',
            'email.email'		  	   => 'Email id is not valid',
            'mobile.required_without'  => 'Phone is required',
        ]);

        if(!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all())]);
        }else{
            $functions = new Functions();
            $existingRecord = DB::table('users')
                    		->select(DB::raw("user_id"))
                            ->whereRaw(DB::raw("mobile ='".$request->mobile."' OR email = '".$request->email."'" ) )
                            ->first();
            
            $user_token = Hash::make($functions->_password_generate(20));
            $now  = date("Y-m-d H:i:s");
            $otp = mt_rand(1000, 9999);
            if($existingRecord) {
                $username = "user" . $existingRecord->user_id;
                $data =array(
                    'username'          => $username,
                    'dob'               => $request->dob,
                    'app_token'         => $user_token,
                    'time_zone'         => $request->timezone,
                    'verification_code' => $otp,
                    'verification_time' => $now,
                    'login_type'        => "OT",
                    'updated_at'        => $now
                );
                DB::table('users')
                        ->where('user_id', $existingRecord->user_id)
                        ->update($data);
                $data  = array( 'user_id' => $existingRecord->user_id, 'app_token' => $user_token,'username' =>$username );
            } else {
                    $user_id = DB::table("users")->select("user_id")->orderBy("user_id","desc")->first();
                    if($user_id){
                        $max_id = $user_id->user_id;
                    }else{
                        $max_id = 1001;
                    }
                    $username = "user" . $max_id;
                    while(DB::table("users")->select("user_id")->where("username",$username)->first())
                    {
                        $max_id++;
                        $username = "user" . $max_id;
                    }
        
                    $data =array(
                        'username'          => $username,
                        
                        'active'            => '0',
                        'app_token'         => $user_token,
                        'time_zone'         => $request->timezone,
                        'verification_code' => $otp,
                        'verification_time' => $now,
                        'login_type'        => "OT",
                        'created_at'        => $now,
                        'updated_at'        => $now
                    );
                    if($reuest->dob!=''){
                        $data['dob'] = $request->dob;
                    }
                    if($request->email){
                        $data['email'] = $request->email;
                    }
                    
                    if($request->mobile){
                        $data['mobile'] = $request->mobile;
                    }
                    
                    $id = DB::table('users')->insertGetId($data);
                    $data  = array( 'user_id' => $id, 'app_token' => $user_token,'username' =>$username );
                        
            }
            if($request->mobile!="") {
				$msg = "An OTP has been sent to your Mobile";	
                Functions::sendSMS("91".$request->mobile, $otp.' is your OTP to verify your account with LeukeVideos. Valid for 10 minutes. Do not share with anyone');    
			} else {
				$msg = "An OTP has been sent to your Email";
			}
            $response = array("status" => "success",'msg'=>$msg ,'content' => $data);      
            return response()->json($response); 
        }
    }
    
    public function login(Request $request){
        $validator = Validator::make($request->all(), [ 
            'email'          => 'required_without:mobile|sometimes|nullable|email',
            'mobile'         => 'required_without:email',
        ],
        [
            'email.required_without'   => 'Email is required',
            'email.email'		  	   => 'Email id is not valid',
            'mobile.required_without'  => 'Phone is required',
        ]);

        if(!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all())]);
        }else{
            $functions = new Functions();
            $existingRecord = DB::table('users')
                    		->select(DB::raw("user_id"))
                            ->whereRaw(DB::raw("mobile ='".$request->mobile."' OR email = '".$request->email."'" ) )
                            ->first();
            
            $user_token = Hash::make($functions->_password_generate(20));
            $now  = date("Y-m-d H:i:s");
            $otp = mt_rand(1000, 9999);
            if($existingRecord) {
                $username = "user" . $existingRecord->user_id;
                $data =array(
                    'username'          => $username,
                    'app_token'         => $user_token,
                    'time_zone'         => $request->timezone,
                    'verification_code' => $otp,
                    'verification_time' => $now,
                    'login_type'        => "OT",
                    'updated_at'        => $now
                );
                DB::table('users')
                        ->where('user_id', $existingRecord->user_id)
                        ->update($data);
                $data  = array( 'user_id' => $existingRecord->user_id, 'app_token' => $user_token,'username' =>$username );
            } else {
                    $user_id = DB::table("users")->select("user_id")->orderBy("user_id","desc")->first();
                    if($user_id){
                        $max_id = $user_id->user_id;
                    }else{
                        $max_id = 1001;
                    }
                    $username = "user" . $max_id;
                    while(DB::table("users")->select("user_id")->where("username",$username)->first())
                    {
                        $max_id++;
                        $username = "user" . $max_id;
                    }
        
                    $data =array(
                        'username'          => $username,
                        'active'            => '0',
                        'app_token'         => $user_token,
                        'time_zone'         => $request->timezone,
                        'verification_code' => $otp,
                        'verification_time' => $now,
                        'login_type'        => "OT",
                        'created_at'        => $now,
                        'updated_at'        => $now
                    );
                    
                    if($request->email){
                        $data['email'] = $request->email;
                    }
                    
                    if($request->mobile){
                        $data['mobile'] = $request->mobile;
                    }
                    
                    $id = DB::table('users')->insertGetId($data);
                    $data  = array( 'user_id' => $id, 'app_token' => $user_token,'username' =>$username );
                        
            }
            if($request->mobile!="") {
				$msg = "An OTP has been sent to your Mobile";	
				Functions::sendSMS("91".$request->mobile, $otp.' is your OTP to verify your account with LeukeVideos. Valid for 10 minutes. Do not share with anyone');
			} else {
				$msg = "An OTP has been sent to your Email";
			}
            $response = array("status" => "success",'msg'=>$msg ,'content' => $data);      
            return response()->json($response); 
        }
    }
    
    public function resend_otp(Request $request){

        $validator = Validator::make($request->all(), [
            'user_id'          => 'required'
        ],[
            'user_id.required' => 'User is required'
        ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all())]);
        }else{
                $userRecord = DB::table('users')
                    ->select("user_id","mobile","email")
                    ->where('user_id',$request->user_id)
                    ->first();

                if($userRecord) {
                    $otp = mt_rand(1000, 9999);
                    $now  = date("Y-m-d H:i:s");
                    DB::table('users')
                        ->where('user_id', $userRecord->user_id)
                        ->update(['verification_code' => $otp, 'verification_time' => $now]);
                    if($userRecord->mobile!='') {
                        Functions::sendSMS("91".$userRecord->mobile, $otp.' is your OTP to verify your account with LeukeVideos. Valid for 10 minutes. Do not share with anyone');    
                    }
                    $response = array( "status" => "success", "msg" => "An OTP has been sent to your Mobile or Email", 'user_id' => $userRecord->user_id ); 
                } else {
                    $response = array( "status" => "failed", "msg" => "Invalid user!" );
                }

                
            return response()->json($response);   
        }
    }

    public function fetchUserInformation(Request $request){
		$validator = Validator::make($request->all(), [
            'user_id'          => 'required'
        ],[
            'user_id.required' => 'User is required'
        ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all())]);
        }else{
	        $userRecord = DB::table('users')
	            ->select(DB::Raw("*,ifnull(dob,'".date('Y-m-d', strtotime('-13 years'))."') as dob,ifnull(bio,'') as bio"))
	            ->where('user_id',$request->user_id)
	            ->first();
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
            
                
	        if($userRecord) {
	            $response = array( "status" => "success", "content" => $userRecord , 'large_pic' => $file_path ,'small_pic' => $small_file_path ); 
	        } else {
	            $response = array( "status" => "failed", "msg" => "Invalid user!" );
	        }
	        
            return response()->json($response);   
        }
	}

    public function updateUserInformation(Request $request){
		$validator = Validator::make($request->all(), [
            'user_id'          => 'required',
            'name'          => 'required',
            'email'          => 'required',
            'mobile'          => 'required',
            'gender'          => 'required',
            'dob'          => 'required',
        ],[
            'user_id.required' => 'User Id is required',
            'name.required' => 'Name is required',
            'email.required' => 'Email is required',
            'mobile.required' => 'Mobile is required',
            'gender.required' => 'Gender is required',
            'dob.required' => 'DOB is required',
        ]);
        
        if (!$validator->passes()) {
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all())]);
        }else{
	        $userRecord = DB::table('users')
	            ->select("*")
	            ->where('user_id',$request->user_id)
	            ->first();
			
	        if($userRecord) {
	        	$nameArr = explode(" ",$request->name);
	        	$fname = $nameArr[0];
	        	if( isset($nameArr[1]) ) {
	        	    $lname = $nameArr[1];    
	        	} else {
	        	    $lname = '';
	        	}
	        	
				DB::table('users')
                        ->where('user_id', $userRecord->user_id)
                        ->update(['fname' => $fname,'lname' => $lname,'email' => $request->email,'mobile' => $request->mobile,'bio' => $request->bio,'gender' => $request->gender,'dob' => date('Y-m-d',strtotime($request->dob))]);
	            $response = array( "status" => "success", "msg" => "User information updated successfully." ); 
	        } else {
	            $response = array( "status" => "failed", "msg" => "Invalid user!" );
	        }
	        
            return response()->json($response);   
        }
	}

    public function socialLogin(Request $request){
        // print_r($request->all());
        // exit;
        $email = $request->email;
        $ios_email = $request->ios_email;
        $functions = new Functions();
        $isRecord = false;
        $user = DB::table("users")->whereRaw(DB::raw("email='".$email."' or email='".$ios_email."'"))->first();
        if($user){
            $isRecord = true;  
        } else {
            if($request->login_type == "A") {
                if($request->ios_uuid!="" && $request->ios_uuid!=null) {
                    $user = DB::table("users")->whereRaw(DB::raw("ios_uuid='".$request->ios_uuid."' OR email='.$request->ios_email.'"))->first();
                    if($user) {
                        echo "asdd"; exit;
                        $isRecord = true;
                    } else {
                        $isRecord = false;
                    }
                }
            }
            
        }
        if($isRecord){
            $ios_uuid = "";
            if($request->login_type == "A") {
                $ios_uuid = $request->ios_uuid;    
            }
            $uniques_user_id_res = DB::table("unique_users_ids")->select("unique_id","user_id","unique_token")->where('unique_token',$request->unique_token)->first();
            if($uniques_user_id_res){
                DB::table('unique_users_ids')
                ->where('unique_token',$request->unique_token)
                ->update(['user_id'=>$user->user_id]);
                DB::table('video_views')
                ->where('unique_id',$uniques_user_id_res->unique_id)
                ->where('user_id',0)
                ->update(['user_id'=>$user->user_id]);
            }else{
                DB::table('unique_users_ids')->insert(['unique_token'=>$request->unique_token,'user_id'=>$user->user_id]);   
            }
            // echo $user->login_type;
            $user_content = array(
                'user_id'           => $user->user_id,
                'username'          => $user->username,
                'fname'             => $user->fname,
                'lname'             => $user->lname,
                'email'             => $user->email,
                'mobile'            => ($user->mobile !=null) ? $user->mobile : '',
                'dob'               => $user->dob,
                'active'            => $user->active,
                'gender'            => $user->gender,
                'user_dp'           => $user->user_dp,                    
                'app_token'         => $user->app_token,
                'country'           => $user->country,
                'languages'         => $user->languages,
                'player_id'         => Functions::fSafeChar($request->player_id),
                'timezone'          => $user->time_zone,
                'login_type'        => $request->login_type,
                'ios_uuid'         => $ios_uuid,
                'last_active'       => Functions::fSafeChar($user->last_active),
            );
            if($request->login_type != "A") {
                DB::table('users')
                    ->where('user_id', $user->user_id)
                    ->update(['fname' => $request->fname,'lname' => $request->lname,'login_type' => $request->login_type,'user_dp' => Functions::fSafeChar($request->user_dp)]);    
            }
        
            $response = array("status" => "success",'msg'=>'Social login successfully' ,'content' => $user_content); 
        }
        else{
            $max_id = 1001;
            $username = "user" . $max_id;
            while(DB::table("users")->select("user_id")->where("username",$username)->first())
            {
                $max_id++;
                $username = "user" . $max_id;
            }
            $user_token = Hash::make($functions->_password_generate(20));
            $now  = date("Y-m-d H:i:s");
            $ios_uuid = "";
            if($request->login_type == "A") {
                $ios_uuid = $request->ios_uuid;    
            }
            $gender = "";
            if($request->gender != null && $request->gender != "") {
                if(strtolower($request->gender) == "male" || strtolower($request->gender) == "m") {
                    $gender = "m";
                } else if(strtolower($request->gender) == "female" || strtolower($request->gender) == "f") {
                    $gender = "f";
                } else {
                    $gender = "ot";
                }
            }
            $data = array(
                'username'          => $username,
                'fname'             => $request->fname,
                'lname'             => $request->lname,
                
                'active'            => '1',
                'gender'            => $gender,
                'app_token'         => $user_token,
                'country'           => Functions::fSafeChar($request->country),
                'languages'         => Functions::fSafeChar($request->languages),
                'time_zone'         => Functions::fSafeChar($request->timezone),
                'user_dp'           => Functions::fSafeChar($request->user_dp),
                'login_type'        => $request->login_type,
                // 'login_type'        => 'FB',
                'created_at'        => $now,
                'updated_at'        => $now,
                'ios_uuid'         => $ios_uuid,
            );

            if(isset($request->dob) && $request->dob!=''){
                $data['dob']     =  date("Y-m-d", strtotime($request->dob));
            }
            if(isset($request->email)){
                $data['email'] = $request->email;
            }

            if(isset($request->mobile)){
                $data['mobile'] = $request->mobile;
            }

            $id = DB::table('users')->insertGetId($data);
            $path = $functions->_getUserFolderName($id, "public/videos");
            // $path = $functions->_getUserFolderName($id, "public/videos/gif");
            $path2 = $functions->_getUserFolderName($id, "public/photos");
            $path3 = $functions->_getUserFolderName($id, 'public/profile_pic');
            $path3 = $functions->_getUserFolderName($id, 'public/sounds');
             $video_gif_path = "public/videos/".$id.'/gif';        
            // $profile_path = "public/profile_pic/".$id;        
            // $sound_path = "public/sounds/".$id;        
            $folderExists = Storage::exists($video_gif_path);
            if(!$folderExists){
                Storage::makeDirectory($video_gif_path);
            }
            // $folderExists1 = Storage::exists($profile_path);
            // if(!$folderExists1){
            //     Storage::makeDirectory($profile_path);
            // }
            // $folderExists3 = Storage::exists($sound_path);
            // if(!$folderExists3){
            //     Storage::makeDirectory($sound_path);
            // }
            
          
            $uniques_user_id_res = DB::table("unique_users_ids")->select("unique_id","user_id","unique_token")->where('unique_token',$request->unique_token)->first();
            if($uniques_user_id_res){
                DB::table('unique_users_ids')
                ->where('unique_token',$request->unique_token)
                ->update(['user_id'=>$id]);
                DB::table('video_views')
                ->where('unique_id',$uniques_user_id_res->unique_id)
                ->where('user_id',0)
                ->update(['user_id'=>$id]);
            }else{
                DB::table('unique_users_ids')->insert(['unique_token'=>$request->unique_token,'user_id'=>$id]);   
            }
        $user_content = array(
            'user_id'           => $id,
            'username'          => $username,
            'fname'             => $request->fname,
            'lname'             => $request->lname,
            'email'             => $request->email,
            'mobile'            => $request->mobile,
            
            'active'            => 1,
            'gender'            => ($request->gender == 'male') ? 'm' : 'f',
            'user_dp'           => $request->user_dp,                    
            'app_token'         => $user_token,
            'country'           => $request->country,
            'languages'         => $request->languages,
            'player_id'         => Functions::fSafeChar($request->player_id),
            'time_zone'         => $request->timezone,
            'user_dp'           => $request->user_dp,                    
            'last_active'       => $now, 
            'ios_uuid'         => $ios_uuid,
        );
         if(isset($request->dob) && $request->dob!=''){
                $user_content ['dob']     =  date("Y-m-d", strtotime($request->dob));
            }
        $response = array("status" => "success",'msg'=>'Social login successfully' ,'content' => $user_content); 
    }
         
    return response()->json($response); 
    
}

public function verifyOtp(Request $request){

    $otp = $request->otp;
    if(strlen($otp)<=4){
        $user_id= $request->user_id;
        $chk = DB::table("users")->select(DB::raw("user_id,user_dp,app_token,fname,lname,mobile,email,gender,ifnull(dob,'NA') as dob,verification_time,verification_code"))->where("user_id",$user_id)->whereNotNull("verification_time")->first();

        if($chk){
            $now = date('Y-m-d H:i:s');
            $datetime = \DateTime::createFromFormat('Y-m-d H:i:s', $chk->verification_time);
            $datetime->modify('+10 minutes');
            $expiryTime= $datetime->format('Y-m-d H:i:s');

            $datetime = \DateTime::createFromFormat('Y-m-d H:i:s', $chk->verification_time);
            $datetime->modify('+10 minutes');
            $expiryTime= $datetime->format('Y-m-d H:i:s');
            if(strtotime($now) > strtotime($expiryTime)){
                $response = array("status" => "error",'msg'=>'Otp Expired');      
            }else{
                if(($chk->verification_code) != trim($otp)){
                    $response = array("status" => "error",'msg'=>'Otp doesn\'t match.');      
                }else{
                    DB::table("users")->where("user_id",$user_id)->update(array("active"=>'1','verification_code'=>'','verification_time'=>null));
                    $response = array("status" => "success",'msg'=>'Profile activated successfully. Proceed to Login', 'data' => json_decode(json_encode($chk), true));      
                }
            }
        }else{
            $response = array("status" => "error",'msg'=>'User doesn\'t exist.');      
        }
    }else{
        $response = array("status" => "error",'msg'=>'Otp should be of 4 digits');      
    }
    // dd($response);
    return response()->json($response);

}

}   