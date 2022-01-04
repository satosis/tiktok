import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:video_player/video_player.dart';

import '../functions.dart';
import '../models/Videos.dart';
import '../services/SessionManager.dart';
import '../widgets/globals.dart';
import '../widgets/video_description.dart';
import 'Comments.dart';
import 'HashVideos.dart';
import 'LoginSlide.dart';
import 'MyProfile.dart';
import 'UserProfile.dart';
import 'UsersToFollow.dart';
import 'VideoPlayer.dart';
import 'VideoRecorder.dart';

/*class HomePage extends StatelessWidget {
  final VideoModel video;
  HomePage([this.video]);
  static bool isOpened = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[200],
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.black,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SlidingUpPanel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SlideUpContainer(this.video),
    );
  }
}*/

class HomePage extends StatefulWidget {
  final VideoModel video;
  HomePage([this.video]);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // final double _initFabHeight = 50.0;
  // double _fabHeight;
  // double _panelHeightOpen;
  // double _panelHeightClosed = 20.0;
  int videoId = 0;
  PanelController _pc = new PanelController();
  PanelController _pc2 = new PanelController();
  PanelController _pc3 = new PanelController();
  VideoPlayerController videoController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  //homepage Varaible
  int _active;
  var jsonData;
  var _getVideoResult;
  // var _playVideo;
  bool allPaused;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  bool likeShowLoader = false;
  int index = 1;
  int totalRows = 0;
  int nosVideos = 0;
  int page = 1;
  int loginUserId = 0;
  String appToken = '';
  List videoList = [];
  var response;
  int following = 0;
  int isFollowingVideos = 0;
  VideoModelList videoModelList;
  bool userFollowSuggestion = false;
  bool showFollowingPage = false;
  bool isLoggedIn = false;
  String totalLikes = '0';
  bool isLiked = false;
  bool videoInitialized = false;
  AnimationController animationController;
  final SessionManager sessions = new SessionManager();
  //homepage Varaible end
  //action bar variable
  static const double ActionWidgetSize = 60.0;
  static const double ProfileImageSize = 50.0;
  // static const double PlusIconSize = 20.0;
  int soundId = 0;
  int userId = 0;
  String totalComments = '0';
  String userDP = '';
  String soundImageUrl = '';
  int isFollowing = 0;
  bool followUnfollowLoader = false;
  String encodedVideoId = '';
  String selectedType;
  String encKey = 'yfmtythd84n4h';
  String description = '';
  List<String> reportType = [
    "It's spam",
    "It's inappropriate",
    "I don't like it"
  ];
  // bool _validate = false;
  GlobalKey<FormState> _key = new GlobalKey();

  bool videoStarted = true;

  int swiperIndex = 0;
  bool initializePage = true;

  SwiperController swipeController;
  setVideoController(vController) {
    print("setVideoControllerabc");
    print(vController);
//    setState(() {
    videoController = vController;
//    });
//    if (videoController.value.position > Duration(seconds: 0)) {
  }

  //action bar variable end
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

  //homepage functions
  LinearGradient get musicGradient => LinearGradient(colors: [
        Colors.grey[800],
        Colors.grey[900],
        Colors.grey[900],
        Colors.grey[800]
      ], stops: [
        0.0,
        0.4,
        0.6,
        1.0
      ], begin: Alignment.bottomLeft, end: Alignment.topRight);
  formSubmitApi(index) async {
    VideoModel videoObject = videoList[index];
    setState(() {
      showLoader = true;
    });

    Dio dio = new Dio(); // with default Options
    dio.options.baseUrl = apiUrlRoot;
    final response = await dio.post("api/v1/submit-report",
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        queryParameters: {
          "user_id": loginUserId,
          "app_token": appToken,
          "video_id": videoObject.videoId,
          "type": selectedType,
          "description": description
        });
    if (response.statusCode == 200) {
      var jsonData = response.data;
      if (jsonData['status'] == "success") {
        Navigator.pop(context);
        var msg = jsonData['msg'];
        Scaffold.of(context).showSnackBar(
          Functions.toast(msg, Colors.green),
        );
      } else {}
      setState(() {
        showLoader = false;
      });
    }
  }

