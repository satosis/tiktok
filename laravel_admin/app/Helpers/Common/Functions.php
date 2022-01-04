<?php
namespace App\Helpers\Common; 

use Intervention\Image\ImageManagerStatic as Image;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; 
use Auth;

class Functions {
    /**
     * @param int $user_id User-id
     * 
     * @return string
     */
     
    public static function digitsFormate($digits)
    {
        $formatedDigits = 0;
        if ($digits >= 1000000000)
        {
            $formatedDigits = number_format($digits / 1000000000, 2) . ' G';
        }
        elseif ($digits >= 1000000)
        {
            $formatedDigits = number_format($digits / 1000000, 2) . ' M';
        }
        elseif ($digits >= 1000)
        {
            $formatedDigits = number_format($digits / 1000, 2) . ' K';
        } else {
            $formatedDigits = $digits;
        }
        return $formatedDigits;
} 
     
    public static function time_elapsed_string($datetime, $full = false) {
        $now = new \DateTime;
        $ago = new \DateTime($datetime);
        $diff = $now->diff($ago);
    
        $diff->w = floor($diff->d / 7);
        $diff->d -= $diff->w * 7;
    
        $string = array(
            'y' => 'y',
            'm' => 'm',
            'w' => 'w',
            'd' => 'd',
            'h' => 'h',
            'i' => 'm',
            's' => 's',
        );
        foreach ($string as $k => &$v) {
            if ($diff->$k) {
                $v = $diff->$k . $v;
            } else {
                unset($string[$k]);
            }
        }
    
        if (!$full) $string = array_slice($string, 0, 1);
        return $string ? implode(', ', $string) : 'just now';
    } 
     
    public static function sendSMS($mobile_no, $msg=""){
        $sms_apikey = config("app.sms_apikey");
        $sms_sender_id = config("app.sms_sender_id");
        $mobile_no = $mobile_no;
        $msg = urlencode($msg);
        $service_name = 'TEMPLATE_BASED';
        $url = "https://smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY=$sms_apikey&MobileNo=$mobile_no&SenderID=$sms_sender_id&Message=$msg&ServiceName=$service_name";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $httpResponse = curl_exec($ch);
        curl_close($ch);
    } 
    
    public static function getFolderName($folder,$size = '') {

        $path = $folder;  

        if($size!=''){            
            $path.= '/'.$size;
        }  

        $folderExists = Storage::exists($path);

        if(!$folderExists){
            Storage::makeDirectory($path);
        } 

        return $path;
    }
    
      function send_notification($to, $msg, $app_id, $notify_to, $heading="", $page="", $param_name="", $param_value="", $id=0){
         
        if($to!=""){
            
            $content = array(
                "en" => $msg
                );
            $heading_arr = array("en"=>$heading);
            
            $fields = array(
                'app_id' => $app_id,
                'include_player_ids' => array($to),
                'contents' => $content,
                'large_icon' => url('/imgs/notify_logo.png'),
                'data' => array("page_name" => $page, "param_name" => $param_name, "param_value" => $param_value),
                'headings' => $heading_arr
            );
          
            $fields = json_encode($fields);
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
            curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json; charset=utf-8'));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
            curl_setopt($ch, CURLOPT_HEADER, FALSE);
            curl_setopt($ch, CURLOPT_POST, TRUE);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    
            $response = curl_exec($ch);
           
            curl_close($ch);
            return $response;
        }
    }

    
    public static function createThumb($imagePath,$req_width,$req_height,$path,$filename){

        $img = Image::make($imagePath);
        
        // Creating thumbnail without crop of specific size
        $img->resize($req_width, $req_height, function ($constraint) {
            $constraint->aspectRatio();
        });
        
        Storage::put($path.'/'.$filename,$img->stream()->__toString(), 'public');
        return true;
    }

    public static function createThumbWidth($imagePath,$req_width,$path,$filename){

        $img = Image::make($imagePath);
        
        $img->resize($req_width, null, function ($constraint) {
            $constraint->aspectRatio();
        });
        
        Storage::put($path.'/'.$filename,$img->stream()->__toString(), 'public');
        return true;
    }

    public static function createThumbHeight($imagePath,$req_height,$path,$filename){

        $img = Image::make($imagePath);
        
        $img->resize(null, $req_height, function ($constraint) {
            $constraint->aspectRatio();
        });
        
        Storage::put($path.'/'.$filename,$img->stream()->__toString(), 'public');
        return true;
    }

    public static function saveImage( $file, $folder ){
        $path = self::getFolderName($folder);
        $filenametostore = $file->store($path);          
        Storage::setVisibility($filenametostore, 'public');
        $fileArray = explode('/',$filenametostore);               
        $fileName = array_pop($fileArray); 
        return $fileName;
    }

