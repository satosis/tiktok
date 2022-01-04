<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: user,key,token,Content-Type, x-xsrf-token");
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');


Route::group(['prefix' => 'v1','namespace'=>'API'],function(){
    Route::post('install-url', 'InstallerController@storeUrl')->name('storeUrl');
	Route::group(['middleware' => 'api_check'], function(){
		Route::post('register', 'RegisterController@index')->name('user_register');
		Route::post('login', 'RegisterController@login')->name('login');
		Route::post('resend_otp', 'RegisterController@resend_otp')->name('resend_otp');
		Route::post('register-social', 'RegisterController@socialLogin')->name('user_register_social');
		Route::post('verify-otp', 'RegisterController@verifyOtp')->name('verify_otp');
		Route::get('get-sounds', 'SoundController@index')->name('get_sounds');
		Route::get('fav-sounds', 'SoundController@favSounds')->name('get_fav_sounds');
		Route::post('set-fav-sound', 'SoundController@setFavSound')->name('set_fav_sound');
		Route::get('get-videos', 'VideoController@index')->name('get_videos');
		Route::get('user_information', 'RegisterController@fetchUserInformation')->name('user_information');
		Route::post('update_user_information', 'RegisterController@updateUserInformation')->name('update_user_information');
		Route::post('update_profile_pic', 'UserController@updateUserProfilePic')->name('update_profile_pic');
		Route::post('upload-video', 'VideoController@uploadVideo')->name('upload-video');
		Route::post('fetch-user-info', 'UserController@fetchUserInformation')->name('fetch-user-info');
		Route::post('fetch-login-user-info', 'UserController@fetchLoginUserInformation')->name('fetch-login-user-info');
		Route::post('video-like', 'VideoController@videoLikes')->name('video-like');
		Route::post('fetch-video-comments', 'VideoController@fetchVideoComments')->name('fetch-video-comments');
		Route::post('add-comment', 'VideoController@addComment')->name('add-comment');
		Route::post('follow-unfollow-user', 'UserController@followUnfollowUser')->name('follow-unfollow-user');
		Route::post('video-upload-2', 'VideoController@uploadVideo2')->name('video-upload-2');
		Route::post('filter-video-upload', 'VideoController@filterUploadVideo')->name('filter-video-upload');
		Route::post('hash-tag-videos', 'VideoController@hashTagVideos')->name('hash-tag-videos');
		Route::post('video-views', 'VideoController@video_views')->name('video-views');
		Route::post('video-enabled', 'VideoController@video_enabled')->name('video-enabled');
		Route::post('delete-video', 'VideoController@deleteVideo')->name('delete-video');
		Route::post('most-viewed-video-users', 'VideoController@mostViewedVideoUsers')->name('most-viewed-video-users');
		Route::post('following-users-list', 'UserController@FollowingUsersList')->name('following-users-list');
		Route::post('followers-list', 'UserController@FollowersList')->name('followers-list');
		Route::post('get-unique-id', 'UserController@unique_user_id')->name('get-unique-id');
		Route::post('get-sound', 'SoundController@getSound')->name('get-sound');
		Route::get('get-cat-sounds', 'SoundController@getCategorySounds')->name('get-cat-sounds');
		Route::post('submit-report', 'UserController@submitReport')->name('submit-report');
		Route::post('delete-comment', 'UserController@deleteComment')->name('delete-comment');
		Route::post('block-user', 'UserController@blockUser')->name('block-user');
	});
});
