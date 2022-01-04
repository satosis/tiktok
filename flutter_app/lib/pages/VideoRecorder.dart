import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../models/Sounds.dart';
import '../pages/MyProfile.dart';
import '../pages/SoundList.dart';
import '../services/SessionManager.dart';
import '../widgets/MarqueWidget.dart';
import '../widgets/globals.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';

import '../functions.dart';
import 'SlidingUpPanelContainer.dart';

class VideoRecorder extends StatefulWidget {
  final int soundId;
//  final CachedVideoPlayerController videoController;
//  VideoRecorder([this.soundId, this.videoController]);
  VideoRecorder([this.soundId]);
  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends State<VideoRecorder>
    with TickerProviderStateMixin {
  CameraController controller;
  String videoPath;
  String audioFile = "";
  String description = "";
  List<CameraDescription> cameras;
  int selectedCameraIdx;
  bool videoRecorded = false;
  GlobalKey<FormState> _key = new GlobalKey();
  // bool _validate = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
//  final FlutterFFmpegConfig _flutterFFmpegConfig = new FlutterFFmpegConfig();

//  Subscription _subscription;
  double uploadProgress = 0;
//  final _loadingStreamCtrl = StreamController<bool>.broadcast();
  bool isUploading = false;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  final SessionManager sessions = new SessionManager();
  String thumbFile = "";
  String gifFile = "";
  int userId = 0;
  PanelController _pc1 = new PanelController();
  String appToken = "";
  final assetsAudioPlayer = AssetsAudioPlayer();
  String audioFileName = "";
  int audioId = 0;
  int videoId = 0;
  bool showLoader = false;
  bool isPublishPanelOpen = false;
  bool isVideoRecorded = false;
  double videoProgressPercent = 0;
  bool showProgressBar = false;
  double progress = 0.0;
  Timer timer;
  // bool _hasTorch = false;
  // bool _toggleFlash = false;
  // String _flashOn = "assets/icons/flash-off.png";

  String responsePath;
  double videoLength = 15.0;

  bool cameraCrash = false;

  /// stop icon animation
  AnimationController _animationController;
  Animation _sizeAnimation;
  bool reverse = false;
  int seconds = 1;

  int privacy = 0;

  String thumbPath = "";
  @override
  void dispose() {
    super.dispose();

    videoController.dispose();

    print("cancelCompression()");
  }

  startTimer() {
    timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      setState(() {
        videoProgressPercent += 1 / (videoLength * 10);
        if (videoProgressPercent >= 1) {
          videoProgressPercent = 1;
          timer.cancel();
          _onStopButtonPressed();
        }
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });
        _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
    /*if (!_loadingStreamCtrl.isClosed) {
      _loadingStreamCtrl.close();
    }*/
    _getSessionData();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: seconds))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.repeat(reverse: !reverse);
              setState(() {
                reverse = !reverse;
              });
            }
          });

    _sizeAnimation =
        Tween<double>(begin: 60.0, end: 70.0).animate(_animationController);
    _animationController.forward();
    if (widget.soundId == null) {
    } else {
      if (widget.soundId > 0) {
        setState(() {
          showLoader = true;
        });
        Timer(Duration(milliseconds: 300), () {
          if (userId > 0) {
            getSound(widget.soundId);
          }
        });
      }
    }
  }

  List<SoundModel> parseSoundModel(String jsonResponse) {
    final parsed = json.decode(jsonResponse).cast<Map<String, dynamic>>();
    return parsed.map<SoundModel>((json) => SoundModel.fromJson(json)).toList();
  }

  Widget _thumbnailWidget() {
    return SlidingUpPanel(
      isDraggable: false,
      backdropEnabled: true,
      backdropColor: Colors.black54,
      panelSnapping: false,
      color: Colors.transparent,
      controller: _pc1,
      maxHeight: MediaQuery.of(context).size.height,
      minHeight: 0,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: videoController == null
            ? Container()
            : Stack(children: <Widget>[
                SizedBox.expand(
                  child: (videoController == null)
                      ? Container()
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: videoController.value.size?.width ?? 0,
                            height: videoController.value.size?.height ?? 0,
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio: videoController.value.aspectRatio
                                  /*videoController.value.size != null
                                          ? videoController.value.aspectRatio
                                          : 1.0*/
                                  ,
                                  child: VideoPlayer(videoController)),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 50,
                  right: 20,
                  child: RawMaterialButton(
                    onPressed: () {
                      videoController.pause();
                      _pc1.open();
//                    uploadVideo();
                    },
                    elevation: 2.0,
                    fillColor: Colors.white,
                    child: Icon(
                      Icons.check_circle,
                      size: 35.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: RawMaterialButton(
                    onPressed: () {
                      videoController.pause();
                      setState(() {
                        isUploading = false;
                        timer.cancel();
                        videoController = null;
                      });
                    },
                    elevation: 2.0,
                    fillColor: Colors.white,
                    child: Icon(
                      Icons.close,
                      size: 35.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                ),
              ]),
      ),
      panelBuilder: (sc) {
        return publishPanel();
      },
    );
  }

  String validateDescription(String value) {
    if (value.length == 0) {
      return "Description is required!";
    } else {
      return null;
    }
  }

  Widget publishPanel() {
    const Map<String, int> privacies = {
      'Public': 0,
      'Private': 1,
      'Only Followers': 2
    };
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Container(
        color: Colors.black,
        /*decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),*/
        height: MediaQuery.of(context).size.height,
//        color: Colors.white,
        child: Form(
          key: _key,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Center(
                  child: Text(
                    "New Post",
                    style: TextStyle(
                      fontFamily: 'RockWellStd',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 1,
                  child: Container(
                    color: Colors.white30,
                  ),
                ),
              ),
              Container(
                height: 500,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                fontFamily: 'RockWellStd',
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                              validator: validateDescription,
                              onSaved: (String val) {
                                description = val;
                              },
                              onChanged: (String val) {
                                description = val;
                              },
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  wordSpacing: 2.0,
                                ),
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.pinkAccent,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.pinkAccent,
                                    width: 0.5,
                                  ),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                ),
                                hintText: "Enter Video Description",
                                hintStyle: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 175,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors
                                            .pinkAccent, //                   <--- border color
                                        width: 0.5,
                                      ),
                                      color: Color(0xff2e2f34),
                                      borderRadius: BorderRadius.all(
                                          new Radius.circular(6.0)),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            thumbPath),
                                        fit: BoxFit.fitWidth,
                                      )),

                                  /* child: CachedNetworkImage(
                                    imageUrl: thumbPath,
                                    height: 175,
                                  ),*/
                                ),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.black,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Privacy Setting",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
