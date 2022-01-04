import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import '../widgets/MarqueWidget.dart';
import '../widgets/globals.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions.dart';
import '../models/Sounds.dart';

class SoundList extends StatefulWidget {
  final ValueSetter<SoundModel> onItemTap;
  SoundList(this.onItemTap);
  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends State<SoundList> {
//  Map<String, dynamic> sounds = {};
  int currentIndex;
  String currentFile;
  final AssetsAudioPlayer _assetsAudioPlayer =
      AssetsAudioPlayer.withId("4234234323asdsad");
  var jsonData;
  var _getSoundResult;
  var _getFavSoundResult;
  bool allPaused;
  int userId = 0;
  int videoId = 0;
  List<SoundModel> sounds = [];
  var _textController1 = TextEditingController();
  var _textController2 = TextEditingController();
  static String searchKeyword1 = '';
  static String searchKeyword2 = '';
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;

  ScrollController scrollController;

  int page = 1;

  bool moreResults = true;

  Color loaderBGColor = Colors.black;
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

  Future _getSounds() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    userId = pref.getInt('user_id');
    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    setState(() {
      showLoader = true;
    });
    print(userId);
    try {
      var response = await dio.get("api/v1/get-sounds",
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "page": page,
            "page_size": 10,
            "search": searchKeyword1,
            "login_id": userId
          });
      if (response.data['status'] == 'success') {
        jsonData = response.data;
        print("jsonData['data']");
        print(jsonData['data']);
        if (jsonData['data'].toString() == "[]") {
          print("jsonData blank");
          setState(() {
            moreResults = false;
          });
        }
        print("jsonData");
        print(jsonData);
        setState(() {
          showLoader = false;
        });
      }
    } catch (e) {
      print(e);
    }
    var map = Map<String, dynamic>.from(jsonData);
    var response = SoundModelList.fromJson(map);
//    print(response);
    return response;
  }

  Future _getFavSounds() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    userId = pref.getInt('user_id');
    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    setState(() {
      showLoader = true;
    });
    print(userId);
    try {
      var response = await dio.get("api/v1/fav-sounds",
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "page_size": 10,
            "search": searchKeyword2,
            "login_id": userId
          });
      if (response.data['status'] == 'success') {
        jsonData = response.data;
        print("jsonData");
        print(jsonData);
        setState(() {
          showLoader = false;
        });
      }
    } catch (e) {
      print(e);
    }
    var map = Map<String, dynamic>.from(jsonData);
    var response = SoundModelList.fromJson(map);
    return response;
  }

  @override
  void initState() {
    _assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });
    setState(() {
      _getSoundResult = _getSounds();
      _getFavSoundResult = _getFavSounds();
    });
    scrollController = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  /*SoundModel find(List<SoundModel> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: null,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Material(
          child: Container(
            color: Colors.grey[900],
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TabBar(
                      onTap: (index) {
                        if (index == 1) {
                          setState(() {
                            _getFavSoundResult = _getFavSounds();
                          });
                        } else {
                          setState(() {
                            _getSoundResult = _getSounds();
                          });
                        }
                      },
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[400],
                      indicatorWeight: 0.3,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Leuke Music",
                              style: TextStyle(
//                        color: Color(0xff06638f),
                                fontSize: 22,
                                fontFamily: 'RockWellStd',
                              ),
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Favourites",
                                  style: TextStyle(
//                        color: Color(0xff06638f),
                                    fontSize: 22,
                                    fontFamily: 'RockWellStd',
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  FontAwesomeIcons.solidHeart,
                                  size: 20,
                                  color: Colors.pinkAccent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 120,
                    child: TabBarView(
                      children: [
                        ModalProgressHUD(
                          progressIndicator: showLoaderSpinner(),
                          inAsyncCall: showLoader,
                          opacity: 1.0,
                          color: loaderBGColor,
                          child: FutureBuilder(
                              future: _getSoundResult,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  // return: show loading widget
                                }
                                if (snapshot.hasError) {
                                  // return: show error widget
                                }

                                SoundModelList soundList = snapshot.data ?? [];
                                if (page > 1) {
                                  sounds.addAll(soundList.data);
                                } else {
                                  sounds = soundList.data;
                                }
                                return Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 2,
                                      child: Container(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                        child: TextField(
                                          controller: _textController1,
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 16.0,
                                          ),
                                          obscureText: false,
                                          keyboardType: TextInputType.text,
                                          onChanged: (String val) {
                                            searchKeyword1 = val;
                                            if (val.length > 2) {
                                              Timer(Duration(seconds: 2), () {
                                                _getSoundResult = _getSounds();
                                              });
                                            }
                                          },
                                          decoration: new InputDecoration(
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white54,
                                                width: 0.3,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white54,
                                                  width: 0.3),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white54,
                                                  width: 0.3),
                                            ),
                                            hintText: "Search",
                                            hintStyle: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white54),
                                            //contentPadding:EdgeInsets.all(10),

                                            suffixIcon: IconButton(
                                              padding:
                                                  EdgeInsets.only(bottom: 12),
                                              onPressed: () {
                                                _textController1.clear();
                                                searchKeyword1 = "";
                                                _getSoundResult = _getSounds();
                                              },
                                              icon: Icon(
                                                Icons.clear,
                                                color: searchKeyword1 != ""
                                                    ? Colors.white54
                                                    : Colors.transparent,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                200,
                                        child:
                                            GroupedListView<SoundModel, String>(
                                          controller: scrollController,
                                          elements: sounds,
                                          groupBy: (element) =>
                                              element.category +
                                              "_" +
                                              element.catId,
                                          order: GroupedListOrder.DESC,
//                                        useStickyGroupSeparators: true,
                                          groupSeparatorBuilder:
                                              (String value) {
                                            var full = value.split("_");
                                            return Container(
                                              color: Colors.black,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      full[0],
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SoundCatList(
                                                              widget.onItemTap,
                                                              int.parse(
                                                                  full[1]),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        "View More",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          itemBuilder: (c, e) {
                                            return PlayerWidget(
                                                sound: e,
                                                onItemTap: (e) {
                                                  widget.onItemTap(e);
                                                });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        ModalProgressHUD(
                          progressIndicator: showLoaderSpinner(),
                          inAsyncCall: showLoader,
                          opacity: 1.0,
                          color: Colors.black,
                          child: FutureBuilder(
                              future: _getFavSoundResult,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  // return: show loading widget
                                }
                                if (snapshot.hasError) {
                                  // return: show error widget
                                }
//                    print(snapshot.data);
                                SoundModelList soundList = snapshot.data ?? [];

                                print(soundList.data);

                                return Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 2,
                                      child: Container(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                        child: TextField(
                                          controller: _textController2,
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 16.0,
                                          ),
                                          obscureText: false,
                                          keyboardType: TextInputType.text,
                                          onChanged: (String val) {
                                            searchKeyword2 = val;
                                            if (val.length > 2) {
                                              Timer(Duration(seconds: 2), () {
                                                _getFavSoundResult =
                                                    _getFavSounds();
                                              });
                                            }
                                          },
                                          decoration: new InputDecoration(
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white54,
                                                  width: 0.3),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white54,
                                                  width: 0.3),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white54,
                                                  width: 0.3),
                                            ),
                                            hintText: "Search",
                                            hintStyle: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white54),
                                            //contentPadding:EdgeInsets.all(10),
                                            suffixIcon: IconButton(
                                              padding:
                                                  EdgeInsets.only(bottom: 12),
                                              onPressed: () {
                                                _textController2.clear();
                                                setState(() {
                                                  searchKeyword2 = "";
                                                });
                                                _getFavSoundResult =
                                                    _getFavSounds();
                                              },
                                              icon: Icon(
                                                Icons.clear,
                                                color: searchKeyword2 != ""
                                                    ? Colors.white54
                                                    : Colors.transparent,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 48.0),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .8 -
                                              45,
                                          child: ListView.builder(
                                              itemCount: soundList.data.length,
                                              itemBuilder: (context, index) {
                                                return PlayerWidget(
                                                    sound:
                                                        soundList.data[index],
                                                    onItemTap: (e) {
                                                      widget.onItemTap(soundList
                                                          .data[index]);
                                                    });
                                              }),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scrollListener() {
    print(scrollController.position.extentAfter);
    if (scrollController.position.extentAfter == 0) {
      setState(() {
        loaderBGColor = Colors.black26;
        if (moreResults) {
          page++;
          _getSoundResult = _getSounds();
        }
      });
    }
  }
}

class PlayerWidget extends StatefulWidget {
  final SoundModel sound;
  final ValueSetter<SoundModel> onItemTap;
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();

  const PlayerWidget({
    @required this.sound,
    @required this.onItemTap,
  });
}

class _PlayerWidgetState extends State<PlayerWidget> {
  int userId = 0;
  int videoId = 0;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  AssetsAudioPlayer assetsAudioPlayer = new AssetsAudioPlayer();
  Future<dynamic> _setFavSounds(soundId, set) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    userId = pref.getInt('user_id');
    String appToken = pref.getString('app_token');

    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    setState(() {
      showLoader = true;
    });

    try {
      var response = await dio.post(
        "api/v1/set-fav-sound",
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        queryParameters: {
          "login_id": userId,
          "app_token": appToken,
          "sound_id": soundId,
          "set": set,
        },
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          setState(() {
            showLoader = false;
          });
        }
        return response.data['msg'];
      } else {
        return "There's some server side issue";
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    assetsAudioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
      theme: NeumorphicThemeData(
        accentColor: Colors.black,
        variantColor: Colors.black,
        intensity: 0.8,
        lightSource: LightSource.topLeft,
        shadowLightColor: Colors.black54,
        shadowDarkColor: Colors.black54,
      ),
      child: StreamBuilder(
        stream: assetsAudioPlayer.isPlaying,
        initialData: false,
        builder: (context, snapshotPlaying) {
          final isPlaying = snapshotPlaying.data;
          return Neumorphic(
            margin: EdgeInsets.all(2),
            style: NeumorphicStyle(
              color: Colors.black,
              shadowLightColor: Colors.black54,
              shadowDarkColor: Colors.black54,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
//                        color: Colors.grey,
            ),
            padding: const EdgeInsets.all(8.0),
            child: NeumorphicTheme(
              darkTheme: NeumorphicThemeData(
                baseColor: Colors.black54,
                accentColor: Colors.black54,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print("Gesture");
                                if (assetsAudioPlayer.current.value == null) {
                                  AssetsAudioPlayer.allPlayers()
                                      .forEach((key, value) {
                                    value.pause();
                                  });
                                  assetsAudioPlayer.open(
                                      Audio.network(widget.sound.url),
                                      autoStart: true);
                                } else {
                                  AssetsAudioPlayer.allPlayers()
                                      .forEach((key, value) {
                                    value.pause();
                                  });
                                  assetsAudioPlayer.playOrPause();
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(8.0),
                                child: Image.asset(
                                  isPlaying
                                      ? "assets/icons/pause-icon.png"
                                      : "assets/icons/play-icon.png",
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        this.widget.sound.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: MarqueeWidget(
                                              child: Text(
                                                this.widget.sound.album,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Text(
                                            "Duration: " +
                                                widget.sound.duration
                                                    .toString() +
                                                " sec",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Neumorphic(
                                  style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.circle(),
                                    depth: 8,
                                    surfaceIntensity: 1,
                                    shadowLightColor: Colors.black54,
                                    shadowDarkColor: Colors.black54,
                                    shape: NeumorphicShape.concave,
                                  ),
                                  child: NeumorphicRadio(
                                    style: NeumorphicRadioStyle(
                                      boxShape: NeumorphicBoxShape.circle(),
                                    ),
                                    value: LoopMode.playlist,
                                    child: Image.asset(
                                      widget.sound.fav > 0
                                          ? "assets/icons/like-icon-on.png"
                                          : "assets/icons/like-icon-off.png",
                                      width: 26,
                                      height: 26,
                                    ),
                                    onChanged: (newValue) async {
                                      String msg = await _setFavSounds(
                                          widget.sound.soundId,
                                          widget.sound.fav > 0
                                              ? "false"
                                              : "true");
                                      if (msg != null && msg.contains('set')) {
                                        setState(() {
                                          widget.sound.fav = 1;
                                        });
                                      } else {
                                        setState(() {
                                          widget.sound.fav = 0;
                                        });
                                      }
                                      Scaffold.of(context).showSnackBar(
                                        Functions.toast(
                                          msg,
                                          Colors.pinkAccent,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    assetsAudioPlayer.playOrPause();
                                    widget.onItemTap(this.widget.sound);
                                  },
                                  child: isPlaying
                                      ? Image.asset(
                                          "assets/icons/select-sound.png",
                                          height: 30,
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                            widget.sound.usedTimes > 0
                                ? Container(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Used " +
                                              widget.sound.usedTimes.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

//  }
//}
class SoundCatList extends StatefulWidget {
  final ValueSetter<SoundModel> onItemTap;
  final int catId;
  SoundCatList(this.onItemTap, this.catId);
  @override
  _SoundCatListState createState() => _SoundCatListState();
}

class _SoundCatListState extends State<SoundCatList> {
  Map<String, dynamic> sounds = {};
  int currentIndex;
  ScrollController scrollController;
  String currentFile;
  var jsonData;
  var _getSoundResult;
  bool allPaused;
  var response;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  List soundsList = [];
  var _textController = TextEditingController();

  static String searchKeyword = '';

  int page = 1;
  bool moreResults = true;
  Color loaderBGColor = Colors.black;

  Future _getSounds() async {
    print("_getSounds");
    Dio dio = new Dio();
    dio.options.baseUrl = apiUrlRoot;
    setState(() {
      showLoader = true;
    });
    try {
      var response = await dio.get("api/v1/get-cat-sounds",
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {
            "page": page,
            "page_size": 10,
            "search": searchKeyword,
            "cat_id": widget.catId
          });
      if (response.data['status'] == 'success') {
        jsonData = response.data;
        print("jsonData");
        print(jsonData);
        setState(() {
          showLoader = false;
        });
        var map = Map<String, dynamic>.from(response.data);
        print("map");
        print(map);
//        var res = SoundModelList.fromJson(map);
        print("response");
//        print(res);
        SoundModelList soundList = SoundModelList.fromJson(map);
        print("soundList.data");
        print(soundList.data);
        setState(() {
          if (soundList.data.length > 0) {
            if (soundsList.length > 0) {
              print("second");
              soundsList.addAll(soundList.data);
            } else {
              print("first");
              soundsList = soundList.data;
            }
          } else {
            setState(() {
              moreResults = false;
            });
          }
        });
        return soundList;
      }
    } catch (e) {
      print(e);
    }
  }

  void _scrollListener() {
    print(scrollController.position.extentAfter);
    if (scrollController.position.extentAfter == 0) {
      setState(() {
        loaderBGColor = Colors.black26;
        if (moreResults) {
          page++;
          _getSounds();
        }
      });
    }
  }

  final AssetsAudioPlayer _assetsAudioPlayer =
      AssetsAudioPlayer.withId("4234234323asdsad");

  @override
  void initState() {
    _assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });
    _getSoundResult = _getSounds();
    scrollController = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  /*SoundModel find(List<SoundModel> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.grey[900],
        child: ModalProgressHUD(
          progressIndicator: showLoaderSpinner(),
          inAsyncCall: showLoader,
          opacity: 1.0,
          color: loaderBGColor,
          child: FutureBuilder(
            future: _getSoundResult,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // return: show loading widget
              }
              if (snapshot.hasError) {
                // return: show error widget
              }
              print(snapshot.data);
              // var soundList = snapshot.data ?? [];
              /*print("soundsList");
              print(soundsList);*/
              return SafeArea(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 2,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16.0,
                          ),
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            searchKeyword = val;
                            if (val.length > 2) {
                              Timer(Duration(seconds: 2), () {});
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
                            hintStyle: TextStyle(
                                fontSize: 16.0, color: Colors.white54),
                            //contentPadding:EdgeInsets.all(10),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.only(bottom: 12),
                              onPressed: () {
                                _textController.clear();
                                _getSoundResult = _getSounds();
                              },
                              icon: Icon(
                                Icons.clear,
                                color: searchKeyword != ""
                                    ? Colors.white54
                                    : Colors.transparent,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Container(
                          color: Colors.black,
                          height: MediaQuery.of(context).size.height - 150,
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: soundsList.length,
                            itemBuilder: (context, index) {
                              return PlayerWidget(
                                sound: soundsList[index],
                                onItemTap: (e) {
                                  widget.onItemTap(soundsList[index]);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
