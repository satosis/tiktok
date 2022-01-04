<?php
namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB; 
use Illuminate\Support\Facades\Storage; 
use App\Helpers\Common\Functions;
use Mail;
use FFMpeg\Format\Video\X264;
use ProtoneMedia\LaravelFFMpeg\Support\FFMpeg;
use ProtoneMedia\LaravelFFMpeg\Support\ServiceProvider;
use App\Jobs\ConvertVideoForStreaming;
use ProtoneMedia\LaravelFFMpeg\Filesystem\Media;
use FFMpeg as FFMpeg1;
use FFProbe as FFProbe1;
use GifCreator\GifCreator;
use FFMpeg\Coordinate\TimeCode;
use Intervention\Image\ImageManagerStatic as Image;
use File;
use Illuminate\Filesystem\Filesystem;

class VideoController extends Controller
{   

     var $column_order = array(null,null,'username', 'title', 'thumb', 'video'); //set column field database for datatable orderable

    var $column_search = array('u.username','v.title','v.video'); //set column field database for datatable searchable

    var $order = array('v.video_id' => 'asc'); // default order

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view("admin.videos");
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        $action = 'add';
        $users = DB::table('users')
                        ->select(DB::raw('user_id,username'))
                        ->where('active',1)
                        ->where('deleted',0)
                        ->orderBy('user_id','ASC')
                        ->get();
         $sounds = DB::table('sounds')
                        ->select(DB::raw('sound_id,title'))
                        ->where('deleted',0)
                        ->orderBy('title','ASC')
                        ->get();      
        return view('admin.videos-create',compact('action','users','sounds'));
    }

