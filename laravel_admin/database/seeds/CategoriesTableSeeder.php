<?php

use Illuminate\Database\Seeder;

class CategoriesTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('categories')->delete();
        
        \DB::table('categories')->insert(array (
            0 => 
            array (
                'cat_id' => 12,
                'cat_name' => 'Funny English',
                'rank' => 9,
                'added_on' => '2020-08-11 10:57:34',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            1 => 
            array (
                'cat_id' => 11,
                'cat_name' => 'Funny Mix',
                'rank' => 8,
                'added_on' => '2020-08-11 10:51:48',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            2 => 
            array (
                'cat_id' => 4,
                'cat_name' => 'TV Ads',
                'rank' => 3,
                'added_on' => '2020-08-04 06:04:57',
                'parent_id' => 0,
                'deleted' => 0,
            ),
            3 => 
            array (
                'cat_id' => 5,
                'cat_name' => 'Bollywood Dialog',
                'rank' => 4,
                'added_on' => '2020-08-04 08:29:49',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            4 => 
            array (
                'cat_id' => 6,
                'cat_name' => 'Bollywood Songs',
                'rank' => 5,
                'added_on' => '2020-08-05 10:55:10',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            5 => 
            array (
                'cat_id' => 9,
                'cat_name' => 'Random Hits',
                'rank' => 6,
                'added_on' => '2020-08-10 13:11:28',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            6 => 
            array (
                'cat_id' => 10,
                'cat_name' => 'Instrumental',
                'rank' => 7,
                'added_on' => '2020-08-11 09:31:01',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            7 => 
            array (
                'cat_id' => 13,
                'cat_name' => 'Hip Hop',
                'rank' => 10,
                'added_on' => '2020-08-12 11:50:23',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            8 => 
            array (
                'cat_id' => 14,
                'cat_name' => 'All Time Hit',
                'rank' => 11,
                'added_on' => '2020-08-12 11:53:57',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            9 => 
            array (
                'cat_id' => 15,
                'cat_name' => 'Horror',
                'rank' => 12,
                'added_on' => '2020-08-12 11:55:21',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            10 => 
            array (
                'cat_id' => 17,
                'cat_name' => 'World Cup Fifa',
                'rank' => 14,
                'added_on' => '2020-08-12 12:00:58',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            11 => 
            array (
                'cat_id' => 18,
                'cat_name' => 'WWE',
                'rank' => 15,
                'added_on' => '2020-08-12 12:02:48',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            12 => 
            array (
                'cat_id' => 19,
                'cat_name' => 'Superhit Hip Hop',
                'rank' => 16,
                'added_on' => '2020-08-12 12:05:33',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            13 => 
            array (
                'cat_id' => 20,
                'cat_name' => 'Punjabi',
                'rank' => 17,
                'added_on' => '2020-08-12 12:09:22',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
            14 => 
            array (
                'cat_id' => 21,
                'cat_name' => 'English',
                'rank' => 18,
                'added_on' => '2020-08-13 09:58:55',
                'parent_id' => NULL,
                'deleted' => 0,
            ),
        ));
        
        
    }
}