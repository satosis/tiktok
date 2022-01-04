import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/Videos.dart';
import '../pages/MyProfile.dart';
import '../pages/UserProfile.dart';
import '../widgets/globals.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

class Comments extends StatefulWidget {
  final Function updateCommentsCount;
  final VideoModel videoObj;
  Comments(this.videoObj, this.updateCommentsCount);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  String comment = '';
  bool showLoader = false;
  bool showLoadMoreLoader = false;
  List<String> commentData = [];
  int totalRecords = 0;
  int page = 1;
  bool showLoadMore = true;
  int userId = 0;
  int videoId = 0;
  ScrollController _scrollController;
  ScrollController _scrollController2 = new ScrollController();
  @override
  void initState() {
    super.initState();
    getSessionVaribales();
    videoId = widget.videoObj.videoId;
    _scrollController = new ScrollController();
    fetchComments();
  }

  getSessionVaribales() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userId = (pref.getInt('user_id') == null) ? 0 : pref.getInt('user_id');
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
      String apiUrl = apiUrlRoot + "api/v1/fetch-video-comments";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {"video_id": videoId, 'page': page});
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            List<dynamic> tempCommentData = rs.data['data'];
            List<String> commentMoreData =
                tempCommentData.map((e) => json.encode(e)).toList();
            commentData.addAll(commentMoreData);
            if (commentData.length == totalRecords) {
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

  fetchComments() async {
    setState(() {
      page = 1;
      showLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/fetch-video-comments";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {"video_id": videoId, 'page': page});
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            totalRecords = rs.data['total_records'];
            List<dynamic> tempCommentData = rs.data['data'];
            commentData = tempCommentData.map((e) => json.encode(e)).toList();
            if (commentData.length == totalRecords) {
              showLoadMore = false;
            }

            _scrollController2.addListener(() {
              if (_scrollController2.position.pixels ==
                  _scrollController2.position.maxScrollExtent) {
                if (commentData.length != totalRecords && showLoadMore) {
                  loadMore();
                }
              }
            });

            _scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
            );
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

  addComment() async {
    FocusScope.of(context).unfocus();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      showLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/add-comment";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "video_id": videoId,
            'comment': comment,
            'user_id': pref.getInt('user_id'),
            'app_token': pref.getString('app_token')
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            this
                .widget
                .updateCommentsCount(rs.data['total_comments'].toString(),videoId);
            comment = "";
            fetchComments();
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

  deleteCommentApi(commentId) async {
    Navigator.pop(context);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      showLoader = true;
    });

    try {
      String apiUrl = apiUrlRoot + "api/v1/delete-comment";
      var rs = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "video_id": videoId,
            'comment_id': commentId,
            'user_id': pref.getInt('user_id'),
            'app_token': pref.getString('app_token')
          });
      if (rs.statusCode == 200) {
        if (rs.data['status'] == 'success') {
          setState(() {
            commentData.removeWhere(
                (item) => jsonDecode(item)['comment_id'] == commentId);
            this
                .widget
                .updateCommentsCount(rs.data['total_comments'].toString());
            comment = "";
            fetchComments();
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

  void deleteConfirm(context, commentId) {
    var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: true,
        // descStyle: TextStyle(fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 400),
        titleStyle: TextStyle(
          color: Colors.black,
          fontSize: 15,
          // fontFamily: 'QueenCamelot',
        ),
        constraints: BoxConstraints.expand(
            width: MediaQuery.of(context).size.width - 80));
    Alert(
        context: context,
        style: alertStyle,
        title: "Are you sure to delete this comment ?",
        content: Container(
          width: MediaQuery.of(context).size.width - 80,
          //child: ,
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              deleteCommentApi(commentId);
            },
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontSize: 14),
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
  }

  @override
  Widget build(BuildContext context) {
    final commentField = TextFormField(
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.text,
      controller: TextEditingController()..text = comment,
      onSaved: (String val) {
        comment = val;
      },
      onChanged: (String val) {
        comment = val;
      },
      decoration: new InputDecoration(
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Type your comment here..",
          suffixIcon: IconButton(
            onPressed: () {
              if (comment.trim() != '' && comment != null) {
                addComment();
              }
            },
            icon: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset("assets/icons/next-b.png"),
            ),
          ),
          contentPadding: EdgeInsets.only(left: 10, top: 15),
          hintStyle: TextStyle(color: Colors.white)),
    );

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Color(0xff000000),
            title: Text(
              "$totalRecords Comments",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
            ),
            centerTitle: true,
          ),
        ),
        body: ModalProgressHUD(
            inAsyncCall: showLoader,
            progressIndicator: showLoaderSpinner(),
            child: Container(
                color: Color(0xff15161a),
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Container(
                        height: MediaQuery.of(context).size.height - 60,
                        child: (commentData.length > 0)
                            ? ListView.builder(
                                controller: _scrollController2,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                itemCount: commentData.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onLongPress: () {
                                          if ((userId ==
                                                  jsonDecode(commentData[i])[
                                                      'user_id']) ||
                                              userId ==
                                                  widget.videoObj.userId) {
                                            deleteConfirm(
                                                context,
                                                jsonDecode(commentData[i])[
                                                    'comment_id']);
                                          }
                                        },
                                        child: Container(
                                          child: ListTile(
                                            leading: GestureDetector(
                                              onTap: () {
                                                if ((userId ==
                                                        jsonDecode(
                                                                commentData[i])[
                                                            'user_id'])) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyProfile(),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserProfile(jsonDecode(
                                                                  commentData[
                                                                      i])[
                                                              'user_id']),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: new BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: new DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:
                                                          CachedNetworkImageProvider(
                                                              jsonDecode(
                                                                      commentData[
                                                                          i])[
                                                                  'pic'])),
                                                ),
                                              ),
                                            ),
                                            title: GestureDetector(
                                              onTap: () {
                                                if ((userId ==
                                                        jsonDecode(
                                                                commentData[i])[
                                                            'user_id'])) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyProfile(),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserProfile(jsonDecode(
                                                                  commentData[
                                                                      i])[
                                                              'user_id']),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                jsonDecode(
                                                    commentData[i])['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            subtitle: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 0,
                                                      vertical: 3),
                                                  child: Text(
                                                    jsonDecode(commentData[i])[
                                                        'comment'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 0,
                                                      vertical: 3),
                                                  child: Text(
                                                    jsonDecode(commentData[i])[
                                                        'timing'],
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      (i != commentData.length - 1)
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 1,
                                              color: Color(0xff444549),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 50),
                                              child: Container(),
                                            ),
                                    ],
                                  );
                                })
                            : (!showLoader)
                                ? Center(
                                    child: Text(
                                      "There is no comments!",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : Container(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Color(0xff2e2f34),
                        child: commentField,
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: (showLoadMoreLoader)
                          ? showLoaderSpinner()
                          : Container(),
                    ),
                  ],
                ))));
  }
}