//                                      canvasColor: Color(0xffffffff),
                                        canvasColor: Colors.black87,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField(
                                          isExpanded: true,
                                          hint: new Text(
                                            "Select Type",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          iconEnabledColor: Colors.white,
                                          style: new TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                          value: privacy,
                                          onChanged: (newValue) {
                                            setState(() {
                                              privacy = newValue;
                                            });
                                          },
                                          items: privacies
                                              .map((text, value) {
                                                return MapEntry(
                                                  text,
                                                  DropdownMenuItem<int>(
                                                    value: value,
                                                    child: new Text(
                                                      text,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              })
                                              .values
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: RaisedButton(
                              color: Color(0xff15161a),
                              padding: EdgeInsets.all(10),
                              child: Container(
                                height: 45,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.0),
                                  gradient: Gradients.blush,
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'RockWellStd',
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                // Validate returns true if the form is valid, otherwise false.
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return VideoRecorder();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RaisedButton(
                              color: Color(0xff15161a),
                              padding: EdgeInsets.all(10),
                              child: Container(
                                height: 45,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.0),
                                  gradient: Gradients.blush,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Share",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onPressed: () {
                                // Validate returns true if the form is valid, otherwise false.
                                if (_key.currentState.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  enableVideo();
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      content:
                                          Text("Enter Video Description")));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void exitConfirm(context) {
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
                              vertical: 10, horizontal: 20),
                          child: Text(
                            "Do you really want to discard "
                            "the video?",
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
                            VideoCompress.cancelCompression();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) {
                                  return HomePage();
                                },
                              ),
                              (Route<dynamic> route) => false,
                            );
                            return true;
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
                                "Yes",
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
                                "No",
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

  _willPopScope(context) {
    if (isVideoRecorded == true) {
      return exitConfirm(context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return HomePage();
          },
        ),
        (Route<dynamic> route) => false,
      );
    }
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

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // CameraDescription selectedCamera = cameras[selectedCameraIdx];
    // CameraLensDirection lensDirection = selectedCamera.lensDirection;
    if (size != null) {
      var deviceRatio = size.width / size.height;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black54),
      );
      return ModalProgressHUD(
        progressIndicator: showLoaderSpinner(),
        inAsyncCall: showLoader,
        child: WillPopScope(
          onWillPop: () async => _willPopScope(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    child: Center(
                      child: Transform.scale(
                        scale: (!controller.value.isInitialized)
                            ? 1
                            : controller.value.aspectRatio / deviceRatio,
                        child: new AspectRatio(
                          aspectRatio: (!controller.value.isInitialized)
                              ? 1
                              : controller.value.aspectRatio,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Center(
                                      child: (!controller.value.isInitialized)
                                          ? CircularProgressIndicator()
                                          : _cameraPreviewWidget(),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onDoubleTap: () {
                      _onSwitchCamera();
                    },
                  ),
                  Positioned(
                    bottom: 35,
                    left: 0,
                    child: _cameraTogglesRowWidget(),
                  ),
                  Positioned(
                    bottom: 35,
                    left: 85,
                    child: _cameraFlashRowWidget(),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _captureControlRowWidget11(),
                      ),
                    ),
                  ),
                  (controller == null ||
                          !controller.value.isInitialized ||
                          !controller.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 110,
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        height: 35.0,
                                        width: 35.0,
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: (videoLength == 15.0)
                                              ? Border.all(
                                                  color: Colors.white70,
                                                  width: 2)
                                              : Border.all(
                                                  color: Colors.white70,
                                                  width: 0),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              videoLength = 15.0;
                                            });
                                            print(videoLength);
                                          },
                                          child: Center(
                                            child: Text(
                                              "15s",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                        height: 35.0,
                                        width: 35.0,
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: (videoLength == 30.0)
                                              ? Border.all(
                                                  color: Colors.white70,
                                                  width: 2)
                                              : Border.all(
                                                  color: Colors.white70,
                                                  width: 0),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              videoLength = 30.0;
                                            });
                                            print(videoLength);
                                          },
                                          child: Center(
                                            child: Text(
                                              "30s",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              )),
                        )
                      : Container(),
                  (showProgressBar)
                      ? Positioned(
                          top: 10,
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width,
                            lineHeight: 5.0,
                            animationDuration: 100,
                            percent: videoProgressPercent,
                            progressColor: Color(0xffec4a63),
                          ),
                        )
                      : Container(),
                  (controller == null ||
                          !controller.value.isInitialized ||
                          !controller.value.isRecordingVideo)
                      ? Positioned(
                          top: 30,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                child: SizedBox(
                                  width: 140.0,
                                  child: MarqueeWidget(
                                    direction: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          audioFileName != ""
                                              ? audioFileName
                                              : "Select Sound ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          Icons.queue_music,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SoundList((sound) {
                                        setState(() {
                                          audioFileName = sound.title;
                                          audioFile = sound.url;
                                          audioId = sound.soundId;
                                          assetsAudioPlayer.open(
                                            Audio.network(sound.url),
                                            autoStart: false,
                                          );
                                        });
                                        Navigator.pop(context);
                                      }),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  (controller != null &&
                          controller.value.isInitialized &&
                          controller.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 35,
                          right: 90,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox.fromSize(
                                size: Size(
                                  50,
                                  50,
                                ), // button width and height
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor:
                                            Colors.pinkAccent, // splash color
                                        onTap: () {
                                          setState(() {
                                            reverse = reverse;
                                          });
                                          if (!videoRecorded) {
                                            onResumeButtonPressed();
                                            _animationController.forward();
                                          } else {
                                            onPauseButtonPressed();
                                            _animationController.stop();
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              !videoRecorded
                                                  ? "assets/icons/play-icon.png"
                                                  : "assets/icons/pause-icon.png",
                                              width: 50,
                                              height: 50,
                                            ), // icon
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    bottom: 35,
                    right: 0,
                    child: FlatButton(
                      child: Image.asset(
                        'assets/icons/gallery.png',
                        width: 50,
                      ),
                      onPressed: _uploadGalleryVideo,
//        icon: Icon(_getCameraLensIcon(lensDirection)),
                      /* label: Text(
            "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}"),*/
                    ),
                  ),
                  (isUploading == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black87,
                              ),
                              width: 200,
                              height: 170,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: CircularPercentIndicator(
                                        progressColor: Colors.pink,
                                        percent: uploadProgress,
                                        radius: 120.0,
                                        lineWidth: 8.0,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        center: Text(
                                          (uploadProgress * 100)
                                                  .toStringAsFixed(2) +
                                              "%",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    /*Container(
                                      child: Text(
                                        (uploadProgress * 100)
                                                .toStringAsFixed(2) +
                                            " %",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 2.0,
                                      child: LinearProgressIndicator(
                                        value: uploadProgress,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      /*StreamBuilder<bool>(
                          stream: _loadingStreamCtrl.stream,
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            print("loadingStream");
                            print(snapshot.data);
                            if (snapshot.data == true) {
                              return GestureDetector(
                                onTap: () {
//                                _flutterVideoCompress.cancelCompression();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.black54,
                                  child: Center(
                                    child: Container(
                                      color: Colors.black,
                                      width: 100,
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset(
                                                "assets/images/gif-logo.gif"),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            SizedBox(
                                              height: 2.0,
                                              child: LinearProgressIndicator(
                                                value: uploadProgress,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        )*/
                      : Container(),
                  _thumbnailWidget(),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  // IconData _getCameraLensIcon(CameraLensDirection direction) {
  //   switch (direction) {
  //     case CameraLensDirection.back:
  //       return Icons.camera_rear;
  //     case CameraLensDirection.front:
  //       return Icons.camera_front;
  //     case CameraLensDirection.external:
  //       return Icons.camera;
  //     default:
  //       return Icons.device_unknown;
  //   }
  // }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      return Row();
    }

    // CameraDescription selectedCamera = cameras[selectedCameraIdx];
    // CameraLensDirection lensDirection = selectedCamera.lensDirection;
    return FlatButton(
      child: Image.asset(
        'assets/icons/flip-camera.png',
        width: 50,
      ),
      onPressed: _onSwitchCamera,
//        icon: Icon(_getCameraLensIcon(lensDirection)),
      /* label: Text(
            "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}"),*/
    );
  }

  Widget _cameraFlashRowWidget() {
    // commented function
    return Row();
/*//    print("cameraFlashRowWidget");
    if (cameras == null) {
      return Row();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;
    print(lensDirection);
    */ /*if (lensDirection == "CameraLensDirection.front") {
      return Row();
    }
    if (lensDirection == "CameraLensDirection.back") {*/ /*
//    print(lensDirection);
    return Container(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        onTap: () async {
          */ /*bool hasTorch = await TorchCompat.hasLamp;
          if (hasTorch) {*/ /*
          if (!_toggleFlash) {
            FlutterTorch.turnOn();
            setState(() {
              _flashOn = "assets/icons/flash-on.png";
              _toggleFlash = true;
            });
          } else {
            FlutterTorch.turnOff();
            setState(() {
              _flashOn = "assets/icons/flash-off.png";
              _toggleFlash = false;
            });
          }
//          }
        },
        child: Container(
          child: Image.asset(
            _flashOn,
            width: 50.0,
//            height: 15.0,
          ),
        ),
      ),
    );
    */ /*} else {
      return Container(
        width: 15.0,
        height: 15.0,
      );
    }*/
  }

  Widget _captureControlRowWidget11() {
    return SizedBox.fromSize(
      size: Size(80, 80), // button width and height
      child: ClipOval(
        child: Container(
//          color: Color(0xffec4a63),
          child: Material(
            //color: Colors.transparent,
            child: InkWell(
              onTap: controller != null &&
                      controller.value.isInitialized &&
                      !controller.value.isRecordingVideo
                  ? _onRecordButtonPressed
                  : _onStopButtonPressed,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  controller != null &&
                          controller.value.isInitialized &&
                          !controller.value.isRecordingVideo
                      ? Image.asset(
                          "assets/icons/video-recording-icon.png",
                          height: 70,
                          width: 70,
                        )
                      : AnimatedBuilder(
                          animation: _sizeAnimation,
                          builder: (context, child) => Image.asset(
                            "assets/icons/stop-video.png",
                            height: _sizeAnimation.value,
                            width: _sizeAnimation.value,
                          ),
                        ), // icon
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
        /*Fluttertoast.showToast(
            msg: 'Camera error ${controller.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);*/
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    setState(() {
      isVideoRecorded = true;
      videoRecorded = true;
    });
    _startVideoRecording().then((String filePath) {
      if (filePath != null) {
        setState(() {
          showProgressBar = true;
          startTimer();
        });
      }
    });
  }

  void _onStopButtonPressed() {
    setState(() {
      isUploading = true;
      videoRecorded = false;
    });
    _stopVideoRecording().then((String outputVideo) async {
      print("_loadingStreamCtrl.true");
//      _loadingStreamCtrl.sink.add(true);
      if (mounted) setState(() {});
      if (outputVideo != null) {}
    });
  }

  Future<void> _startVideoPlayer(outputVideo) async {
    setState(() {
      showLoader = true;
    });
    print("outputVideo");
    print(outputVideo);
    final VideoPlayerController vcontroller =
        VideoPlayerController.network(outputVideo);
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
//        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
    setState(() {
      showLoader = false;
    });
  }

  void onPauseButtonPressed() {
    assetsAudioPlayer.pause();
    pauseVideoRecording().then((_) {
      if (mounted)
        setState(() {
          videoRecorded = false;
          timer.cancel();
        });
    });
  }

  void onResumeButtonPressed() {
    assetsAudioPlayer.play();
    resumeVideoRecording().then((_) {
      if (mounted)
        setState(() {
          videoRecorded = true;
          startTimer();
        });
    });
  }

  Future<String> _startVideoRecording() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    assetsAudioPlayer.play();

    // Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    /*final String currentTime =
        "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controller.startVideoRecording(filePath);
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  final Trimmer _trimmer = Trimmer();

  Future _uploadGalleryVideo() async {
    File file;
    final picker = ImagePicker();
    print("videoLength");
    print(videoLength);
    final pickedFile = await picker.getVideo(
      source: ImageSource.gallery,
    );
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    // File file = await ImagePicker.pickVideo(
    //   source: ImageSource.gallery,
    // );

    if (file != null) {
      await _trimmer.loadVideo(videoFile: file);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return TrimmerView(
          _trimmer,
          (output) async {
            setState(() {
              videoPath = output;
            });
            print("videoPath");
            Navigator.pop(context);
            setState(() {
              isUploading = true;
            });
            String responseVideo = "";
            responseVideo = await uploadVideo();
            if (responseVideo != "") {
              _pc1.open();
            }
          },
          videoLength,
          audioFile,
        );
      }));
    }
  }

  Future<String> _stopVideoRecording() async {
    setState(() {
      isUploading = true;
      print("_loadingStreamCtrl.true");
//      _loadingStreamCtrl.sink.add(true);
    });
    assetsAudioPlayer.pause();
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    final Directory appDirectory = await getExternalStorageDirectory();
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    /*final String currentTime =
        "$countVideos" + DateTime.now().millisecondsSinceEpoch.toString();*/
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String outputVideo = '$outputDirectory/$currentTime.mp4';
    // final String thumbNail = '$outputDirectory/${currentTime}.png';
    // final String thumbGif = '$outputDirectory/${currentTime}.gif';

    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String appDocPath = appDocDir.path;
    // String aFPath = '${appDirectory.path}/Audios/$audioFile';
    String responseVideo = "";
//    _loadingStreamCtrl.sink.add(true);
    final info = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
    );
    print("compressed");
    print(info.path);
    setState(() {
      videoPath = info.path;
    });
    responseVideo = await uploadVideo();
    if (progress >= 100.0) {
      print("progress 100");
    }
//    String aFPath = '${appDocDir.parent.path}' + '/$audioFile';
//    audioFile = "https://www.rachelallan.com/sara_rasines.mp3";
//    aFPath = "https://www.rachelallan.com/sarah_rasines.mp3";
    /*if (audioFile != "") {
      print("Merge Audio");
      _flutterFFmpeg
          .execute(
              "-i $videoPath -i $audioFile -c:v libx264 -c:a aac -ac 2 -ar 22050 -map 0:v:0 -map 1:a:0 -shortest $outputVideo")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      */ /*setState(() {
        videoPath = outputVideo;
      });*/ /*
    } else {
      _flutterFFmpeg
          .execute("-i $videoPath -vcodec libx265 -crf 28 $outputVideo")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      */ /*setState(() {
        videoPath = outputVideo;
      });*/ /*
    }*/
    /*_flutterFFmpeg
        .execute("-i $videoPath -ss 00:00:01.000 -vframes 1 $thumbNail")
        .then((rc) => print("FFmpeg process exited with rcthumb $rc"));
    _flutterFFmpeg
        .execute(
            "-ss 0 -t 3 -i $videoPath -vf 'fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse' -loop 0 $thumbGif")
        .then((rc) async {
      print("FFmpeg process exited with rcgif $rc");

      setState(() {
        isConverting = false;
        thumbFile = thumbNail;
        gifFile = thumbGif;
      });
    });*/
    if (responseVideo != '') {
//      _loadingStreamCtrl.sink.add(false);
      /*setState(() {
        videoPath = outputVideo;
      });*/
      await _startVideoPlayer(responseVideo);
    }

    return outputVideo;
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
    setState(() {
      cameraCrash = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
      ),
    );
    /*Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);*/
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Color(0xff2e2f34),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                    child: Container(
                  height: 80,
                  width: 80,
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage("assets/icons/camera-error.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ) //
                    ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: new Text("Camera Error",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Color(0xfff5ae78),
                          fontWeight: FontWeight.bold)),
                ) //
                    ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: new Text("Camera Stopped Wroking !!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                      )),
                ) //
                    ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                    padding: EdgeInsets.all(0),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [Color(0xffec4a63), Color(0xff7350c7)],
                        begin: FractionalOffset(0.0, 1),
                        end: FractionalOffset(0.4, 4),
                        stops: [0.1, 0.7],
                      )),
                      child: Center(
                        child: Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'RockWellStd',
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoRecorder(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getSessionData() async {
    sessions.getUserInfo().then((obj) {
      setState(() {
        userId = obj['user_id'];
        appToken = obj['app_token'];
      });
      print("UserTokens $userId $appToken");
    });
  }

  Future<String> getSound(soundId) async {
    print("getSound");
    print(soundId);
    print("UserTokens $userId $appToken");
    setState(() {
//      showLoader = true;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/get-sound";
      var response = await Dio().post(
        apiUrl,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        queryParameters: {
          "sound_id": soundId,
          "user_id": userId,
          "app_token": appToken,
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        if (response.data['status'] == 'success') {
          setState(() {
            var map = Map<String, dynamic>.from(response.data['data']);
            SoundModel sound = SoundModel.fromJson(map);
            audioFileName = sound.title;
            audioFile = sound.url;
            audioId = sound.soundId;
            assetsAudioPlayer.open(
              Audio.network(sound.url),
              autoStart: false,
            );
            showLoader = false;
          });
        } else {
          var msg = response.data['msg'];
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.red),
          );
        }
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      var msg = e;
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(msg, Colors.red),
      );
      setState(() {
        showLoader = false;
      });
    }
    return responsePath;
  }

  Future<String> enableVideo() async {
    print("enabledVideo");
    setState(() {
//      showLoader = true;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/video-enabled";
      var response = await Dio().post(
        apiUrl,
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
          "video_id": videoId,
          "description": description,
          "privacy": privacy,
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        if (response.data['status'] == 'success') {
          setState(() {
            isUploading = false;
            showLoader = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyProfile(),
            ),
          );
        } else {
          var msg = response.data['msg'];
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.red),
          );
        }
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      var msg = e;
//      _loadingStreamCtrl.sink.add(true);
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(msg, Colors.red),
      );
      setState(() {
        showLoader = false;
      });
    }
    return responsePath;
  }

  Future<String> uploadVideo() async {
    print("uploadVideo");
    setState(() {
//      showLoader = true;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/video-upload-2";
      String videoFileName = videoPath.split('/').last;
//      String gifFileName = gifFile.split('/').last;
//      String thumbFileName = thumbFile.split('/').last;
      FormData formData = FormData.fromMap({
        "video":
            await MultipartFile.fromFile(videoPath, filename: videoFileName),
        /*"gif_file":
            await MultipartFile.fromFile(gifFile, filename: gifFileName),
        "thumbnail_file":
            await MultipartFile.fromFile(thumbFile, filename: thumbFileName),*/
      });
      var response = await Dio().post(
        apiUrl,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        data: formData,
        queryParameters: {
          "user_id": userId,
          "app_token": appToken,
          "description": description,
          "sound_id": audioId
        },
        onSendProgress: (int sent, int total) {
          setState(() {
//            uploadProgress = sent / total * 100;
            uploadProgress = sent / total;
            if (uploadProgress >= 100) {
//              isUploading = false;
            }
          });
          print("$sent : $total");
          print("uploadProgress : $uploadProgress");
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        if (response.data['status'] == 'success') {
          setState(() {
            isUploading = false;
            showLoader = false;
            responsePath = response.data['file_path'];
            thumbPath = response.data['thumb_path'];
            videoId = response.data['video_id'];
          });
          return responsePath;
//          Navigator.pop(context);
        } else {
          var msg = response.data['msg'];
          var alertStyle = AlertStyle(
            animationType: AnimationType.fromTop,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            descStyle: TextStyle(
              fontSize: 16,
            ),
            animationDuration: Duration(milliseconds: 400),
            titleStyle: TextStyle(
              color: Colors.red,
              fontSize: 22,
              fontFamily: 'QueenCamelot',
            ),
            constraints:
                BoxConstraints.expand(width: MediaQuery.of(context).size.width),
          );
          Alert(
            context: context,
            style: alertStyle,
            type: AlertType.error,
            title: "Video Flagged",
            desc: msg,
            buttons: [
              DialogButton(
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) {
                      return HomePage();
                    },
                  ),
                  (Route<dynamic> route) => false,
                ),
                width: 120,
              )
            ],
          ).show();
          return "";
        }
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      var msg = e.toString();
      msg = "There is some error uploading video.";
//      _loadingStreamCtrl.sink.add(true);
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(msg, Colors.red),
      );
      setState(() {
        showLoader = false;
      });
      Timer(
          Duration(seconds: 2),
          () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false));
    }
    return responsePath;
  }
}

class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoRecorder(),
    );
  }
}

