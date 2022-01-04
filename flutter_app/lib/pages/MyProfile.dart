import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import '../models/Videos.dart';
import '../pages/Followings.dart';
import '../pages/SlidingUpPanelContainer.dart';
import '../pages/editProfile.dart';
import '../services/SessionManager.dart';
import '../widgets/globals.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../functions.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SessionManager sessions = new SessionManager();
  ScrollController _scrollController = new ScrollController();
  bool showLoader = false;
  static String searchKeyword = '';
  int _curIndex = 0;
  int userId = 0;
  String appToken = '';
  String name = '';
  String smallProfilePic = '';
  String largeProfilePic = '';
  List videoList = [];
  bool showLoadMoreLoader = false;
  VideoModelList videoModelList;
  String totalVideosLike = '0';
  String totalFollowings = '0';
  String totalFollowers = '0';
  String totalVideos = '0';
  int totalRecords = 0;
  bool showLoadMore = true;
  int page = 1;
  @override
  void initState() {
    print(apiUrlRoot + "imgs/user-dummy-pic.png");
    super.initState();
    _getSessionData();
  }

  updateProfileData(data) {
    setState(() {
      if (data['small_pic'] != null) {
        smallProfilePic = data['small_pic'];
        largeProfilePic = data['large_pic'];
      }
      if (data['name'] != null) {
        name = data['name'];
      }
    });
  }

  _getSessionData() async {
    sessions.getUserInfo().then((obj) {
      setState(() {
        userId = obj['user_id'];
        name = obj['name'];
        appToken = obj['app_token'];
        fetchData();
      });
    });
  }

  showLoaderSpinner() {
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
      showLoadMoreLoader = true;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/fetch-login-user-info";
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
            "app_token": appToken,
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
        showLoadMoreLoader = false;
      });
    } catch (e) {
      throw (e);
    }
  }

  fetchData() async {
    setState(() {
      showLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/fetch-login-user-info";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {"user_id": userId, "app_token": appToken});
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            smallProfilePic = rs.data['small_pic'];
            largeProfilePic = rs.data['large_pic'];
            totalVideosLike = rs.data['totalVideosLike'].toString();
            totalFollowers = rs.data['totalFollowers'].toString();
            totalFollowings = rs.data['totalFollowings'].toString();
            totalVideos = rs.data['totalVideos'].toString();
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
        showLoader = false;
      });
    } catch (e) {
      //throw (e);
    }
  }

  List<VideoModel> parseModel(String jsonResponse) {
    final parsed = json.decode(jsonResponse).cast<Map<String, dynamic>>();
    return parsed.map<VideoModel>((json) => VideoModel.fromJson(json)).toList();
  }

  void onSelectedMenu(String choice) {
    if (choice == SettingMenu.LOGOUT) {
      logout(context);
    } else if (choice == SettingMenu.EDIT_PROFILE) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfile(this.updateProfileData),
        ),
      );
    }
  }

  final searchField = TextField(
    style: TextStyle(
      color: Colors.white54,
      fontSize: 16.0,
    ),
    obscureText: false,
    keyboardType: TextInputType.text,
    controller: TextEditingController()..text = searchKeyword,
    onChanged: (String val) {
      searchKeyword = val;
    },
    decoration: new InputDecoration(
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      hintText: "Find Friends",
      hintStyle: TextStyle(fontSize: 15.0, color: Colors.white54),
    ),
  );

  Widget profilePhoto() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(45.0),
                    child: AppBar(
                      iconTheme: IconThemeData(
                        color: Colors.white, //change your color here
                      ),
                      backgroundColor: Color(0xff15161a),
                      title: Text(
                        "PROFILE PICTURE",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w400),
                      ),
                      centerTitle: true,
                    ),
                  ),
                  backgroundColor: Colors.black,
                  body: Center(
                    child: PhotoView(
                      enableRotation: true,
                      imageProvider: CachedNetworkImageProvider((largeProfilePic
                                  .toLowerCase()
                                  .contains(".jpg") ||
                              largeProfilePic.toLowerCase().contains(".jpeg") ||
                              largeProfilePic.toLowerCase().contains(".png") ||
                              largeProfilePic.toLowerCase().contains(".gif") ||
                              largeProfilePic.toLowerCase().contains(".bmp") ||
                              largeProfilePic
                                  .toLowerCase()
                                  .contains("fbsbx.com") ||
                              largeProfilePic
                                  .toLowerCase()
                                  .contains("googleusercontent.com"))
                          ? largeProfilePic
                          : apiUrlRoot + "imgs/user-dummy-pic.png"),
                    ),
                  ));
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Container(
          width: 70.0,
          height: 70.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100), color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new CachedNetworkImageProvider(
                    (smallProfilePic.toLowerCase().contains(".jpg") ||
                            smallProfilePic.toLowerCase().contains(".jpeg") ||
                            smallProfilePic.toLowerCase().contains(".png") ||
                            smallProfilePic.toLowerCase().contains(".gif") ||
                            smallProfilePic.toLowerCase().contains(".bmp") ||
                            smallProfilePic
                                .toLowerCase()
                                .contains("fbsbx.com") ||
                            smallProfilePic
                                .toLowerCase()
                                .contains("googleusercontent.com"))
                        ? smallProfilePic
                        : apiUrlRoot + "imgs/user-dummy-pic.png",
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profilePersonInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(name,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'RockWellStd',
                fontWeight: FontWeight.bold)),
        RaisedButton(
          color: Color(0xff15161a),
          padding: EdgeInsets.all(0),
          child: Container(
            height: 25,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                gradient: Gradients.blush),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      fontFamily: 'RockWellStd',
                    ),
                  ),
                ],
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(this.updateProfileData),
              ),
            );
          },
        ),
      ],
    );
  }

  _deleteVideo(context, videoId) async {
    print(videoId);

//    Navigator.of(context, rootNavigator: true).pop("Discard");
    showLoader = true;
    // final SharedPreferences pref = await SharedPreferences.getInstance();
    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    try {
      var response = await dio.post(
        "api/v1/delete-video",
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        queryParameters: {
          "video_id": videoId,
          "app_token": appToken,
          "user_id": userId
        },
      );
      print(response.data);
      if (response.data['status'] == 'success') {
        print("Deleted successful");
        setState(() {
          videoModelList.data.removeWhere((item) => item.videoId == videoId);
//          totalVideos
          showLoader = false;
        });
      }
    } catch (e) {
      showLoader = false;
      print(e);
    }
    return true;
  }

  Widget userVideo(context) {
    if (videoModelList != null) {
      if (videoModelList.data.length > 0) {
        var size = MediaQuery.of(context).size;
        final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
        final double itemWidth = size.width / 2;
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: GridView.builder(
            controller: _scrollController,
            primary: false,
            padding: const EdgeInsets.all(2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                              builder: (context) =>
                                  HomePage(videoModelList.data[i])),
                        );
                      },
                      onLongPress: () {
                        var alertStyle = AlertStyle(
                            animationType: AnimationType.fromTop,
                            isCloseButton: false,
                            isOverlayTapDismiss: true,
                            //descStyle: TextStyle(fontWeight: FontWeight.bold),
                            animationDuration: Duration(milliseconds: 400),
                            titleStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              //fontFamily: 'QueenCamelot',
                            ),
                            constraints: BoxConstraints.expand(
                                width: MediaQuery.of(context).size.width - 80));
                        Alert(
                            context: context,
                            style: alertStyle,
                            title:
                                "This will permanently delete the video and you will not be able to recover it. "
                                "You still want to delete the video?",
                            content: Container(
                              width: MediaQuery.of(context).size.width - 80,
                              //child: ,
                            ),
                            buttons: [
                              DialogButton(
                                onPressed: () async {
                                  await _deleteVideo(
                                      context, videoModelList.data[i].videoId);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                gradient: Gradients.blush,
                              ),
                              DialogButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                gradient: Gradients.blush,
                              )
                            ]).show();
                      },
                      child: Container(
                          child: Stack(
                        children: [
                          Container(
                            height: size.height,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 3.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 5 Vertically
                                  ),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(1),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: videoModelList.data[i].videoGif != ""
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            videoModelList.data[i].videoGif,
                                        placeholder: (context, url) =>
                                            showLoaderSpinner(),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/noVideo.jpg',
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            videoModelList.data[i].totalLikes,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            videoModelList.data[i].totalViews,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        if (!showLoader) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.videocam,
                    size: 30,
                    color: Colors.grey,
                  ),
                  Text(
                    "No Videos Yet",
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
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.videocam,
                  size: 30,
                  color: Colors.grey,
                ),
                Text(
                  "No Videos Yet",
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
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
      child: DefaultTabController(
        length: 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _curIndex = index;
                  });
                },
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                indicatorWeight: 0.2,
                labelPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (_curIndex == 0)
                              ? Image.asset(
                                  'assets/icons/my-video-e.png',
                                  width: 35,
                                )
                              : Image.asset('assets/icons/my-video-d.png',
                                  width: 35),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "My Videos",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Tab(
                  //   child: Align(
                  //     alignment: Alignment.center,
                  //     child: Container(
                  //       child: Column(
                  //         children: <Widget>[
                  //           (_curIndex == 1)
                  //               ? Image.asset('assets/icons/liked-video-e.png',
                  //                   width: 30)
                  //               : Image.asset('assets/icons/liked-video-d.png',
                  //                   width: 30),
                  //           Text(
                  //             "Liked Videos (0)",
                  //             style:
                  //                 TextStyle(color: Colors.white, fontSize: 12),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 370,
                child: TabBarView(children: [
                  Container(child: userVideo(context)),
                  // Center(
                  //   child: Container(
                  //     height: MediaQuery.of(context).size.height,
                  //     width: MediaQuery.of(context).size.width,
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: <Widget>[
                  //         Icon(
                  //           Icons.videocam,
                  //           size: 30,
                  //           color: Colors.grey,
                  //         ),
                  //         Text(
                  //           "No Videos Yet",
                  //           style: TextStyle(color: Colors.grey, fontSize: 15),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ]),
              ),
            ),
          ],
        ),
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
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                  child: Container(
                    height: 24,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 88,
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.settings,
                              size: 22, color: Colors.white),
                          onSelected: onSelectedMenu,
                          color: Color(0xff444549),
                          itemBuilder: (BuildContext context) {
                            return SettingMenu.choices.map((String choice) {
                              return PopupMenuItem(
                                height: 30,
                                value: choice,
                                child: Text(
                                  choice,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'RockWellStd',
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        profilePhoto(),
                        profilePersonInfo(),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 3, bottom: 3),
                              child: Text(
                                totalVideosLike,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              "LIKES",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            )
                          ],
                        ),
                      ),
                      Container(height: 35, width: 0.8, color: Colors.white),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            if (totalFollowings != '0') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyFollowingFollowers(0),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 3, bottom: 3),
                                child: Text(
                                  totalFollowings,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "FOLLOWINGS",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(height: 35, width: 0.8, color: Colors.white),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            if (totalFollowers != '0') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyFollowingFollowers(1),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 3, bottom: 3),
                                child: Text(
                                  totalFollowers,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "FOLLOWERS",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0.4)),
                ),
                SizedBox(
                  height: 12,
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

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const List<String> choices = <String>[EDIT_PROFILE, LOGOUT];
}
