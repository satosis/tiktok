import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/SlidingUpPanelContainer.dart';
import 'routes.dart' as router;
import 'services/SessionManager.dart';
import 'widgets/globals.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.landscapeLeft,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      title: "Leuke",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var loggedInUser = new Map();
  String uniqueId;
  final SessionManager sessions = new SessionManager();

  @override
  void initState() {
    super.initState();
    userUniqueId();
    checkInternetConnection(true);
  }

  userUniqueId() async {
    print("userUniqueId");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      uniqueId = (pref.getString('unique_id') == null)
          ? ""
          : pref.getString('unique_id');
      if (uniqueId == "") {
        Dio dio = new Dio();
        dio.options.baseUrl = apiUrlRoot;
        try {
          var response = await dio.post(
            "api/v1/get-unique-id",
            options: Options(
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'USER': apiUser,
                'KEY': apiKey,
              },
            ),
          );
          if (response.data['status'] == 'success') {
            uniqueId = response.data['unique_token'];
            pref.setString("unique_id", uniqueId);
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }

  redirectToHome() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
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
                color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Container(
                  height: 50,
                  width: 50,
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage("assets/images/no-internet.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ) //
                    ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: new Text(
                      "Internet Connection Error",
                      style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: new Text(
                      "Please check your internet connectivity and try again",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      )),
                ) //
                    ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
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
                          'Retry',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'RockWellStd',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    onPressed: () {
                      checkInternetConnection(false);
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

  checkInternetConnection(bool showPopup) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (showPopup) {
        showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: dialogContent(context),
          ),
        );
      }
    } else {
      Timer(Duration(milliseconds: 700), () => redirectToHome());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 800, maxWidth: 400),
      child: Stack(children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Color(0XFF15161a),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Image.asset(
                  'assets/images/gif-logo.gif',
                  width: 200,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                child: Image.asset(
                  'assets/images/logo-name.gif',
                  width: 200,
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