Future<void> main() async {
  runApp(VideoRecorderApp());
}

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  final ValueSetter<String> onVideoSaved;
  final double maxLength;
  final String sound;
  TrimmerView(this._trimmer, this.onVideoSaved, this.maxLength, this.sound);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  AssetsAudioPlayer assetsAudioPlayer = new AssetsAudioPlayer();
  bool _isPlaying = false;
  bool _progressVisibility = false;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  /*void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Video Length Alert"),
          content: new Text("Video should not exceed 15 secs"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
//                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  Future<String> _saveVideo() async {
    setState(() {
      if (_startValue + widget.maxLength * 1000 < _endValue) {
        _endValue = _startValue + widget.maxLength * 1000;
      }
      _progressVisibility = true;
    });
    print("_startValue");
    print(_startValue);
    print("_endValue");
    print(_endValue);
    print("widget.maxLength");
    print(widget.maxLength);
    String _value;

    await widget._trimmer
        .saveTrimmedVideo(
            applyVideoEncoding: true,
            startValue: _startValue,
            endValue: _endValue,
//            maxLength: widget.maxLength,
            customVideoFormat: '.mp4')
        .then((value) {
      setState(() {
        _progressVisibility = true;
        _value = value;
      });
    });
    return _value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(" "),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                RaisedButton(
                  color: Color(0xff15161a),
                  padding: EdgeInsets.all(0),
                  child: Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        gradient: Gradients.blush),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(
                              content: Text('Video Saved successfully'),
                            );
                            widget.onVideoSaved(outputPath);
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        },
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: VideoViewer(),
                ),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    sound: widget.sound,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(seconds: widget.maxLength.toInt()),
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      print("End changed");
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      print("onChangePlaybackState $_endValue $_startValue");
                      if (_endValue - _startValue >=
                          widget.maxLength * 1000 + 0.1) {
                        setState(() {
                          _endValue = _startValue + widget.maxLength * 1000;
                        });
                      }
                      if (widget.sound != "") {
                        if (assetsAudioPlayer
                                .currentPosition.value.inMilliseconds
                                .toDouble() >=
                            _endValue) {
                          assetsAudioPlayer.playOrPause();
                        }
                        if (!value) {
                          assetsAudioPlayer.pause();
                          assetsAudioPlayer.seek(Duration(seconds: 0));
                        } else {
                          assetsAudioPlayer.play();
                        }
                      }
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                RaisedButton(
                  color: Color(0xff15161a),
                  padding: EdgeInsets.all(0),
                  child: Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        gradient: Gradients.blush),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            _isPlaying ? "Pause" : "Play",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (widget.sound != "") {
                      if (assetsAudioPlayer.current.value == null) {
                        AssetsAudioPlayer.allPlayers().forEach((key, value) {
                          value.pause();
                        });
                        await assetsAudioPlayer
                            .open(Audio.network(widget.sound), autoStart: true);
                      } else {
                        AssetsAudioPlayer.allPlayers().forEach((key, value) {
                          value.pause();
                        });
                        assetsAudioPlayer.pause();
                      }
                    }
                    bool playbackState =
                        await widget._trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );

                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String durationToString(Duration duration) {
    String twoDigits(var n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes =
        twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
    String twoDigitSeconds =
        twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
