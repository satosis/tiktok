<?php

use Illuminate\Database\Seeder;

class VideoTagsTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('video_tags')->delete();
        
        \DB::table('video_tags')->insert(array (
            0 => 
            array (
                'tag_id' => 1,
                'tag' => '#dance',
                'banner' => '20200728074305_just-dance-2020-hero-video-fallback-01-ps4-us-07jun19.jpg',
            ),
            1 => 
            array (
                'tag_id' => 2,
                'tag' => '#Girls',
                'banner' => '20200728074321_MG_Tour_Banner.jpg',
            ),
            2 => 
            array (
                'tag_id' => 3,
                'tag' => '#welcome',
                'banner' => '20200728074340_1614f51978b3242e550365956583.png',
            ),
        ));
        
        
    }
}