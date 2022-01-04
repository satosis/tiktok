import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

var date = new DateTime.now();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  bool showLoader = false;
  String _timezone = 'Unknown';
  int userId;
  int _curIndex;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String email = '';
  String mobile = '';
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    /*"https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/user.gender.read",
    "https://www.googleapis.com/auth/user.birthday.read",
    "https://www.googleapis.com/auth/user.phoneNumbers.read",
    "https://www.googleapis.com/auth/user.addresses.read",*/
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
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(720).height(720),birthday,gender,languages,location{location}&access_token=${accessToken.token}');
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

  _loginGoogle() async {
    await googleSignIn.signIn();
    print(googleSignIn.currentUser);
    print(googleSignIn.currentUser?.displayName);
    print(googleSignIn.currentUser?.email);
    print(googleSignIn.currentUser?.photoUrl);
    await getGoogleInfo().then((info) {
      var userInfo = info;
    });
  }

  Future<String> getGoogleInfo() async {
    final headers = await googleSignIn.currentUser.authHeaders;
    final r = await http.get(
        "https://people.googleapis.com/v1/people/me?personFields=addresses,birthdays,phoneNumbers,genders",
        headers: {"Authorization": headers["Authorization"]});
    final response = jsonDecode(r.body);
    print(response);
    var userInfo = Map();
    userInfo['gender'];
  }

  registerApi(var userInfo) async {
    setState(() {
      showLoader = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("Entered Register");
    Dio dio = new Dio(); // with default Options
    dio.options.baseUrl = apiUrlRoot;
    try {
      print("try");

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
      var msg = "There are some errors in registration process.";
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(msg, Colors.redAccent),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Widget build(BuildContext context) {
    Future<String> loginApi() async {
      showLoader = true;
      String apiUrl = apiUrlRoot + "api/v1/login";
      await http
          .post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'USER': apiUser,
          'KEY': apiKey,
        },
        body: jsonEncode({
          'email': email,
          'mobile': mobile,
          'timezone': _timezone,
          'login_type': 'OT',
        }),
      )
          .then((response) async {
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          showLoader = false;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            userId = jsonData['content']['user_id'];
            Navigator.of(context).pushNamed('sign-up-otp',
                arguments: {'user_id': userId, 'msg': jsonData['msg']});
          } else {
            var jsonData = jsonDecode(response.body);
            var msg = jsonData['msg'];
            _scaffoldKey.currentState.showSnackBar(
              Functions.toast(msg, Colors.redAccent),
            );
          }
        } else {
          var msg = "There are some errors in registration process.";
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.redAccent),
          );
        }
        setState(() {
          showLoader = false;
        });
      }).catchError((error) {
        throw error;
      });
    }

    formSubmit() {
      if (_key.currentState.validate()) {
        _key.currentState.save();
        loginApi();
      } else {
        setState(() {
          _validate = true;
        });
      }
    }

    String validateEmail(String value) {
      bool emailValid =
          RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
              .hasMatch(value);
      if (value.length == 0) {
        return "Email field is required!";
      } else if (!emailValid) {
        return "Email field is required!";
      } else {
        return null;
      }
    }

    String validateMobile(String value) {
      if (value.length == 0) {
        return "Mobile field is required!";
      } else if (value.length > 10) {
        return "Mobile number length must not exceed 10 digits";
      } else {
        return null;
      }
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          exit(0);
        },
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: false,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: showLoader,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  color: Color(0XFF15161a),
                  child: Center(
                    child: Form(
                      key: _key,
                      autovalidate: _validate,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'QueenCamelot',
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.039),
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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              .2,
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.022),
                                      Text(
                                        "Login To Your Account",
                                        style: TextStyle(
                                          color: Color(0xfffcb37b),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'QueenCamelot',
                                          fontSize: 26,
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .005),
                                      Container(
                                        color: Colors.black26,
                                        height: 1,
                                        width: 270,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .020),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .015),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 35.0, right: 35.0),
                                        child: DefaultTabController(
                                          length: 2,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: TabBar(
                                                  onTap: (index) {
                                                    setState(() {
                                                      _curIndex = index;
                                                      mobile = '';
                                                      email = '';
                                                    });
                                                  },
                                                  indicatorColor:
                                                      Color(0xfffcb37b),
                                                  labelColor: Color(0xfffcb37b),
                                                  unselectedLabelColor:
                                                      Colors.grey[400],
                                                  indicatorWeight: 2.0,
                                                  tabs: [
                                                    Tab(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "Email",
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                            fontFamily:
                                                                'RockWellStd',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Tab(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "Mobile",
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                            fontFamily:
                                                                'RockWellStd',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    10,
                                                child: TabBarView(children: [
                                                  Container(
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'RockWellStd',
                                                        fontSize: 16.0,
                                                        color: Colors.white,
                                                      ),
                                                      validator: _curIndex == 0
                                                          ? validateEmail
                                                          : null,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (String val) {
                                                        email = val;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        errorStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          wordSpacing: 2.0,
                                                        ),
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        errorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.red,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        prefixIcon: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.email,
                                                              color:
                                                                  Colors.white,
                                                              size: 24.0,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          10.0),
                                                              child: Container(
                                                                color: Colors
                                                                    .white,
                                                                width: 1,
                                                                height: 30,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 17),
                                                        hintText:
                                                            "Enter Your Email",
                                                        hintStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      validator: _curIndex == 1
                                                          ? validateMobile
                                                          : null,
                                                      onSaved: (String val) {
                                                        mobile = val;
                                                      },
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.white,
                                                        fontFamily:
                                                            'RockWellStd',
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        errorStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          wordSpacing: 2.0,
                                                        ),
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        errorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        prefixIcon: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Text(
                                                              "+91",
                                                              style: TextStyle(
                                                                fontSize: 16.0,
                                                                height: 0.9,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'RockWellStd',
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 10.0,
                                                                right: 13,
                                                              ),
                                                              child: Container(
                                                                color: Colors
                                                                    .white,
                                                                width: 1,
                                                                height: 30,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 17),
                                                        hintText:
                                                            "Enter Your Mobile",
                                                        hintStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "OR",
                                        style: TextStyle(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.002,
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'RockWellStd',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.006,
                                      ),
                                      Text(
                                        "Continue With",
                                        style: TextStyle(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                  _loginFb();
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            width: 1,
                                            height: 40,
                                            color: Color(0XFF15161a),
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
                                SizedBox(
                                  height: 130,
                                ),
                                SizedBox(height: 20.0),
                                Positioned(
                                  bottom: 15,
                                  right: 15,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.09,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: GestureDetector(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                            "assets/icons/next-b.png"),
                                      ),
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        formSubmit();
                                      },
                                    ),
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
                                        height:
                                            MediaQuery.of(context).size.height /
                                                .2,
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
                                      width: MediaQuery.of(context).size.width -
                                          30,
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
                                                  "have an account? ",
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
                                                  begin:
                                                      FractionalOffset(0.0, 1),
                                                  end: FractionalOffset(0.4, 4),
                                                  stops: [0.1, 0.7],
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontFamily: 'RockWellStd',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, 'sign-up');
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
            ),
          ),
        ),
      ),
    );
  }
}
