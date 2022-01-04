<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

$adminRoute = config('app.admin_url');

Route::get('v/{video_id}', 'IndexController@showVideo')->name('show-video');

Route::get('/open/app', 'IndexController@index')->name('openmyapp');

Route::group(['prefix'=>$adminRoute,'namespace'=>'Admin','as'=>'admin.'],function(){
	// Route::get('/img', 'ImgController@index')->name('img');
	// Routes without auth check for guest customers
	Route::get('/', 'Auth\LoginController@showLoginForm')->name('login');
	Route::post('/login', 'Auth\LoginController@login')->name('loginPost');
	Route::get('/register', 'Auth\RegisterController@index')->name('register');
	Route::post('/register', 'Auth\RegisterController@register')->name('registerPost'); 
	Route::get('/logout', 'AdminController@logout')->name('logout');

	// Routes with auth check for logged in admin
	Route::group(['middleware' => 'auth:admin'], function()
	{	
	 	Route::get('/dashboard', 'AdminController@index')->name('dashboard');
	 	Route::get('/change_password/', 'AdminController@changePassword')->name('change_password.index');
	    Route::post('/update_password/', 'AdminController@updatePassword')->name('change_password.update');

	    // categories management system ( Listing, Add, Edit, Delete , Copy )
    	Route::resource('categories', 'CategoryController');
		Route::post('/categories/delete','CategoryController@delete')->name('categories_delete');
		Route::get('/categories/create/{category_id?}', 'CategoryController@create')->name('categories_create');
		Route::get('/categories/{category_id}/view', 'CategoryController@view')->name('categories_view');
        Route::get('/categories/{category_id}/copy', 'CategoryController@copyContent')->name('categories_copy');
        Route::get('/categories/{category_id}/edit', 'CategoryController@edit')->name('categories_edit');
		Route::post('/categories/server_processing','CategoryController@serverProcessing')->name('categories_server_processing');
		
		Route::resource('sounds', 'SoundController');
		Route::post('/sounds/delete','SoundController@delete')->name('sounds_delete');
		Route::post('/sounds/select_cat','SoundController@select_cat')->name('sounds_select_cat');
		Route::post('/sounds/create','SoundController@create')->name('sounds_create');
		Route::get('/sounds/{user_id}/copy', 'SoundController@copyContent')->name('sounds_copy');
		Route::get('/sounds/{user_id}/view', 'SoundController@view')->name('sounds_view');
		Route::get('/sounds/detail/{payment_id}', 'SoundController@detail')->name('sounds_detail');
		Route::post('/sounds/server_processing','SoundController@serverProcessing')->name('sounds_server_processing');
		Route::post('/sounds/audio_play','SoundController@audio_play')->name('audio_play');

		Route::resource('videos', 'VideoController');
		Route::post('/videos/delete','VideoController@delete')->name('videos_delete');
		Route::post('/videos/create','VideoController@create')->name('videos_create');
		Route::get('/videos/{user_id}/view','VideoController@view')->name('videos_view');
		Route::get('/videos/{user_id}/edit','VideoController@edit')->name('videos_edit');
		Route::get('/videos/{user_id}/copy', 'VideoController@copyContent')->name('videos_copy');
		Route::post('/videos/server_processing','VideoController@serverProcessing')->name('videos_server_processing');

        Route::resource('tags', 'TagController');
		Route::post('/tags/delete','TagController@delete')->name('tags_delete');
		Route::post('/tags/create','TagController@create')->name('tags_create');
		Route::get('/tags/{user_id}/view','TagController@view')->name('tags_view');
		Route::get('/tags/{user_id}/edit','TagController@edit')->name('tags_edit');
		Route::get('/tags/{user_id}/copy', 'TagController@copyContent')->name('tags_copy');
		Route::post('/tags/server_processing','TagController@serverProcessing')->name('tags_server_processing');
		
		Route::resource('candidates', 'CandidateController');
		Route::post('/candidates/delete','CandidateController@delete')->name('candidates_delete');
		Route::get('/candidates/copy/{user_id}', 'CandidateController@copyContent')->name('candidates_copy');
		Route::get('/candidates/view/{user_id?}', 'CandidateController@view')->name('candidates_view');
		Route::get('/candidates/edit/{user_id?}', 'CandidateController@edit')->name('candidates_edit');
		Route::get('/candidates/{action?}/view/{user_id?}', 'CandidateController@view')->name('candidates_view');
		Route::get('/candidates/{action?}/edit/{user_id?}', 'CandidateController@edit')->name('candidates_edit');
		Route::get('/candidates/{action?}/photos/{user_id?}', 'CandidateController@photos')->name('candidates_photos');
		Route::get('/candidates/{action?}/videos/{user_id?}', 'CandidateController@videos')->name('candidates_videos');
		Route::get('/candidates/{action?}/audios/{user_id?}', 'CandidateController@audios')->name('candidates_audios');
		Route::get('/candidates/inactive/{user_id}', 'CandidateController@inactive')->name('candidates_inactive');
		Route::get('/candidates/active/{user_id}', 'CandidateController@active')->name('candidates_active');
		Route::post('/candidates/server_processing','CandidateController@serverProcessing')->name('candidates_server_processing');
		Route::get('/candidates/changePassword/{user_id}', 'CandidateController@changePassword')->name('candidates_changePassword');
		Route::post('/candidates/updatePassword/{user_id}', 'CandidateController@updatePassword')->name('candidates_updatePassword');
		Route::post('/candidates/loadMore','CandidateController@loadMore')->name('candidates_loadMore');
		Route::post('/candidates/loadMoreVideos','CandidateController@loadMoreVideos')->name('candidates_loadMoreVideos');
		Route::post('/candidates/loadMoreAudios','CandidateController@loadMoreAudios')->name('candidates_loadMoreAudios');

		
		Route::resource('settings', 'SettingController');
		Route::get('/settings/{setting_id}/edit', 'SettingController@index')->name('settings.index');
	    Route::post('/settings/delete','SettingController@delete')->name('settings_delete');
        Route::get('/settings/copy/{msg_id}', 'SettingController@copyContent')->name('settings_copy');
		Route::post('/settings/server_processing','SettingController@serverProcessing')->name('settings_server_processing');
		
		Route::get('export', 'ImportController@export')->name('export');
		Route::get('importExportView', 'ImportController@importExportView')->name('exportView');
		Route::post('import', 'ImportController@import')->name('import');
		
		Route::resource('reports', 'ReportController');
		Route::post('/reports/server_processing','ReportController@serverProcessing')->name('reports_server_processing');
		
	});    

});