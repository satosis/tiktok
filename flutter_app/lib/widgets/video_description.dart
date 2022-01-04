import 'package:flutter/material.dart';
import '../models/Videos.dart';
import '../services/SessionManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'MarqueWidget.dart';

class VideoDescription extends StatefulWidget {
  final VideoModel video;
  final PanelController pc3;
  VideoDescription(this.video, this.pc3);
  @override
  _VideoDescriptionState createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  String username = "";
  String description = "";
  String appToken = "";
  int soundId = 0;
  int loginId = 0;
  bool isLogin = false;
  AnimationController animationController;
  // static const double ActionWidgetSize = 60.0;
  // static const double ProfileImageSize = 50.0;

  final SessionManager sessions = new SessionManager();

  String soundImageUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.video.username;
    description = widget.video.description;
    soundId = widget.video.soundId;
    soundImageUrl = widget.video.soundImageUrl;
  }
/*
  _getSessionData() async {
    sessions.getUserInfo().then((obj) {
      setState(() {
        if (obj['user_id'] > 0) {
          isLogin = true;
          loginId = obj['user_id'];
          appToken = obj['app_token'];
        } else {}
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70.0,
        padding: EdgeInsets.only(left: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
              ],
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 30.0,
            ),
            SizedBox(
              width: 150.0,
              child: MarqueeWidget(
                direction: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.video.soundTitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*  Widget _getMusicPlayerAction() {
    return GestureDetector(
      onTap: () {
        print(soundId);
        (isLogin)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoRecorder(soundId),
                ),
              )
            : widget.pc3.open();
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
                      image: new CachedNetworkImageProvider(soundImageUrl),
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
  }*/

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
}
