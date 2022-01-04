import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import '../models/Videos.dart';
import '../pages/UserProfile.dart';
import '../services/SessionManager.dart';
import '../widgets/globals.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../pages/SlidingUpPanelContainer.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../functions.dart';

class MyFollowingFollowers extends StatefulWidget {
  final int type;
  MyFollowingFollowers(this.type);
  @override
  _MyFollowingFollowersState createState() => _MyFollowingFollowersState();
}

class _MyFollowingFollowersState extends State<MyFollowingFollowers> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  final SessionManager sessions = new SessionManager();
  bool showLoader = false;
  static String followingKeyword = '';
  static String followerKeyword = '';
  int page = 1;
  int totalRecords = 0;
  bool showLoadMore = true;
  VideoModelList followingUsersList;
  VideoModelList followersList;
  int userId = 0;
  String appToken = '';
  bool followUnfollowLoader = false;
  int followUserId = 0;
  int _curIndex;
  var _followingSearch = TextEditingController();
  var _followerSearch = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (this.widget.type == 0) {
      _curIndex = 0;
      followingUsers();
    } else {
      _curIndex = 1;
      followers();
    }
    followingKeyword = '';
    followerKeyword = '';
  }

  static showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  followingLoadMore() async {
    setState(() {
      page = page + 1;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/following-users-list";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "user_id": userId,
            'app_token': appToken,
            'page': page
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            var map = Map<String, dynamic>.from(rs.data);
            var response = VideoModelPageList.fromJson(map);
            VideoModelPageList videoPageList = response;
            var mapVideoPageLst = Map<String, dynamic>.from(videoPageList.data);
            VideoModelList videoModelListMoreData =
                VideoModelList.fromJson(mapVideoPageLst);
            followingUsersList.data.addAll(videoModelListMoreData.data);
            if (followingUsersList.data.length == totalRecords) {
              showLoadMore = false;
            }
          });
        } else {
          print("ERRRRRR1111");
        }
      } else {
        print("ERRRRRR");
      }
      setState(() {
        //showLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  followingUsers() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userId = (pref.getInt('user_id') == null) ? 0 : pref.getInt('user_id');
      appToken = (pref.getString('app_token') == null)
          ? ''
          : pref.getString('app_token');
      page = 1;
      showLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/following-users-list";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "user_id": userId,
            'app_token': appToken,
            'page': 1,
            'search': followingKeyword
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            var map = Map<String, dynamic>.from(rs.data);
            var response = VideoModelPageList.fromJson(map);
            VideoModelPageList videoPageList = response;
            var mapVideoPageLst = Map<String, dynamic>.from(videoPageList.data);
            followingUsersList = VideoModelList.fromJson(mapVideoPageLst);

            _scrollController.addListener(() {
              if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent) {
                if ((followingUsersList.data.length != totalRecords) &&
                    showLoadMore) {
                  followingLoadMore();
                }
              }
            });
          });
        } else {
          print("ERRRRRR1111");
        }
      } else {
        print("ERRRRRR");
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  followersLoadMore() async {
    setState(() {
      page = page + 1;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/followers-list";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "user_id": userId,
            'app_token': appToken,
            'page': page
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            var map = Map<String, dynamic>.from(rs.data);
            var response = VideoModelPageList.fromJson(map);
            VideoModelPageList videoPageList = response;
            var mapVideoPageLst = Map<String, dynamic>.from(videoPageList.data);
            VideoModelList videoModelListMoreData =
                VideoModelList.fromJson(mapVideoPageLst);
            followersList.data.addAll(videoModelListMoreData.data);
            if (followersList.data.length == totalRecords) {
              showLoadMore = false;
            }
          });
        } else {
          print("ERRRRRR1111");
        }
      } else {
        print("ERRRRRR");
      }
      setState(() {
        //showLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  followers() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userId = (pref.getInt('user_id') == null) ? 0 : pref.getInt('user_id');
      appToken = (pref.getString('app_token') == null)
          ? ''
          : pref.getString('app_token');
      page = 1;
      showLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/followers-list";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "user_id": userId,
            'app_token': appToken,
            'page': 1,
            'search': followerKeyword
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            var map = Map<String, dynamic>.from(rs.data);
            var response = VideoModelPageList.fromJson(map);
            VideoModelPageList videoPageList = response;
            var mapVideoPageLst = Map<String, dynamic>.from(videoPageList.data);
            followersList = VideoModelList.fromJson(mapVideoPageLst);

            _scrollController.addListener(() {
              if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent) {
                if ((followersList.data.length != totalRecords) &&
                    showLoadMore) {
                  followersLoadMore();
                }
              }
            });
          });
        } else {
          print("ERRRRRR1111");
        }
      } else {
        print("ERRRRRR");
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  followUnfollowUser(userId, loginUserId, i) async {
    setState(() {
      followUserId = userId;
      followUnfollowLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/follow-unfollow-user";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "follow_by": loginUserId,
            "follow_to": userId,
            "app_token": appToken
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            if (_curIndex == 0) {
              followingUsersList.data[i].followText = rs.data['followText'];
            } else {
              followersList.data[i].followText = rs.data['followText'];
            }
          });
        } else {
          var msg = rs.data['msg'];
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.red),
          );
        }
      } else {
        var msg = rs.data['msg'];
        _scaffoldKey.currentState.showSnackBar(
          Functions.toast(msg, Colors.red),
        );
      }
      setState(() {
        followUnfollowLoader = false;
        followUserId = 0;
      });
    } catch (e) {
      throw (e);
    }
  }

  Widget layout(obj) {
    if (obj != null) {
      if (obj.data.length > 0) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 185,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: obj.data.length,
                  itemBuilder: (context, i) {
                    var fullName = obj.data[i].fname + " " + obj.data[i].lname;
                    return Container(
                      decoration: new BoxDecoration(
                        border: new Border(
                            bottom: new BorderSide(
                                width: 0.2, color: Colors.white)),
                      ),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfile(obj.data[i].userId),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: (obj.data[i].userDP != '')
                                ? Image.network(
                                    obj.data[i].userDP,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: showLoaderSpinner(),
                                      );
                                    },
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  )
                                : Image.asset(
                                    'assets/images/default-user.png',
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  ),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfile(obj.data[i].userId),
                              ),
                            );
                          },
                          child: Text(
                            obj.data[i].username,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        subtitle: Text(
                          fullName,
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                        trailing: GestureDetector(
                            onTap: () {
                              followUnfollowUser(obj.data[i].userId, userId, i);
                            },
                            child: Container(
                              width: 85,
                              height: 26,
                              decoration: (obj.data[i].followText ==
                                      'Following')
                                  ? BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(3),
                                    )
                                  : BoxDecoration(
                                      gradient: Gradients.blush,
                                      borderRadius: BorderRadius.all(
                                          new Radius.circular(5.0)),
                                    ),
                              child: Center(
                                child: ((followUserId != obj.data[i].userId))
                                    ? Text(
                                        obj.data[i].followText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : showLoaderSpinner(),
                              ),
                            )),
                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                    );
                  },
                )),
          ),
        );
      } else {
        if (!showLoader) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 185,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                  Text(
                    "No User Yet",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    } else {
      if (!showLoader) {
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height - 185,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                ),
                Text(
                  "No User Yet",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  // TabController _tabController;
  Widget tabs() {
    return DefaultTabController(
      initialIndex: _curIndex,
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: TabBar(
              onTap: (index) {
                setState(() {
                  followingKeyword = '';
                  followerKeyword = '';
                  _curIndex = index;
                  if (index == 0) {
                    followingUsers();
                  } else {
                    followers();
                  }
                });
              },
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Followings",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Text(
                        "Followers",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 120,
            child: TabBarView(children: [
              Container(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      child: TextField(
                        controller: _followingSearch,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16.0,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          setState(() {
                            followingKeyword = val;
                          });
                          if (val.length > 2) {
                            Timer(Duration(seconds: 2), () {
                              followingUsers();
                            });
                          }
                        },
                        decoration: new InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          hintText: "Search",
                          hintStyle:
                              TextStyle(fontSize: 16.0, color: Colors.white54),
                          contentPadding: EdgeInsets.fromLTRB(2, 15, 0, 0),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0, right: 0),
                            onPressed: () {
                              _followingSearch.clear();
                              setState(() {
                                followingKeyword = '';
                                followingUsers();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: (followingKeyword.length > 0)
                                  ? Colors.white54
                                  : Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  layout(followingUsersList)
                ],
              )),
              Container(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      child: TextField(
                        controller: _followerSearch,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16.0,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          setState(() {
                            followerKeyword = val;
                          });
                          if (val.length > 2) {
                            Timer(Duration(seconds: 2), () {
                              followers();
                            });
                          }
                        },
                        decoration: new InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          hintText: "Search",
                          hintStyle:
                              TextStyle(fontSize: 16.0, color: Colors.white54),
                          contentPadding: EdgeInsets.fromLTRB(2, 15, 0, 0),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0, right: 0),
                            onPressed: () {
                              _followerSearch.clear();
                              setState(() {
                                followerKeyword = '';
                                followers();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: (followerKeyword.length > 0)
                                  ? Colors.white54
                                  : Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  layout(followersList)
                ],
              )),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: ModalProgressHUD(
          inAsyncCall: showLoader,
          progressIndicator: showLoaderSpinner(),
          child: Container(
            color: Color(0XFF15161a),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                  child: Container(
                    height: 24,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                SingleChildScrollView(
                  child: Container(
                    //height: MediaQuery.of(context).size.height,
                    child: tabs(),
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
