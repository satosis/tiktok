<?php

use Illuminate\Database\Seeder;

class AdminTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('admin')->delete();
        
        \DB::table('admin')->insert(array (
            0 => 
            array (
                'admin_id' => 3,
                'name' => 'admin',
                'email' => 'admin@gmail.com',
                'password' => '$2y$10$vhTsG97FHYrdVAvEDyZEf.irGwfZV2/TvWdbf7MZqjYwkjhRszYFu',
                'remember_token' => NULL,
                'created_at' => '2019-06-20 07:56:10',
                'updated_at' => '2019-06-20 07:56:10',
            ),
        ));
        
        
    }
}