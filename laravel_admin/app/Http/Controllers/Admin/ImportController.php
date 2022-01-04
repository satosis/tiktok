<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Http\Request;
use App\Imports\SoundsImport;
use Maatwebsite\Excel\Facades\Excel;
  

class ImportController extends BaseController
{
    
    /**
    * @return \Illuminate\Support\Collection
    */
    public function importExportView()
    {
       return view('import');
    }
   
    /**
    * @return \Illuminate\Support\Collection
    */
    public function export() 
    {
        return Excel::download(new SoundsImport, 'users.xlsx');
    }
   
    /**
    * @return \Illuminate\Support\Collection
    */
    public function import() 
    {  
        $data = Excel::toArray(new SoundsImport, request()->file('file')); 
        collect(head($data))
        ->each(function ($row, $key) {
         if($row[0]>0){
            \DB::table('sounds')
                ->where('sound_id', $row[0])
                ->update(['title'=>($row[1]!=null)?$row[1] : '','tags'=>($row[4]!=null)?$row[4]:'','album'=>($row[5]!=null)?$row[5]:'','active'=>($row[6]!=null && $row[6]!=0)?$row[6]:0]);
         }
            
        });
        //exit;
        return back();
    }
}
