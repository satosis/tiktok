import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import '../models/Videos.dart';
import '../pages/SlidingUpPanelContainer.dart';
import '../services/SessionManager.dart';
import '../widgets/globals.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions.dart';

class UsersToFollow extends StatefulWidget {
  final Function updateFollowingVariable;
  UsersToFollow(this.updateFollowingVariable);
  @override
  _UsersToFollowState createState() => _UsersToFollowState();
}

class _UsersToFollowState extends State<UsersToFollow> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  final SessionManager sessions = new SessionManager();
  bool showLoader = false;
  static String searchKeyword = '';
  int page = 1;
  int totalRecords = 0;
  bool showLoadMore = true;
  VideoModelList videoModelList;
  int userId = 0;
  String appToken = '';
  bool followUnfollowLoader = false;
  int followUserId = 0;
  var _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    getData();
    searchKeyword = '';
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

  loadMore() async {
    setState(() {
      page = page + 1;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/most-viewed-video-users";
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
            videoModelList.data.addAll(videoModelListMoreData.data);
            if (videoModelList.data.length == totalRecords) {
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

  getData() async {
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
      String apiUrl = apiUrlRoot + "api/v1/most-viewed-video-users";
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
            'search': searchKeyword
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            var map = Map<String, dynamic>.from(rs.data);
            var response = VideoModelPageList.fromJson(map);
            VideoModelPageList videoPageList = response;
            var mapVideoPageLst = Map<String, dynamic>.from(videoPageList.data);
            videoModelList = VideoModelList.fromJson(mapVideoPageLst);

            _scrollController.addListener(() {
              if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent) {
                if ((videoModelList.data.length != totalRecords) &&
                    showLoadMore) {
                  loadMore();
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
            videoModelList.data[i].followText = rs.data['followText'];
            this.widget.updateFollowingVariable(
                rs.data['is_following_videos'], userId);
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: ModalProgressHUD(
          inAsyncCall: showLoader,
          progressIndicator: showLoaderSpinner(),
          child: SingleChildScrollView(
            child: Container(
              color: Color(0XFF15161a),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 50,
                              child: TextField(
                                controller: _controller,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16.0,
                                ),
                                obscureText: false,
                                keyboardType: TextInputType.text,
                                onChanged: (String val) {
                                  searchKeyword = val;
                                  if (val.length > 2) {
                                    Timer(Duration(seconds: 2), () {
                                      getData();
                                    });
                                  }
                                },
                                decoration: new InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white54, width: 0.3),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white54, width: 0.3),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white54, width: 0.3),
                                  ),
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                      fontSize: 16.0, color: Colors.white54),
                                  //contentPadding:EdgeInsets.all(10),
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.only(bottom: 12),
                                    onPressed: () {
                                      _controller.clear();
                                      getData();
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 13, bottom: 2, left: 15),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Text(
                          'Recommended',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  (videoModelList != null)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 110,
                            child: GridView.builder(
                              controller: _scrollController,
                              primary: false,
                              padding: const EdgeInsets.all(2),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: (itemWidth / itemHeight),
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                crossAxisCount: 3,
                              ),
                              itemCount: videoModelList.data.length,
                              itemBuilder: (BuildContext context, int i) {
                                return AnimationConfiguration.staggeredList(
                                  position: i,
                                  duration: const Duration(milliseconds: 300),
                                  child: SlideAnimation(
                                    verticalOffset: 20.0,
                                    child: FadeInAnimation(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                    videoModelList.data[i])),
                                          );
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: videoModelList
                                                            .data[i].videoGif !=
                                                        ""
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.6),
                                                              blurRadius:
                                                                  3.0, // soften the shadow
                                                              spreadRadius:
                                                                  0.0, //extend the shadow
                                                              offset: Offset(
                                                                0.0, // Move to right 10  horizontally
                                                                0.0, // Move to bottom 5 Vertically
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  videoModelList
                                                                      .data[i]
                                                                      .videoGif,
                                                              placeholder:
                                                                  (context,
                                                                          url) =>
                                                                      Center(
                                                                child:
                                                                    showLoaderSpinner(),
                                                              ),
                                                              fit: BoxFit.cover,
                                                            )),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        child: Image.asset(
                                                          'assets/images/noVideo.jpg',
                                                          fit: BoxFit.fill,
                                                        ),
                                                      )),
                                            Positioned(
                                              bottom: 55,
                                              child: Container(
                                                width: 35.0,
                                                height: 35.0,
                                                decoration: new BoxDecoration(
                                                  borderRadius:
                                                      new BorderRadius.all(
                                                          new Radius.circular(
                                                              100.0)),
                                                  border: new Border.all(
                                                    color: Colors.white,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Container(
                                                  width: 35.0,
                                                  height: 35.0,
                                                  decoration: new BoxDecoration(
                                                    image: new DecorationImage(
                                                        image: (videoModelList
                                                                    .data[i]
                                                                    .userDP !=
                                                                "")
                                                            ? NetworkImage(
                                                                videoModelList
                                                                    .data[i]
                                                                    .userDP,
                                                              )
                                                            : AssetImage(
                                                                'assets/images/default-user.png',
                                                              ),
                                                        fit: BoxFit.contain),
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            new Radius.circular(
                                                                100.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                                bottom: 37,
                                                child: Text(
                                                  videoModelList
                                                      .data[i].username,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontFamily: 'RockWellStd',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            Positioned(
                                              bottom: -5,
                                              child: ButtonTheme(
                                                minWidth: 80,
                                                height: 25,
                                                child: RaisedButton(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.all(0),
                                                  child: Container(
                                                    height: 25,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.0),
                                                        gradient:
                                                            Gradients.blush),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: <Widget>[
                                                          ((followUserId !=
                                                                  videoModelList
                                                                      .data[i]
                                                                      .userId))
                                                              ? Text(
                                                                  videoModelList
                                                                      .data[i]
                                                                      .followText,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        11,
                                                                    fontFamily:
                                                                        'RockWellStd',
                                                                  ),
                                                                )
                                                              : showLoaderSpinner(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    followUnfollowUser(
                                                        videoModelList
                                                            .data[i].userId,
                                                        userId,
                                                        i);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : (!showLoader)
                          ? Center(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height - 360,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              width: 2, color: Colors.grey)),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      "No User Yet",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