private function _form_validation($request){
      
        $validator = Validator::make($request->all(), [ 
            'user_id'          => 'required',              
            // 'title'          => 'required', 
            'video'          => 'mimes:mp4,mov,ogg,qt',              
        ],[ 
            'user_id.required'   => 'User Id  is required.',
            // 'title.required'   => 'Title is required.',
            'video.mimes'   => 'Video Type is invalid',
        ]);
        //dd($request->all());
        if (!$validator->passes()) {
            // $file=$request->file('video');
            // $ext=$file->getClientOriginalExtension();
            return response()->json(['status'=>'error','msg'=> $this->_error_string($validator->errors()->all()) ]);
        }else{
           
            $functions = new Functions();
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
            
            if($request->id>0){
                if($request->hasFile('video')){
                    $time_folder=time();
                    $videoPath = 'public/videos/'.$request->user_id;
                                   
                    $videoFileName=$request->file('video')->getClientOriginalName();
                    $request->video->storeAs("public/videos/".$request->user_id, $videoFileName);
                 
                    if($request->sound_id>0){
                        $soundName = DB::table("sounds")
                                    ->select(DB::raw("sound_name,user_id"))
                                    ->where("sound_id",$request->sound_id)
                                    ->first();
                            
                                    if($soundName->user_id>0){
                                        $soundPath = 'public/sounds/'.$soundName->user_id.'/'. $soundName->sound_name;
                                    }else{
                                        $soundPath = 'public/sounds/'. $soundName->sound_name;
                                    }
                    
                        FFMpeg::fromDisk('local')
                        ->open([$videoPath.'/'.$videoFileName, $soundPath])
                        ->export()
                        ->addFormatOutputMapping(new X264('libmp3lame', 'libx264'), Media::make('local', 'public/videos/'.$request->user_id.'/'.$time_folder.'/'.$videoFileName), ['0:v', '1:a'])
                        ->save();
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
                        $audioData = array(
                            'user_id' => $request->user_id,
                            'cat_id' => 0,
                            'title' => $request->user_id.'_'.$time_folder,
                            'sound_name' => $time_folder.'.aac',
                            'tags'     => $hashtags,
                            'duration' =>$audio_duration,
                            'created_at' => date('Y-m-d H:i:s')
                        ); 
                        
                        DB::table('sounds')->insert($audioData);
                        
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
                    if($request->sound_id==0 || $request->sound_id==null){
                        $sound_id=0;
                    }else{
                        $sound_id=$request->sound_id;
                    }


                    $data =array(
                        'user_id'       => $request->user_id,
                        'video'         => $time_folder.'/'.$videoFileName,
                        'thumb'         => $time_folder.'.jpg',
                        'gif'         => $time_folder.'.gif',
                        'title' => ($request->title==null)?'' : $request->title,
                        'description' => ($request->description==null)? '' : $request->description,
                        'duration'    => $duration,
                        'sound_id'     => $sound_id,
                        'tags'      => $hashtags,
                        'enabled' => 1,
                        'master_video' => $c_path,
                        'created_at' => date('Y-m-d H:i:s'),
                        'updated_at' => date('Y-m-d H:i:s')
                    );
                    DB::table('videos')->where('video_id',$id)->update($data); 
                    //$v_id=DB::table('videos')->insertGetId($data);  
                    $video = array(
                        'disk'          => 'local',
                        'original_name' => $request->video->getClientOriginalName(),
                        'path'          => $file_path,
                        'c_path'        => $c_path,
                        'title'         => $request->title,
                        'video_id'      => $id,
                        'user_id'       => $request->user_id
                    );
                    
                    ConvertVideoForStreaming::dispatch($video);
    
                    return $data;
                }else{
                    // $fileName=$request->old_video;
            
                    // $thumb_name=$request->old_thumb;
                    // $gif_name=$request->old_gif;
                    // $duration=$request->old_duration;
                    if($request->sound_id==0 || $request->sound_id==null){
                        $sound_id=0;
                    }else{
                        $sound_id=$request->sound_id;
                    }
                    $data =array(
                        
                        'title' => ($request->title==null)?'' : $request->title,
                        'description' => ($request->description==null)? '' : $request->description,
                        'sound_id'     => $sound_id,
                        'tags'      => $hashtags,
                        'enabled' => 1,
                        'updated_at' => date('Y-m-d H:i:s')
                    );
                   return $data; 
                }
                
            }else{
      
                if($request->hasFile('video')){
                    $time_folder=time();
                    $videoPath = 'public/videos/'.$request->user_id;
                   
    
                    $videoFileName=$request->file('video')->getClientOriginalName();
                    $request->video->storeAs("public/videos/".$request->user_id, $videoFileName);
                 
                    if($request->sound_id>0){
                        $soundName = DB::table("sounds")
                                    ->select(DB::raw("sound_name,user_id"))
                                    ->where("sound_id",$request->sound_id)
                                    ->first();
                                    if($soundName->user_id>0){
                                        $soundPath = 'public/sounds/'.$soundName->user_id.'/'. $soundName->sound_name;
                                    }else{
                                        $soundPath = 'public/sounds/'. $soundName->sound_name;
                                    }
                        FFMpeg::fromDisk('local')
                        ->open([$videoPath.'/'.$videoFileName, $soundPath])
                        ->export()
                        ->addFormatOutputMapping(new X264('libmp3lame', 'libx264'), Media::make('local', 'public/videos/'.$request->user_id.'/'.$time_folder.'/'.$videoFileName), ['0:v', '1:a'])
                        ->save();
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
                            $audioData = array(
                                'user_id' => $request->user_id,
                                'cat_id' => 0,
                                'title' => $request->user_id.'_'.$time_folder,
                                'sound_name' => $time_folder.'.aac',
                                'tags'     => $hashtags,
                                'duration' =>$audio_duration,
                                'created_at' => date('Y-m-d H:i:s')
                            ); 
                            
                        DB::table('sounds')->insert($audioData);
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
                    if($request->sound_id==0 || $request->sound_id==null){
                        $sound_id=0;
                    }else{
                        $sound_id=$request->sound_id;
                    }


                    $data =array(
                        'user_id'       => $request->user_id,
                        'video'         => $time_folder.'/'.$videoFileName,
                        'thumb'         => $time_folder.'.jpg',
                        'gif'         => $time_folder.'.gif',
                        'title' => ($request->title==null)?'' : $request->title,
                        'description' => ($request->description==null)? '' : $request->description,
                        'duration'    => $duration,
                        'sound_id'     => $sound_id,
                        'master_video' => $c_path,
                        'tags'      => $hashtags,
                        'enabled' => 1,
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
    
                    return $data;

                }else{
                    redirect( config('app.admin_url').'/videos')->with('error','You can\'t leave Video field empty');
                }
            }
        }
       
    }
    
      private function getCleanFileName($filename){
        return preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename) . '.m3u8';
    }
 
    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $data = $this->_form_validation($request);
        //DB::table('videos')->insert($data);
        return redirect( config('app.admin_url').'/videos')->with('success','Video submitted successfully');
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show()
    {   
        $users = DB::table('users')
                        ->select(DB::raw('user_id,username'))
                        ->where('active',1)
                        ->where('deleted',0)
                        ->orderBy('user_id','ASC')
                        ->get();
        $sounds = DB::table('sounds')
                        ->select(DB::raw('sound_id,title'))
                        ->where('deleted',0)
                        ->orderBy('title','ASC')
                        ->get();   
        return view("admin.categories",compact('users','sounds'));
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        $action = 'edit';
        $users = DB::table('users')
                        ->select(DB::raw('user_id,username'))
                        ->where('active',1)
                        ->where('deleted',0)
                        ->orderBy('user_id','ASC')
                        ->get();
        $sounds = DB::table('sounds')
                        ->select(DB::raw('sound_id,title'))
                        ->where('deleted',0)
                        ->orderBy('title','ASC')
                        ->get();   
        $video = DB::table('videos')->select(DB::raw("*"))->where('video_id','=',$id)->first();
       // dd( $video);
        return view('admin.videos-create',compact('video','id','action','users','sounds'));
    }

  
    public function view($id)
    {
        $action = 'view';
        $users = DB::table('users')
            ->select(DB::raw('user_id,username'))
            ->where('active',1)
            ->where('deleted',0)
            ->orderBy('user_id','ASC')
            ->get();
         $sounds = DB::table('sounds')
                        ->select(DB::raw('sound_id,title'))
                        ->where('deleted',0)
                        ->orderBy('title','ASC')
                        ->get();   
        $video = DB::table('videos')->select(DB::raw("*"))->where('video_id','=',$id)->first();
    
        return view('admin.videos-create',compact('video','id','action','users','sounds'));
    }

   
    
    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $data = $this->_form_validation($request);
        //DB::table('videos')->where('video_id',$id)->update($data);
        return redirect( config('app.admin_url').'/videos')->with('success','Video updated successfully');
    }

  
    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
   
     public function serverProcessing(Request $request)
    {
        $currentPath = url(config('app.admin_url')).'/videos/';

        $list = $this->get_datatables($request);
        $data = array();
        $no = $request->start;
        foreach ($list as $category) {
            $no++;
            $row = array();
            //<a class="edit" href="'.$currentPath.$category->video_id.'/edit"><i class="fa fa-edit"></i></a>;
            $row[] = '<a class="view" href="'.$currentPath.$category->video_id.'/'.'view"><i class="fa fa-search"></i></a><a class="delete deleteSelSingle" style="cursor:pointer;" data-val="'.$category->video_id.'"><i class="fa fa-trash"></i></a>';
            $row[] = '<div class="align-center"><input id="cb'.$no.'" name="key_m[]" class="delete_box blue-check" type="checkbox" data-val="'.$category->video_id.'"><label for="cb'.$no.'"></label></div>';
            $row[] = $category->username;
            $row[] = $category->title;
            $row[] = "<img src=".secure_asset('storage/videos/'.$category->user_id.'/thumb/'.$category->thumb)." height=200/>";
            $row[] = $category->video;
            $data[] = $row;
        }

        $output = array(
            "draw" => $request->draw,
            "recordsTotal" => $this->count_all($request),
            "recordsFiltered" => $this->count_filtered($request),
            "data" => $data,
        );
        echo json_encode($output);
    }

    private function _get_datatables_query($request)
    {            
        $keyword = $request->search['value'];
        $order = $request->order;
        $candidateRS = DB::table('videos as v')
                        ->leftJoin('users as u' , 'u.user_id','=','v.user_id')
                       ->select(DB::raw("v.*,u.username"));
                        
        $strWhere = " v.active=1";
        $strWhereOr = "";
        $i = 0;

        foreach ($this->column_search as $item) // loop column
        {
            if($keyword) // if datatable send POST for search{
                $strWhereOr = $strWhereOr." $item like '%".$keyword."%' or ";
                //$candidateRS = $candidateRS->orWhere($item, 'like', '%' . $keyword . '%') ;
        }
        $strWhereOr = trim($strWhereOr, "or ");
        if($strWhereOr!=""){
            $candidateRS = $candidateRS->whereRaw(DB::raw($strWhere." and (".$strWhereOr.")"));
        }else{
            $candidateRS = $candidateRS->whereRaw(DB::raw($strWhere ));
        }
        

        if(isset($order)) // here order processing
        {
            $candidateRS = $candidateRS->orderBy($this->column_order[$request->order['0']['column']], $request->order['0']['dir']);
        } 
        else if(isset($this->order))
        {
            $orderby = $this->order;
            $candidateRS = $candidateRS->orderBy(key($orderby),$orderby[key($orderby)]);
        }
       
        return $candidateRS;
    }

    function get_datatables($request)
    {
        $candidateRS = $this->_get_datatables_query($request);
        if($request->length != -1){
            $candidateRS = $candidateRS->limit($request->length);
            if($request->start != -1){
                $candidateRS = $candidateRS->offset($request->start);
            }
        }
        
        $candidates = $candidateRS->get();
        return $candidates;
    }

    function count_filtered($request)
    {
        $candidateRS = $this->_get_datatables_query($request);
        return $candidateRS->count();
    }

    public function count_all($request)
    {
        $candidateRS = DB::table('videos')->select(DB::raw("count(*) as total"))->where('active',1)->first();
        return $candidateRS->total;
    }

    public function delete(Request $request){
        $rec_exists = array();
        $del_error = '';
        $ids = explode(',',$request->ids);
        foreach ($ids as $id) {
             $videoRes = DB::table('videos')->select(DB::raw("video,user_id"))->where('video_id',$id)->first();
            $video_name=explode('/',$videoRes->video);
            $folder_name=$videoRes->user_id.'/'.$video_name[0];
            $f_name=explode('.',$video_name[0]);
            $thumb_name=$videoRes->user_id.'/thumb/'.$f_name[0].'.jpg';
            $gif_name=$videoRes->user_id.'/gif/'.$f_name[0].'.gif';
            
            File::deleteDirectory(storage_path()."/app/public/videos/".$folder_name);
            File::Delete(storage_path()."/app/public/videos/".$thumb_name);
            File::Delete(storage_path()."/app/public/videos/".$gif_name);
            DB::table('videos')->where('video_id', $id)->delete();
        }
        
        if($del_error == 'error'){
            $request->session()->put('error',$msg );
            return response()->json(['status' => 'error',"rec_exists"=>$rec_exists]);
        }else{
            if( count($ids) > 1){
                $msg = "Video deleted successfully";
            }else{
                $msg = "Video deleted successfully";
            }
            $request->session()->put('success', $msg);
            return response()->json(['status' => 'success',"rec_exists"=>$rec_exists]);
        }
        return redirect()->back();
    }

    public function copyContent($id)
    {
        $action = 'copy';
        $parent_categories = DB::table('categories')
            ->select(DB::raw('cat_id,cat_name,parent_id'))
            ->where('parent_id',0)
            ->orderBy('cat_id','ASC')
            ->get();
        $categories = DB::table('categories')
                ->select(DB::raw('cat_id,cat_name,parent_id'))
                ->where('parent_id','!=',0)
                ->orderBy('cat_id','ASC')
                ->get();
        $sound = DB::table('sounds')->select(DB::raw("*"))->where('sound_id','=',$id)->first();
        return view('admin.sounds-create',compact('id','sound','action','parent_categories','categories'));
    }
}