    public static function saveImageAs( $file, $folder,$fileName ){
        $path = self::getFolderName($folder);       
        $file->storeAs($folder, $fileName);           
        Storage::setVisibility($folder.'/'.$fileName, 'public');          
        return true;
    }

    public static function getImageName($color_filter,$cat_id,$product_id,$image_no,$extension){
        $image_name = self::nameToAlias($color_filter).'-';
        foreach ($cat_id as $value) {
            $category = DB::table('categories')
            ->select(DB::raw("cat_name,alias"))
            ->where('cat_id',$value)
            ->first();
            if($category->alias){
                $image_name.= $category->alias.'-';
            }else{
                $image_name.= self::nameToAlias($category->cat_name).'-';
            }
        }
        $image_name.= $product_id.'-'.$image_no.'.'.$extension;
        return $image_name;
    }

    public static function nameToAlias($name){
        return str_replace(' ', '-', strtolower($name));
    }

    public static function alaisToName($alias){
        return str_replace('-', ' ', strtoupper($name));
    }

    public static function filters($product_id){
        $filters      = "";
        $product = DB::table("products")->select(DB::raw("color_filter,silhouette_id,fabric_id,neckline_id,season_id"))->where('product_id',$product_id)->first();
        $color_filter = strtolower($product->color_filter);
        $silhouette   = $product->silhouette_id;
        $fabric       = $product->fabric_id;
        $neckline     = $product->neckline_id;
        if($product->season_id!=''){
            $season   = explode(',',$product->season_id);
        }
        
        if( isset($color_filter) && $color_filter!="") {
            $filters  = self::nameToAlias($color_filter).",";
        }
        if( isset($season) && count($season) > 0 ) {
            foreach ($season as $key) {
                $db_season = DB::table('seasons')->select(DB::raw('season'))->where('season_id',$key)->first();
            }
            $filters .= self::nameToAlias($db_season->season).",";
        }
        if( isset($silhouette) && $silhouette!='') {
            $db_silhouette = DB::table('silhouettes')->select(DB::raw('silhouette'))->where('silhouette_id',$silhouette)->first();
            $filters .= self::nameToAlias($db_silhouette->silhouette).",";
        }
        if( isset($fabric) && $fabric!='') {
            $db_fabric = DB::table('fabrics')->select(DB::raw('fabric'))->where('fabric_id',$fabric)->first();
            $filters .= self::nameToAlias($db_fabric->fabric).",";
        }
        if( isset($neckline) && $neckline!='') {
            $db_neckline = DB::table('necklines')->select(DB::raw('neckline_type'))->where('neckline_id',$neckline)->first();
            $filters .= self::nameToAlias($db_neckline->neckline_type).",";
        }
        $product_sizes = DB::table("product_sizes")->select(DB::raw("distinct(size)as size"))->where('product_id',$product_id)->get();
        foreach ($product_sizes as $product_size) {
            $filters .= 'size-'.self::nameToAlias($product_size->size).",";
        }
        DB::table('products')->where('product_id',$product_id)->update(['filters'=>$filters]);
        return true;
    }

    public static function slugify($text)
    {
        // replace non letter or digits by -
        $text = preg_replace('~[^\pL\d]+~u', '-', $text);       
        // remove unwanted characters
        $text = preg_replace('~[^-\w]+~', '', $text);
        // trim
        $text = trim($text, '-');
        // remove duplicate -
        $text = preg_replace('~-+~', '-', $text);
        // lowercase
        $text = strtolower($text);
        if (empty($text)) {
            return 'n-a';
        }
        return $text;
    }

    public static function getName(){
        $admin = Auth::guard('admin')->user();
        echo ucfirst($admin->name); 
    }

    public static function getCategories(){

        $categories = DB::table('categories')
            ->select(DB::raw("*"))
            ->where('visible',1)
            ->orderBy('rank','ASC')
            ->get();

        return $categories;
    }
   public static function validate_token($user_id,$app_token){
        $res=DB::table('users')
         		->select(DB::raw("count(*) as user_count"))
                ->where('user_id',$user_id)
                ->where('app_token',$app_token)
                //->where('user_type',$type)
                ->first();

        if($res->user_count == 0){ 
            return 0;
        }else{
            return 1;
        }
    }

 
 	public function date_time($time){
		$timestamp=strtotime($time);
	  $date = date('d/m/Y', $timestamp);
	  $time = date('h:i A', $timestamp);

	    if($date == date('d/m/Y')) {
	      $date = $time;
	       return $date;
	    } 
	    else if($date == date('d/m/Y', strtotime(' -1 day'))) {
	      $date = 'Yesterday at '.$time;
	       return $date;
	    }else{
	    	return date('M d,Y ', $timestamp)." at ".date('h:i A', $timestamp);
	    	}
	}
 
