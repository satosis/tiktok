import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../widgets/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/Videos.dart';
//void main() => runApp(VideoPlayerApp());

/*class VideoPlayerApp extends StatelessWidget {
  final PanelController _pc;
  final VideoModel video;
  final ValueSetter<VideoPlayerController> updateVideoController;
  VideoPlayerApp(this._pc, this.video, this.updateVideoController);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      home: VideoPlayerScreen(this._pc, this.video, this.updateVideoController),
    );
  }
}*/

class VideoPlayerApp extends StatefulWidget {
//  final PanelController _pc;
//   final PanelController _pc;
  final PanelController pc3;
  final VideoModel video;
  final ValueSetter<VideoPlayerController> setVideoController;
//  final ValueSetter<bool> videoInitialized;
  VideoPlayerApp(
    // this._pc,
    this.pc3,
    this.video,
    this.setVideoController,
    /*this.videoInitialized*/
  );
//  VideoPlayerScreen({
//    Key key,
//    this.pc,
//  }) : super(key: key);

  @override
  VideoPlayerAppState createState() => VideoPlayerAppState();
}

class VideoPlayerAppState extends State<VideoPlayerApp> {
  VideoPlayerController controller;
  static bool _lights = true;
  // bool _isPlaying = false;
  Duration duration;
  Duration position;
  bool _isEnd = false;
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

  _incViews() async {
    print("_incViews");
    final SharedPreferences pref = await SharedPreferences.getInstance();
    // int userId = 0;
    int videoId = widget.video.videoId;
    // String uniqueId = "";
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
  }

  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _lights = false;
    controller = VideoPlayerController.network(widget.video.url);
    controller.pause();
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = controller.initialize();

    // Use the controller to loop the video.
    controller.setLooping(true);
    Timer(Duration(seconds: 5), () {
      _incViews();
    });
//    setState(() {
    if (controller != null) {
      widget.setVideoController(controller);
    }
//    });

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    controller.pause();
    controller.dispose();
    super.dispose();
  }

  Key cellKey(int row, int col) => Key('Cell-$row-$col');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
//      appBar: AppBar(
//        title: Text('Butterfly Video'),
//      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.

      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
//            print("widget.videoInitialized(true);");
//            widget.videoInitialized(true);
            return VisibilityDetector(
              key: cellKey(22, 4543),
              onVisibilityChanged: (visibilityInfo) {
                if (widget.pc3.isPanelOpen) {
                  controller.pause();
                } else {
                  var visiblePercentage = visibilityInfo.visibleFraction * 100;
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
                      'Widget ${visibilityInfo.key} is $visiblePercentage% visible');
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
                          /*ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: controller.value.size.height / 2),
                            child:*/
                          AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                          // ),
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
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
//            print("widget.videoInitialized(false);");
//            widget.videoInitialized(false);
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
}
