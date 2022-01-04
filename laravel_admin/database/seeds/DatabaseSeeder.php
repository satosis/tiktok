<?php

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // $this->call(UserSeeder::class);
        $this->call(UsersTableSeeder::class);
        $this->call(AdminTableSeeder::class);
        $this->call(SoundsTableSeeder::class);
        $this->call(VideosTableSeeder::class);
        $this->call(VideoTagsTableSeeder::class);
        $this->call(CategoriesTableSeeder::class);
        $this->call(FailedJobsTableSeeder::class);
    }
}