    public function _password_generate($chars){
        $data = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcefghijklmnopqrstuvwxyz';
        return substr(str_shuffle($data), 0, $chars);
    }

    public function _getUserFolderName($user_id, $folder){
        $path = $folder.'/'.$user_id;        
        $folderExists = Storage::exists($path);
        if(!$folderExists){
            Storage::makeDirectory($path);
        }
        return $path;        
    }


    public function _cropImage($imagePath,$req_width,$req_height,$x,$y,$path,$filename){

        $img = Image::make($imagePath);

        $width  = $img->width();
        $height = $img->height(); 

        $vertical   = (($width < $height) ? true : false);
        $horizontal = (($width > $height) ? true : false);
        $square     = (($width == $height) ? true : false);
        //$vertical = true;

        if ($vertical) {

        	$new_height = $req_height;
        	$new_width = round(($new_height/$height)*$width);
        	
            //$top = $bottom = ( ( $req_height - $height ) / 2);
            //$newHeight = ($req_height) - ($bottom + $top);
            
            $img->resize($new_width, $new_height, function ($constraint) {
                $constraint->aspectRatio();
            });
            
		 	$img->crop($new_width, $new_width, $x,$y); 
		 	$img->fit(500, 500, function ($constraint) {
			    $constraint->upsize();
			});  
		 	//$img->resizeCanvas($new_width, $new_height, 'center', true, '#ffffff');
        	
        } else{

        	$new_height = round(($req_width/$width)*$height);
        	$new_width = $req_width;
        	
            $img->resize($new_width, $new_height, function ($constraint) {
                $constraint->aspectRatio();
            });
            $img->fit(500, 500, function ($constraint) {
				    $constraint->upsize();
				});
	 		
	        $img->crop($new_height, $new_height, $x,$y);  
	       // $img->resizeCanvas($new_width, $new_height, 'center', true, '#ffffff'); 
        }

        Storage::put($path.'/'.$filename,$img->stream()->__toString(), 'public');
        
        return true;        
    }

    public function _createThumb($imagePath,$req_width,$req_height,$path,$filename){

        $img = Image::make($imagePath);

        $width  = $img->width();
        $height = $img->height(); 

        $vertical   = (($width < $height) ? true : false);
        $horizontal = (($width > $height) ? true : false);
        $square     = (($width == $height) ? true : false);
        $vertical = true;

        if ($vertical) {

        	$new_height = $req_height;
        	$new_width = round(($new_height/$height)*$width);
        	
            //$top = $bottom = ( ( $req_height - $height ) / 2);
            //$newHeight = ($req_height) - ($bottom + $top);
            
            $img->resize($new_width, $new_height, function ($constraint) {
                $constraint->aspectRatio();
            });

        } else{

        	$new_height = round(($req_width/$width)*$height);
        	$new_width = $req_width;
        	
            $img->resize($new_width, $new_height, function ($constraint) {
                $constraint->aspectRatio();
            });

        }

        $img->resizeCanvas($new_width, $new_height, 'center', false, '#ffffff');
               
        Storage::put($path.'/'.$filename,$img->stream()->__toString(), 'public');
        
        return true;        
    }

    public function _user_check($user_id,$app_token,$type){
        $user = DB::table("users")
            ->select(DB::raw("count(*) as user_count"))
            ->where('user_id',$user_id)
            ->where('app_token',$app_token)
            ->where('user_type',$type)
            ->first();

        if($user->user_count == 0){ 
            return 0;
        }else{
            return 1;
        }
    }

    public function valid_candidate($user_id,$type){
        $user = DB::table("users")
            ->select(DB::raw("count(*) as user_count"))
            ->where('user_id',$user_id)
            ->where('user_type',$type)
            ->where('active',1)
            ->first();

        if($user->user_count == 0){ 
            return 0;
        }else{
            return 1;
        }
    }
    public static function fSafeNum($str)
    {   
        if($str){
            $str =trim($str);
            $str = str_replace(" ","",$str);
            $str = str_replace(",","",$str);
            if (is_numeric($str))
            {
                return doubleval($str);
            }
            else
            {
                return 0 ;
            }
        }else{
            return 0 ;
        }

    }
    public static function fSafeChar($str)
    {
        if($str){
            $str = trim($str);
            $str = str_replace("\'","'",$str);
            $str = str_replace("'","''",$str);
            return $str;    
        }else{
            return "";
        }
        
    }
    public static function getLogo(){
        $settings = DB::table('settings')->select("site_logo")->where("setting_id",1)->first();
        $site_logo = "3e9sZOW9up5Xvs7pzVHOGlqpoAQmBtNglGlH025H.jpeg";
        if($settings){
            $site_logo = $settings->site_logo;
        }
        return $site_logo;
    }
}