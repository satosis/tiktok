import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions.dart';
import '../widgets/globals.dart';
import '../widgets/roundedDiagonal.dart';
import 'SlidingUpPanelContainer.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  bool showLoader = false;
  String _timezone = 'Unknown';
  int userId;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    "https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/user.gender.read",
    "https://www.googleapis.com/auth/user.birthday.read",
    "https://www.googleapis.com/auth/user.phoneNumbers.read",
    "https://www.googleapis.com/auth/user.addresses.read",
  ]);

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<void> initPlatformState() async {
    String timezone;
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }
    if (!mounted) return;
    setState(() {
      _timezone = timezone;
    });
  }

  _loginFb() async {
    final FacebookLoginResult result = await facebookSignIn.logIn([
      'email',
      'user_birthday',
      'user_gender',
      'user_location',
      'user_likes'
    ]);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture,birthday,gender,languages,location{location}&access_token=${accessToken.token}');
        final profile = jsonDecode(graphResponse.body);
        final Map<String, String> userInfo = {
          'fname': profile['first_name'] != null ? profile['first_name'] : "",
          'lname': profile['last_name'] != null ? profile['last_name'] : "",
          'email': profile['email'] != null ? profile['email'] : "",
          'mobile':
              profile['primary_phone'] != null ? profile['primary_phone'] : "",
          'gender': profile['gender'] != null ? profile['gender'] : "",
          'user_dp': profile['picture']['data']['url'] != null
              ? profile['picture']['data']['url']
              : "",
          'dob': profile['birthday'] != null ? profile['birthday'] : "",
          'country': profile['location']['location']['country'] != null
              ? profile['location']['location']['country']
              : "",
          'languages': "",
          'player_id': "",
          'time_zone': _timezone,
          'login_type': "FB",
        };
        registerApi(userInfo);
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }
  }

  registerApi(var userInfo) async {
    setState(() {
      showLoader = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Dio dio = new Dio(); // with default Options
    dio.options.baseUrl = apiUrlRoot;

    try {
      final response = await dio.post(
        "api/v1/register-social",
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': apiUser,
            'KEY': apiKey,
          },
        ),
        data: {
          'fname': userInfo['fname'],
          'lname': userInfo['lname'],
          'email': userInfo['email'],
          'mobile': userInfo['mobile'],
          'gender': userInfo['gender'],
          'user_dp': userInfo['user_dp'],
          'dob': userInfo['dob'],
          'country': userInfo['country'],
          'languages': userInfo['languages'],
          'player_id': userInfo['player_id'],
          'login_type': userInfo['login_type'],
          'time_zone': userInfo['time_zone'],
        },
      );
      if (response.statusCode == 200) {
        var jsonData = response.data;
        if (jsonData['status'] == "success") {
          var userData = jsonData['content'];
          prefs.setInt("user_id", userData['user_id']);
          prefs.setString("username", userData['username']);
          prefs.setString("name", userData['fname'] + " " + userData['lname']);
          prefs.setString("email", userData['email']);
          prefs.setString("mobile", userData['mobile']);
          prefs.setString("dob", userData['dob']);
          prefs.setInt("active", userData['active']);
          prefs.setString("gender", userData['gender']);
          prefs.setString("user_dp", userData['user_dp']);
          prefs.setString("app_token", userData['app_token']);
          prefs.setString("country", userData['country']);
          prefs.setString("languages", userData['languages']);
          prefs.setString("player_id", userData['player_id']);
          prefs.setString("time_zone", userData['time_zone']);
          prefs.setString("login_type", userData['login_type']);
          prefs.setString("last_active", userData['last_active']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          setState(() {
            showLoader = false;
          });
        } else {
          setState(() {
            showLoader = false;
          });
          var jsonData = jsonDecode(response.data);
          var msg = jsonData['msg'];
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.redAccent),
          );
        }
      } else {
        setState(() {
          showLoader = false;
        });
        var msg = "There are some errors in registration process.";
        _scaffoldKey.currentState.showSnackBar(
          Functions.toast(msg, Colors.redAccent),
        );
      }
    } catch (error) {
      setState(() {
        showLoader = false;
      });
      throw error;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  _loginGoogle() async {
    await googleSignIn.signIn();
    print(googleSignIn.currentUser);
    print(googleSignIn.currentUser?.displayName);
    print(googleSignIn.currentUser?.email);
    print(googleSignIn.currentUser?.photoUrl);
    await getGoogleInfo().then((info) {
      var userInfo = info;
      print(userInfo);
    });
  }

  Future<String> getGoogleInfo() async {
    final headers = await googleSignIn.currentUser.authHeaders;
    final r = await http.get(
        "https://people.googleapis.com/v1/people/me?personFields=addresses,birthdays,phoneNumbers,genders",
        headers: {"Authorization": headers["Authorization"]});
    var userInfo = Map();
    userInfo['gender'];
  }

  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showLoader,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            color: Color(0XFF15161a),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'QueenCamelot',
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.024),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.8,
                    child: Stack(
                      children: <Widget>[
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationX(math.pi),
                          child: ClipPath(
                            clipper: RoundedDiagonalPathClipper(),
                            child: Container(
                              height: MediaQuery.of(context).size.height / .2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(45.0),
                                ),
                                color: Color(0XFF2e2f34),
                              ),
                              child: null,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 15,
                            right: 15,
                          ),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.04),
                              Text(
                                "Create An Account",
                                style: TextStyle(
                                  color: Color(0xfffcb37b),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'QueenCamelot',
                                  fontSize: 30,
                                ),
                              ),
                              Container(
                                color: Colors.grey[400],
                                height: .4,
                                width: MediaQuery.of(context).size.width * .7,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.011),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              RaisedButton(
                                padding: EdgeInsets.all(0),
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffec4a63),
                                        Color(0xff7350c7)
                                      ],
                                      begin: FractionalOffset(0.0, 1),
                                      end: FractionalOffset(0.4, 4),
                                      stops: [0.1, 0.7],
                                    ),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'USE PHONE OR EMAIL',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, 'sign-up-dob');
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.015,
                              ),
                              Text(
                                "OR",
                                style: TextStyle(
                                  height: MediaQuery.of(context).size.height *
                                      0.002,
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'RockWellStd',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.006,
                              ),
                              Text(
                                "Continue With",
                                style: TextStyle(
                                  height: MediaQuery.of(context).size.height *
                                      0.002,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'RockWellStd',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      width: 40,
                                      child: GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          width: 35,
                                          child: Image.asset(
                                              "assets/icons/facebook.png"),
                                          height: 35,
                                        ),
                                        onTap: () {
                                          print("SIGNUP FB");
                                          _loginFb();
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: .2,
                                    height: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      width: 35,
                                      child: GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          width: 35,
                                          child: Image.asset(
                                              "assets/icons/google.png"),
                                          height: 35,
                                        ),
                                        onTap: () {
                                          _loginGoogle();
                                        },
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
                  Transform.translate(
                    offset: Offset(0, -60),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3.7,
                      child: Stack(
                        children: <Widget>[
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: ClipPath(
                              clipper: RoundedDiagonalPathClipper(),
                              child: Container(
                                height: MediaQuery.of(context).size.height / .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(45.0),
                                  ),
                                  color: Color(0XFF2e2f34),
                                ),
                                child: null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 30,
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Already ",
                                          style: TextStyle(
                                            height: 1.55,
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "have an account ",
                                          style: TextStyle(
                                            height: 1.55,
                                            color: Color(0xfffcb37b),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                        colors: [
                                          Color(0xffec4a63),
                                          Color(0xff7350c7)
                                        ],
                                        begin: FractionalOffset(0.0, 1),
                                        end: FractionalOffset(0.4, 4),
                                        stops: [0.1, 0.7],
                                      )),
                                      child: Center(
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'RockWellStd',
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'login');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class MyDateTimePicker extends StatefulWidget {
  @override
  _MyDateTimePickerState createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: _dateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }
}
