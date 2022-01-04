<?php

use Illuminate\Database\Seeder;

class UsersTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        \DB::table('users')->delete();
        
        \DB::table('users')->insert(array (
            0 => 
            array (
                'user_id' => 1,
                'username' => 'user1001',
                'fname' => 'Unify',
                'lname' => 'Softtech',
                'email' => 'unifysofttech@admin.com',
                'mobile' => '9876543210',
                'gender' => 'm',
                'bio' => NULL,
                'user_dp' => 'https://lh3.googleusercontent.com/a-/AOh14Ggp-Dae6G9nl66wpK57Oe3FlWWEvu6XEVDo9GJz=s96-c',
                'password' => '',
                'dob' => '1970-01-01',
                'country' => '',
                'languages' => '',
                'app_token' => '$2y$10$Yg1sehsi1sosm9kgbsFbkuxLWi1ooWd0Y5dhtredEsKmolpY2F9Fi',
                'login_type' => 'G',
                'time_zone' => '',
                'player_id' => '',
                'ios_uuid' => '',
                'verification_code' => '',
                'verification_time' => NULL,
                'active' => 1,
                'deleted' => 0,
                'last_active' => NULL,
                'created_at' => '2020-07-28 04:39:54',
                'updated_at' => '2020-07-28 04:39:54',
            ),
            1 => 
            array (
                'user_id' => 2,
                'username' => 'user1002',
                'fname' => 'sarita',
                'lname' => 'kumari',
                'email' => 'sarita.unify@gmail.com',
                'mobile' => '',
                'gender' => 'f',
                'bio' => NULL,
                'user_dp' => 'https://lh3.googleusercontent.com/-06V8gf2RefQ/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucnafk1qYb1WKHdRu6G1vnSVTezZnw/s96-c/photo.jpg',
                'password' => '',
                'dob' => '1992-04-22',
                'country' => '',
                'languages' => '',
                'app_token' => '$2y$10$ZpGNnpiSOmH8nczo8Ij8g.cRMUl6YEpDkPimiMrccVJdH8jzBfqQm',
                'login_type' => 'G',
                'time_zone' => '',
                'player_id' => '',
                'ios_uuid' => '',
                'verification_code' => '',
                'verification_time' => NULL,
                'active' => 1,
                'deleted' => 0,
                'last_active' => NULL,
                'created_at' => '2020-09-28 12:27:55',
                'updated_at' => '2020-09-28 12:27:55',
            ),
            2 => 
            array (
                'user_id' => 3,
                'username' => 'user1003',
                'fname' => 'Sarita',
                'lname' => 'Sahota',
                'email' => 'saritasahota@ymail.com',
                'mobile' => '',
                'gender' => '',
                'bio' => NULL,
                'user_dp' => 'https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=3231753506947939&height=720&width=720&ext=1603955414&hash=AeR-87WyZF-hRLfs',
                'password' => '',
                'dob' => NULL,
                'country' => '',
                'languages' => '',
                'app_token' => '$2y$10$u988r5IvhsiP9.iHT.7i.OPEQMuKvsBUZGeA23Y.5ASqrLLEXLT9C',
                'login_type' => 'FB',
                'time_zone' => '',
                'player_id' => '',
                'ios_uuid' => '',
                'verification_code' => '',
                'verification_time' => NULL,
                'active' => 1,
                'deleted' => 0,
                'last_active' => NULL,
                'created_at' => '2020-09-29 07:10:15',
                'updated_at' => '2020-09-29 07:10:15',
            ),
        ));
        
        
    }
}