  likeVideo(index) async {
    VideoModel videoObject = videoList[index];
    setState(() {
      likeShowLoader = true;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/video-like";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "user_id": loginUserId,
            "app_token": appToken,
            "video_id": videoObject.videoId
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalLikes = rs.data['total_likes'].toString();
            isLiked = (rs.data['is_like'] > 0) ? true : false;
            updateLike(videoObject.videoId, rs.data['is_like'], totalLikes);
          });
        } else {
          print("3334");
        }
      } else {}
      setState(() {
        likeShowLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  followUnfollowUser(index) async {
    VideoModel videoObject = videoList[index];
    setState(() {
      followUnfollowLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/follow-unfollow-user";
      var rs = await Dio().post(
        apiUrl,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        queryParameters: {
          "follow_by": loginUserId,
          "follow_to": videoObject.userId,
          "app_token": appToken
        },
      );
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            videoObject.isFollowing = rs.data['is_following_videos'];
            isFollowing = rs.data['is_following_videos'];
            this.updateFollowingVariable(
                isFollowing, videoObject.userId, false);
          });
        } else {
          // var msg = rs.data['msg'];
        }
      } else {
        // var msg = rs.data['msg'];
      }
      setState(() {
        followUnfollowLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  takeActionFromUserProfile(value, type) {
    VideoModel videoObj = videoList[index];
    setState(() {
      if (type == 'popup') {
        videoController.pause();
        _pc3.open();
      } else {
        updateFollowingVariable(value, videoObj.userId, false);
      }
    });
  }

  updateCommentsCount(count, videoId) {
    final tile = this.videoList.firstWhere((item) => item.videoId == videoId);
    setState(() {
      totalComments = count;
      tile.totalComments = count;
    });
  }

  void updateLike(int videoId, int liked, String totalLikes) {
    final tile = this.videoList.firstWhere((item) => item.videoId == videoId);
    setState(() {
      tile.likeId = liked;
      tile.totalLikes = totalLikes;
    });
  }

  Widget sidebar(index) {
    VideoModel videoObj = videoList[index];
    isLiked = (videoObj.likeId > 0) ? true : false;
    totalLikes = videoObj.totalLikes;
    totalComments = videoObj.totalComments;
    isFollowing = videoObj.isFollowing;
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    encodedVideoId =
        stringToBase64.encode(encKey + videoObj.videoId.toString());
    return Container(
      width: 70.0,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 70.0,
            ),
            GestureDetector(
              onTap: () {
                videoController.pause();
                /* if (videoStarted) { */
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => (videoObj.userId != loginUserId)
                        ? UserProfile(
                            videoObj.userId, takeActionFromUserProfile)
                        : MyProfile(),
                  ),
                );
                /* } else {} */
              },
              child: Container(
                height: 55.0,
                width: 50.0,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      bottom: 10,
                      child: Container(
                        height: 45.0,
                        width: 45.0,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffffffff).withOpacity(0.5),
                              spreadRadius: 6,
                              blurRadius: 6,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(50),
                          image: new DecorationImage(
                            image:
                                new CachedNetworkImageProvider(videoObj.userDP),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    (videoObj.userId != loginUserId)
                        ? Positioned(
                            bottom: 0,
                            left: 13,
                            child: GestureDetector(
                              onTap: () {
                                /* if (videoStarted) { */
                                setState(() {
                                  if (loginUserId > 0) {
                                    followUnfollowUser(index);
                                  } else {
                                    videoController.pause();
                                    _pc3.open();
                                  }
                                });
                                /* } else {} */
                              },
                              child: (!followUnfollowLoader)
                                  ? (isFollowing == 0)
                                      ? Image.asset(
                                          'assets/icons/plus-icon.png',
                                          width: 22,
                                        )
                                      : Image.asset(
                                          'assets/icons/chk-icon.png',
                                          width: 22,
                                        )
                                  : showLoaderSpinner(),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.transparent,
              height: 10,
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                alignment: Alignment.bottomCenter,
                padding:
                    EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                icon: (isLiked)
                    ? (!likeShowLoader)
                        ? Image.asset(
                            'assets/icons/like.png',
                            width: 30.0,
                          )
                        : showLoaderSpinner()
                    : (!likeShowLoader)
                        ? Image.asset(
                            'assets/icons/unlike.png',
                            width: 30.0,
                          )
                        : showLoaderSpinner(),
                onPressed: () {
                  /* if (videoStarted) { */
                  setState(() {
                    if (isLoggedIn) {
                      likeVideo(index);
                    } else {
                      videoController.pause();
                      _pc3.open();
                    }
                  });
                  /* } else {} */
                },
              ),
            ),
            Divider(
              color: Colors.transparent,
              height: 5.0,
            ),
            Text(
              totalLikes,
              style: TextStyle(
                  color: Colors.white.withOpacity(1),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(
                        top: 9, bottom: 6, left: 5.0, right: 5.0),
                    icon: Image.asset(
                      'assets/icons/comment-details.png',
                      width: 30.0,
                    ),
                    onPressed: () {
                      /* if (videoStarted) { */

                      if (isLoggedIn) {
                        videoController.pause();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Comments(videoObj, this.updateCommentsCount),
                          ),
                        );
                      } else {
                        videoController.pause();
                        _pc3.open();
                      }
                      /* } else {} */
                    },
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 5.0,
                ),
                Text(
                  totalComments,
                  style: TextStyle(
                      color: Colors.white.withOpacity(1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                alignment: Alignment.topCenter,
                icon: Image.asset(
                  'assets/icons/share.png',
                  width: 30.0,
                ),
                onPressed: () {
                  /* if (videoStarted) { */
                  final RenderBox box = context.findRenderObject();
                  Share.share(
                    apiUrlRoot + 'v/$encodedVideoId',
                    subject: "Share Video - Leuke",
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size,
                  );
                  /* } else {} */
                },
              ),
            ),
            Divider(
              color: Colors.transparent,
              height: 5.0,
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        _getMusicPlayerAction(index),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                alignment: Alignment.topCenter,
                icon: Icon(Icons.report_problem, size: 23, color: Colors.white),
                onPressed: () {
                  /* if (videoStarted) { */
                  selectedType = null;
                  description = '';
                  if (isLoggedIn) {
                    reportLayout(context, index);
                  } else {
                    videoController.pause();
                    _pc3.open();
                  }
                  /* } else {} */
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }

  validateForm(index) {
    if (_key.currentState.validate()) {
      //no any error in validation..
      _key.currentState.save();
      formSubmitApi(index);
    } else {
      //validation error..
      setState(() {
        // _validate = true;
      });
    }
  }

  void reportLayout(context, index) {
    var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: true,
        descStyle: TextStyle(fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 400),
        titleStyle: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontFamily: 'QueenCamelot',
        ),
        constraints:
            BoxConstraints.expand(width: MediaQuery.of(context).size.width));
    Alert(
        context: context,
        style: alertStyle,
        title: "REPORT",
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            // autovalidate: _validate,
            key: _key,
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Color(0xffffffff),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          hint: new Text("Select Type",
                              textAlign: TextAlign.center),
                          iconEnabledColor: Colors.black,
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                          value: selectedType,
                          onChanged: (newValue) {
                            setState(() {
                              selectedType = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'This field is required!' : null,
                          items: reportType.map((String val) {
                            return new DropdownMenuItem(
                              value: val,
                              child: new Text(
                                val,
                                style: new TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  onChanged: (String val) {
                    description = val;
                  },
                ),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              validateForm(index);
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            gradient: Gradients.blush,
          ),
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            gradient: Gradients.blush,
          )
        ]).show();
  }

  _getVideos() async {
    print("_getVideos()");
    setState(() {
      showLoader = true;
    });
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = 0;
    int videoId = 0;
    if (widget.video != null) {
      userId = widget.video.userId;
      videoId = widget.video.videoId;
    }
    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    try {
      var response = await dio.get("api/v1/get-videos",
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "page_size": 10,
            "search": "",
            "page": page,
            "user_id": userId,
            "video_id": videoId,
            "login_id":
                (pref.getInt('user_id') == null) ? 0 : pref.getInt('user_id'),
            "following": following,
          });
      if (response.data['status'] == 'success') {
        isFollowingVideos = response.data['is_following_videos'];
        jsonData = response.data;
        print("jsonData");
        print(jsonData);
        var map = Map<String, dynamic>.from(jsonData);
        var res = VideoModelPageList.fromJson(map);
        VideoModelPageList videoPageList = res;
        var mapVideoPageLst = Map<String, dynamic>.from(videoPageList.data);
        videoModelList = VideoModelList.fromJson(mapVideoPageLst);
        videoList.addAll(videoModelList.data);
        onVideoChange(videoList[0]);
        setState(() {
          totalRows = videoModelList.total;
          nosVideos = videoList.length;
          showLoader = false;
          userFollowSuggestion = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  updateFollowingVariable(value, usrId, [isReload = true]) {
    setState(() {
      isFollowingVideos = value;
      if (isFollowingVideos == 1) {
        for (var item in videoModelList.data) {
          if (usrId == item.userId) {
            item.isFollowing = 1;
          }
        }
        following = 1;
        if (isReload) {
          showFollowingPage = false;
          userFollowSuggestion = false;
          _active = 1;
          videoList = [];
          _getVideos();
        }
      } else {
        for (var item in videoModelList.data) {
          if (usrId == item.userId) {
            item.isFollowing = 0;
          }
        }
        following = 0;
        if (isReload) {
          showFollowingPage = true;
          userFollowSuggestion = true;
          _active = 2;
          videoList = [];
          _getVideos();
        }
      }
    });
  }
  //homepage functions end

  // Bottom toolBar variables

  onVideoChange(VideoModel video) {
    setState(() {
      videoId = video.videoId;
    });
  }

  _onWillPop() {
    Dialog fancyDialog = Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Container(
        height: 210.0,
        width: 300.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          //color: Colors.white,
          borderRadius: BorderRadius.all(new Radius.circular(12.0)),
        ),
        child: Column(
          children: <Widget>[
            Container(
                height: 150,
                decoration: BoxDecoration(
                  //color: Color(0xff2e2f34),
                  borderRadius: BorderRadius.all(new Radius.circular(12.0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Image.asset('assets/images/gif-logo.gif',
                            width: 80, fit: BoxFit.fill),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          child: Text(
                            "Do you really want to exit an App?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop("Discard");
              },
              child: Container(
                  decoration: BoxDecoration(
                    //color: Color(0xff2e2f34),
                    borderRadius: BorderRadius.all(new Radius.circular(32.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop("Discard");
                          },
                          child: Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              gradient: Gradients.blush,
                              borderRadius:
                                  BorderRadius.all(new Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'RockWellStd'),
                              ),
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            exit(0);
                          },
                          child: Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              gradient: Gradients.blush,
                              borderRadius:
                                  BorderRadius.all(new Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: Text(
                                "Exit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'RockWellStd'),
                              ),
                            ),
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => fancyDialog);
  }

  getUserId() async {
    // final SharedPreferences pref = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    // _fabHeight = _initFabHeight;
    videoId = 1;
    getUserId();
    checkLoggedInUser();
    _getVideoResult = _getVideos();
    super.initState();
    _active = 2;
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );

    animationController.repeat();
    Timer(Duration(seconds: 2), () {
      checkVideoStarted();
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the CachedVideoPlayerController to free up resources.
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  checkVideoStarted() {
    print("checkVideoStarted");
    if (videoController == null) {
    } else {
      print("if videoController != null");
      videoController.initialize().then((_) {
        print("if videoController.initialize");
        setState(() {
          videoStarted = true;
        });
      });
      /*if (videoController.value.isPlaying) {
        print("if ");
//      setState(() {
//        Timer(Duration(seconds: 1), () {
          setState(() {
            videoStarted = true;
          });
//        });
//      });
      }*/
    }
  }

  checkLoggedInUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var userId =
          (pref.getInt('user_id') == null) ? 0 : pref.getInt('user_id');
      appToken = (pref.getString('app_token') == null)
          ? ''
          : pref.getString('app_token');
      loginUserId = userId;
      if (userId > 0) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    });
  }

  void _onRefresh() async {
    print("_onRefresh");
    // monitor network fetch
//    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
    _refreshController.refreshCompleted();
  }

  Widget build(BuildContext context) {
    // _panelHeightOpen = MediaQuery.of(context).size.height * .40;

    return WillPopScope(
      onWillPop: () async => _onWillPop(),
      child: Material(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              SlidingUpPanel(
                isDraggable: false,
                backdropEnabled: true,
                backdropColor: Colors.transparent,
                panelSnapping: false,
                color: Colors.transparent,
                controller: _pc,
                maxHeight: 290.0,
                minHeight: 0,
                onPanelOpened: () {
                  setState(() {
//                    HomePage.isOpened = true;
                  });
                },
                body: homeWidget(),
                panelBuilder: (sc) => _panel(sc),
                onPanelSlide: (double pos) => setState(() {
                  // _fabHeight = 600;
                }),
              ),
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: bottomToolbarWidget(this._pc3, this._pc2),
              ),
              // SlidingUpPanel(
              //   isDraggable: false,
              //   backdropEnabled: true,
              //   backdropColor: Colors.transparent,
              //   panelSnapping: false,
              //   color: Colors.transparent,
              //   controller: _pc2,
              //   maxHeight: 500,
              //   minHeight: 0,
              //   onPanelOpened: () {
              //     print("Helloddddd");
              //     print(videoId);
              //     //this.widget.checkCommentsOpened(true);
              //   },
              //   body: null,
              //   panelBuilder: (sc) => (videoId > 0) ? Comments() : Container(),
              //   onPanelSlide: (double pos) => setState(
              //     () {
              //       _fabHeight = 600;
              //     },
              //   ),
              // ),
              SlidingUpPanel(
                isDraggable: false,
                backdropEnabled: true,
                backdropColor: Colors.transparent,
                panelSnapping: false,
                color: Colors.transparent,
                controller: _pc3,
                maxHeight: MediaQuery.of(context).size.height,
                minHeight: 0,
                onPanelOpened: () {},
                body: null,
                panelBuilder: (sc) =>
                    LoginSlide(this._pc3, this.videoController),
                onPanelSlide: (double pos) => setState(
                  () {
                    // _fabHeight = 600;
                  },
                ),
              ),
              // the fab
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Container(
        height: 270,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 1.0,
            ),
            Container(
              height: 230,
              padding: EdgeInsets.only(left: 12.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, i) {
                  var imgUrl = ([
                    'assets/images/p1.jpg',
                    'assets/images/p2.jpg',
                    'assets/images/p3.jpg'
                  ]..shuffle())
                      .first;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 148.1,
                        height: 233.0,
                        color: Colors.transparent,
                        child: Card(
                          elevation: 5,
                          child: Container(
                            height: 233,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 1.0,
                                  color: Colors.white,
                                ),
                                top: BorderSide(
                                  width: 1.0,
                                  color: Colors.white,
                                ),
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: Colors.white,
                                ),
                                right: BorderSide(
                                  width: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(5.0),
                                topRight: const Radius.circular(5.0),
                                bottomLeft: const Radius.circular(0),
                                bottomRight: const Radius.circular(0),
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 2.0, right: 2.0),
                                      height: 219.0,
                                      width: 134.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5.0),
                                          topRight: Radius.circular(5.0),
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0),
                                        ),
                                        image: DecorationImage(
                                            image: AssetImage(imgUrl),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 219.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: FractionalOffset.topCenter,
                                      end: FractionalOffset.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                      stops: [
                                        0.0,
                                        1.3,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 5.0,
                                  bottom: 5.0,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 35.0,
                                        height: 35.0,
                                        decoration: new BoxDecoration(
                                          color: Colors.black,
                                          image: new DecorationImage(
                                            image: new AssetImage(imgUrl),
                                            fit: BoxFit.fitWidth,
                                          ),
                                          borderRadius: new BorderRadius.all(
                                            new Radius.circular(50.0),
                                          ),
                                          border: new Border.all(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        height: 30,
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5.0,
                                                    top: 5.0,
                                                  ),
                                                  child: Text(
                                                    "Profile Name",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green,
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5.0,
                                                  ),
                                                  child: Text(
                                                    "Followers: 1.2M",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      fontSize: 9.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 54,
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _button(String label, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            color: Colors.transparent,
          ),
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(label),
      ],
    );
  }*/

  Widget bottomToolbarWidget(PanelController pc3, PanelController pc2) {
    {
      return Column(
        children: [
          Container(
            //color:Colors.white10.withOpacity(0.2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black12.withOpacity(0.1), Colors.transparent],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: Image.asset(
                          'assets/icons/home.png',
                          width: 25.0,
                        ),
                        onPressed: () {
                          /* if (videoStarted) { */
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                          /* } else {} */
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: Image.asset(
                          'assets/icons/hash.png',
                          width: 23.0,
                        ),
                        onPressed: () {
                          /* if (videoStarted) { */
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HashVideos(),
                            ),
                          );
                          /* } else {} */
                        },
                      ),
                    ],
                  ),
                  Container(
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Image.asset(
                        'assets/icons/video.png',
                        height: 100,
                        width: 100,
                      ),
                      onPressed: () {
//                        videoController.dispose();
                        videoController.pause();
//                         if (videoStarted) {
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoRecorder(),
                            ),
                          );
                        } else {
                          videoController.pause();
                          pc3.open();
                        }
                        /* } else {
                          print("abc");
                        }*/
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: Image.asset(
                          'assets/icons/message.png',
                          width: 23.0,
                        ),
                        onPressed: () {
                          /* if (videoStarted) { */
                          if (isLoggedIn) {
                            pc2.open();
                          } else {
                            videoController.pause();
                            pc3.open();
                          }
                          /* } else {} */
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: Image.asset(
                          'assets/icons/me.png',
                          width: 23.0,
                        ),
                        onPressed: () {
                          videoController.pause();
                          /* if (videoStarted) { */
                          if (isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyProfile(),
                              ),
                            );
                          } else {
                            videoController.pause();
                            pc3.open();
                          }
                          /* } else {} */
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget homeWidget() {
    {
      return Scaffold(
        body: (videoList.length > 0 && !userFollowSuggestion)
            ? Stack(
                children: <Widget>[
                  FutureBuilder(
                      future: _getVideoResult,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return new Swiper(
                            controller: swipeController,
                            loop: false,
                            onIndexChanged: (index) {
                              print("index $index");
                              onVideoChange(videoList[index]);
                              setState(() {
                                videoInitialized = false;
                              });
                              if (index > 0) {
                                setState(() {
                                  initializePage = false;
                                });
                              }
                              setState(() {
                                swiperIndex = index;
                                videoStarted = false;
                              });
                              if (totalRows > nosVideos &&
                                  index == (nosVideos - 1)) {
                                setState(() {
                                  page++;
                                  _getVideos();
                                });
                              }
                            },
                            itemBuilder: (BuildContext context, int index) {
                              // VideoModel video = videoList[index];
                              return new Stack(
                                fit: StackFit.loose,
                                children: <Widget>[
                                  Container(
                                    color: Colors.black,
                                    child: VideoPlayerApp(
                                      // _pc,
                                      _pc3,
                                      videoList[index],
                                      setVideoController, /* (videoInit) {
                                      print(
                                          "videoInitEnter $videoInitialized");
                                      setState(() {
                                        videoInitialized = videoInit;
                                        print(
                                            "videoInitLeave $videoInitialized");
                                      });
                                    }*/
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      // Top section
                                      // Middle expanded
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                VideoDescription(
                                                  videoList[index],
                                                  _pc3,
                                                ),
                                                // ActionsToolbar(
                                                //   widget._pc,
                                                //   widget._pc2,
                                                //   widget._pc3,
                                                //   videoList[index],
                                                //   this.updateLike,
                                                //   this.updateFollowingVariable,
                                                // ),
                                                sidebar(index)
                                              ]),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 70.0,
                                      ),
                                    ],
                                  ),
                                  (swiperIndex == 0 && !initializePage)
                                      ? SafeArea(
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
//                                            color: Colors.black87,
                                            color: Colors.transparent,
                                            child: RefreshConfiguration(
                                              springDescription:
                                                  SpringDescription(
                                                stiffness: 170,
                                                damping: 16,
                                                mass: 1.9,
                                              ), // custom spring back animate,the props meaning see the flutter api
                                              child: SmartRefresher(
                                                controller: _refreshController,
                                                header: WaterDropMaterialHeader(
                                                  backgroundColor:
                                                      Colors.pinkAccent,
                                                  color: Colors.black87,
                                                ),
                                                enablePullDown:
                                                    (swiperIndex == 0)
                                                        ? true
                                                        : false,
                                                onRefresh: _onRefresh,
                                                child: SwipeDetector(
                                                  onSwipeUp: () {
                                                    print("onSwipeUp");
                                                    setState(() {
                                                      videoInitialized = true;
                                                    });
                                                  },
                                                  child: Container(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              );
                            },
                            itemCount: videoModelList.total != null
                                ? videoModelList.total
                                : 10,
                            scrollDirection: Axis.vertical,
                          );
                        } else {
                          return Center();
                        }
                      }),
                  topSection,
                ],
              )
            : (showFollowingPage)
                ? Container(
                    decoration: BoxDecoration(gradient: Gradients.blush),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  child: Text("Following",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18.0,
                                      )),
                                  onTap: () {},
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  height: 15,
                                  width: 2,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                GestureDetector(
                                  child: Text(
                                    "Featured",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      userFollowSuggestion = false;
                                      showFollowingPage = false;
                                      _active = 2;
                                      following = 0;
                                      _getVideos();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              videoController.pause();
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UsersToFollow(
                                        this.updateFollowingVariable),
                                  ),
                                );
                              } else {
                                videoController.pause();
                                _pc3.open();
                              }
                            },
                            child: Container(
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
                                            width: 2, color: Colors.white)),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "This is your feed of user you follow.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "You can follow people or subscribe to hashtags.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Icon(Icons.person_add,
                                      color: Colors.white, size: 45),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // Text(
                                  //   "Find your friends already on Leuke.",
                                  //   style: TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 15,
                                  //       fontWeight: FontWeight.w600),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Following",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0,
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  height: 15,
                                  width: 2,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Featured",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(child: showLoaderSpinner()),
                      ],
                    ),
                  ),
      );
    }
  }

  Widget get topSection => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black45,
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    "Following",
                    style: (_active == 1)
                        ? TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          )
                        : TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ),
                  ),
                  onTap: () {
                    setState(() {
                      if (isFollowingVideos > 0) {
                        showFollowingPage = false;
                        userFollowSuggestion = false;
                        _active = 1;
                        following = 1;
                        videoList = [];
                        _getVideos();
                      } else {
                        showFollowingPage = true;
                        userFollowSuggestion = true;
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 8,
                ),
                Container(
                  height: 15,
                  width: 2,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  child: Text(
                    "Featured",
                    style: (_active == 2)
                        ? TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          )
                        : TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ),
                  ),
                  onTap: () {
                    setState(() {
                      userFollowSuggestion = false;
                      _active = 2;
                      following = 0;
                      videoList = [];
                      _getVideos();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
  Widget _getMusicPlayerAction(index) {
    VideoModel videoObj = videoList[index];
    return GestureDetector(
      onTap: () {
        videoController.pause();
        if (isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoRecorder(videoObj.soundId),
            ),
          );
        } else {
          videoController.pause();
          _pc3.open();
        }
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: ActionWidgetSize,
          height: ActionWidgetSize,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: ProfileImageSize,
                width: ProfileImageSize,
                decoration: BoxDecoration(
                  gradient: musicGradient,
                  borderRadius: BorderRadius.circular(ProfileImageSize / 2),
                ),
                child: Container(
                  height: 45.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(50),
                    image: new DecorationImage(
                      image: new CachedNetworkImageProvider(
                          videoObj.soundImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VideoPlayerController controller;
  // static bool _lights = true;
  // bool _isPlaying = false;
  Duration duration;
  Duration position;
  // bool _isEnd = false;
  // Future<void> _initializeVideoPlayerFuture;
  /*_incViews() async {
    print("_incViews");
    final SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = 0;
    int videoId = widget.video.videoId;
    String uniqueId = "";
    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    try {
      var response = await dio.post("api/v1/video-views",
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "unique_token": (pref.getString('unique_id') == null)
                ? 0
                : pref.getString('unique_id'),
            "video_id": videoId,
            "user_id":
                (pref.getInt('user_id') == null) ? 0 : pref.getInt('user_id'),
          });
      if (response.data['status'] == 'success') {
        print("successful view");
      }
    } catch (e) {
      print(e);
    }
  }*/

  /*Widget videoPlayer(VideoModel video) {
    {
      _lights = false;
      controller = CachedVideoPlayerController.network(video.url);
//    controller.play();
      // Initialize the controller and store the Future for later use.
      _initializeVideoPlayerFuture = controller.initialize();

      // Use the controller to loop the video.
      controller.setLooping(true);
      Timer(Duration(seconds: 5), () {
        _incViews();
      });
      return Scaffold(
        backgroundColor: Colors.black,
//      appBar: AppBar(
//        title: Text('Butterfly Video'),
//      ),
        // Use a FutureBuilder to display a loading spinner while waiting for the
        // CachedVideoPlayerController to finish initializing.

        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print("widget.videoInitialized(true);");
              widget.videoInitialized(true);
              return VisibilityDetector(
                key: cellKey(22, 4543),
                onVisibilityChanged: (visibilityInfo) {
                  if (widget.pc3.isPanelOpen) {
                    controller.pause();
                  } else {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage < 1) {
                      //the magic is done here
                      controller.pause();
                    } else {
                      print("Play");
                      controller.play();
                      if (_isEnd == true) {
                        print("Video Ended");
//                    widget.onVideoEnd;
                      }
                    }
                    debugPrint(
                        'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
//                  print("Entered ");

                      // If the video is playing, pause it.
                      if (controller.value.isPlaying) {
                        controller.pause();
                        _lights = true;
                      } else {
                        // If the video is paused, play it.
                        controller.play();
                        _lights = false;
                      }
                    });
                  },
                  child: Container(
                    // color: Colors.black,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: CachedVideoPlayer(controller),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: _lights
                                      ? Colors.grey[300]
                                      : Colors.transparent,
                                  size: 80,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // If the CachedVideoPlayerController is still initializing, show a
              // loading spinner.

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.video.videoThumbnail,
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: showLoaderSpinner()),
                  )
                ],
              );
            }
          },
        ),
      );
    }
  }*/
}
