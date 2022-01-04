<?php

namespace App\Http\Controllers\Admin;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB; 
use Illuminate\Support\Facades\Storage; 

class SettingController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index($id=1)
    {
        $action = 'edit';
        $settings = DB::table('settings')->select(DB::raw("*"))->where('setting_id','=',$id)->first();
        // dd($setting);
        return view('admin.settings-create',compact('settings','action','id'));
    }

    private function _form_validation($request){
        $rules = [
            'site_name'     => 'required',
            // 'site_address'     => 'required',
            // 'site_email'     => 'required',
            // 'site_phone' => 'required',
            'site_logo'     => 'required',
        ];
        $messages = [
            'site_name.required' => 'You can\'t leave Invoice Start From field empty',
            // 'site_address.required'    => 'You can\'t leave Registration Fee field empty',
            // 'site_email.required'    => 'You can\'t leave Invoice Comapny Name field empty',
            // 'site_phone.required'    => 'You can\'t leave Address field empty',
            'site_logo.required'    => 'Please select a logo',
        ];
        $this->validate($request,$rules,$messages);
        $fileName="";
        if($request->hasFile('site_logo')) {
            $path = 'public/uploads/logos';
            $filenametostore = $request->file('site_logo')->store($path);
            Storage::setVisibility($filenametostore, 'public');
            $fileArray = explode('/',$filenametostore);
            $fileName = array_pop($fileArray);
            // $file_path = secure_asset(config('app.profile_path').$request->user_id."/".$fileName);
        }else{
            if(isset($request->id) && $request->id>0){
                $fileName=$request->old_img;
            }else{
               // return redirect(( config('app.admin_url').'/categories/create'))->with('error',' You can\'t leave image field empty')->withInput();
            }
        }
        $data['img']=$fileName;
        
        $postData = array(
            'site_name' => $request->site_name,
            'site_address' => $request->site_address,
            'site_email'     => $request->site_email,
            'site_phone'     => $request->site_phone,
            'site_logo'     => $fileName,
            'updated_at'     => date('Y-m-d H:i:s'),
        );
        return $postData;
    }

     /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    /*public function edit($id)
    {
        $action = 'edit';
        $candidate = DB::table('users')->select(DB::raw("*"))->where('user_id','=',$id)->first();
         //dd($candidate);
        return view('admin.candidates-create',compact('candidate','id','action'));
    }*/

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id=1)
    {
        $action='edit';
        // dd($request->all());
        $data = $this->_form_validation($request);
        DB::table('settings')->updateOrInsert(
        ['setting_id' => $id],
        $data);
        // ->where('setting_id',$id)->update();
        $msg="Update Successfully";
        return redirect( config("app.admin_url").'/settings')->with('success','Update Successfully');
    }

}
