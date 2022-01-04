import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  //Auth Token
  final String appToken = "";

  Future<Map> getUserInfo() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int userId, _active;
    String uniqueId,
        userDp,
        _email,
        _mobile,
        _name,
        _username,
        _gender,
        _dob,
        _country,
        _languages,
        playerId,
        timeZone,
        loginType,
        lastActive,
        appToken;

    uniqueId = (pref.getString("unique_id") ?? "");
    userId = (pref.getInt("user_id") ?? 0);
    userDp = pref.getString("user_dp") ?? "";
    _email = pref.getString("email") ?? "";
    _mobile = pref.getString("mobile") ?? "";
    _name = pref.getString("name") ?? "";
    _username = pref.getString("username") ?? "";
    _gender = pref.getString("gender") ?? "";
    _dob = pref.getString("dob") ?? "";
    _country = pref.getString("country") ?? "";
    _languages = pref.getString("languages") ?? "";
    playerId = pref.getString("player_id") ?? "";
    _active = (pref.getInt("active") ?? 0);
    timeZone = pref.getString("time_zone") ?? "";
    loginType = pref.getString("login_type") ?? "";
    lastActive = pref.getString("last_active") ?? "";
    appToken = pref.getString("app_token") ?? "";

    var user = new Map();
    user['unique_id'] = uniqueId;
    user['user_id'] = userId;
    user['user_dp'] = userDp;
    user['email'] = _email;
    user['mobile'] = _mobile;
    user['name'] = _name;
    user['username'] = _username;
    user['gender'] = _gender;
    user['dob'] = _dob;
    user['country'] = _country;
    user['languages'] = _languages;
    user['player_id'] = playerId;
    user['active'] = _active;
    user['time_zone'] = timeZone;
    user['login_type'] = loginType;
    user['last_active'] = lastActive;
    user['app_token'] = appToken;
    return user;
  }

  /// ----------------------------------------------------------
  /// UserInfo
  /// ----------------------------------------------------------
  /*Future<void> setUserInfo(UserInfo mUser) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(is_vsm, mUser.is_vsm);
    prefs.setInt(last_active, mUser.last_active);
    prefs.setString(user_city_id, mUser.user_city_id);
    prefs.setString(user_company, mUser.user_company);
    prefs.setString(user_company_id, mUser.user_company_id);
    prefs.setString(user_country_id, mUser.user_country_id);
    prefs.setString(user_dp, mUser.user_dp);
    prefs.setString(user_email, mUser.user_email);
    prefs.setString(user_id, mUser.user_id);
    prefs.setString(user_membership, mUser.user_membership);
    prefs.setString(user_mobile, mUser.user_mobile);
    prefs.setString(user_name, mUser.user_name);
    prefs.setString(username, mUser.username);
    prefs.setString(user_status, mUser.user_status);
  }

  //NewUser=======================================================
  Future<NewUser> getNewUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool by_admin, company_edit, default_dp, no_following;

    by_admin = pref.getBool(this.by_admin) ?? null;
    company_edit = pref.getBool(this.company_edit) ?? null;
    default_dp = pref.getBool(this.default_dp) ?? null;
    no_following = pref.getBool(this.no_following) ?? null;

    NewUser user = new NewUser();
    user.by_admin = by_admin;
    user.company_edit = company_edit;
    user.default_dp = default_dp;
    user.no_following = no_following;
    return user;
  }

  Future<void> setNewUser(NewUser mUser) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(by_admin, mUser.by_admin);
    prefs.setBool(company_edit, mUser.company_edit);
    prefs.setBool(default_dp, mUser.default_dp);
    prefs.setBool(no_following, mUser.no_following);
  }

  //auth token=======================================================

  Future<String> getAuthToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String auth_token;
    auth_token = pref.getString(this.auth_token) ?? null;
    return auth_token;
  }



  //fcm token
  Future<String> getFCMToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String auth_token;
    auth_token = pref.getString(this.fcm_token) ?? null;
    return auth_token;
  }

  Future<void> setFCMToken(String fcm_token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.fcm_token, fcm_token);
  }

  _checkUser(BuildContext context) async {
    SessionManager prefs = await SessionManager();
    Future<UserInfo> mUserInfoCall = prefs.getUserInfo();
    mUserInfoCall.then((onValue) {
      if (onValue.user_id != null) {
        Navigator.pushReplacementNamed(context, '/AlreadyLoggedIn');
      } else {
        Navigator.pushReplacementNamed(context, '/Login');
      }
    }, onError: (e) {
      print(e);
    });
  }*/

  Future<void> setAuthToken(String authToken) async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString(this.auth_token, auth_token);
  }

  onLogout(BuildContext context) async {
    setAuthToken(null);
//    _checkUser(context);
  }
}
