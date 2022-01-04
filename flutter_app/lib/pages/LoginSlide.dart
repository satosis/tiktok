import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../widgets/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../functions.dart';
import 'SlidingUpPanelContainer.dart';

class LoginSlide extends StatefulWidget {
  final PanelController pc3;
  final VideoPlayerController videoController;
  LoginSlide(this.pc3, this.videoController);
  @override
  _LoginSlideState createState() => _LoginSlideState();
}

class _LoginSlideState extends State<LoginSlide> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  bool showLoader = false;
  String _timezone = 'Unknown';
  int userId;
  String uniqueId = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    "https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/user.gender.read",
    "https://www.googleapis.com/auth/user.birthday.read",
    //"https://www.googleapis.com/auth/user.phoneNumbers.read",
    "https://www.googleapis.com/auth/user.addresses.read",
  ]);

  /*String _pickFirstNamedContact(Map<String, dynamic> data) {
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
  }*/

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
      /*'user_birthday',
      'user_gender',
      'user_location',
      'user_likes'*/
    ]);
    print("result.status" + result.status.toString());
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        /*final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(720).height(720),birthday,gender,languages,location{location}&access_token=${accessToken.token}');*/
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(720).height(720)&access_token=${accessToken.token}');
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
          'country': "",
          /*'country': profile['location']['location']['country'] != null
              ? profile['location']['location']['country']
              : "",*/
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
    var name = googleSignIn.currentUser.displayName.split(' ');
    var firstName = name[0];
    var lastName = name[name.length - 1];
    var email = googleSignIn.currentUser?.email;
    var userDp = googleSignIn.currentUser?.photoUrl;
    var gender = "";
    var dob = "";
    var mobile = "";
    var country = "";
    userDp.replaceAll('=s96-c', '=s512-c');
    await getGoogleInfo().then((info) {
      setState(() {
        gender = info['gender'] != null ? info['gender'] : "";
        dob = info['dob'] != null ? info['dob'] : "";
        mobile = info['mobile'] != null ? info['mobile'] : "";
        country = info['country'] != null ? info['country'] : "";
      });
    });

    final Map<String, String> userInfo = {
      'fname': firstName != null ? firstName : "",
      'lname': lastName != null ? lastName : "",
      'email': email != null ? email : "",
      'mobile': mobile != null ? mobile : "",
      'gender': gender != null ? gender : "",
      'user_dp': userDp != null ? userDp : "",
      'dob': dob != null ? dob : "",
      'country': country != null ? country : "",
      'languages': "",
      'player_id': "",
      'time_zone': _timezone,
      'login_type': "G",
    };
    print(userInfo);
    registerApi(userInfo);
  }

  Future getGoogleInfo() async {
    final headers = await googleSignIn.currentUser.authHeaders;
    final r = await http.get(
        "https://people.googleapis.com/v1/people/me?personFields=birthdays,genders,phoneNumbers,",
        headers: {"Authorization": headers["Authorization"]});
    final response = jsonDecode(r.body);
    print(response);
    var gender = response['genders'][0]['value'] == "male"
        ? "M"
        : (response['genders'][0]['value'] == "female" ? "F" : "O");
    var dob = response['birthdays'][0]['date']['year'].toString() +
        '-' +
        response['birthdays'][0]['date']['month'].toString() +
        '-' +
        response['birthdays'][0]['date']['day'].toString();
    var mobile = "";
    var country = "";
    final Map<String, String> userInfo = {
      'mobile': mobile != null ? mobile : "",
      'gender': gender != null ? gender : "",
      'dob': dob != null ? dob : "",
      'country': country != null ? country : "",
      'languages': "",
      'player_id': "",
      'time_zone': _timezone,
      'login_type': "G",
    };
    return userInfo;
  }

  registerApi(var userInfo) async {
    print("registerApi");
    setState(() {
      showLoader = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uniqueId = (prefs.getString('unique_id') == null)
        ? ""
        : prefs.getString('unique_id');
//    print("uniqueId");
//    print(uniqueId);
//    await prefs.clear();
    print("Entered Register");
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
          'unique_token': uniqueId,
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
          prefs.setString("unique_id", uniqueId);
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
          Navigator.pushReplacement(
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
      var msg = "There are some errors in registration process.";
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(msg, Colors.redAccent),
      );
      throw error;
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _launchMapsUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Color(0XFF15161a),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                  child: Container(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                widget.pc3.close();
                                widget.videoController.play();
                              },
                              child: Icon(Icons.close,
                                  size: 25, color: Colors.white)),
                        ],
                      )),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    height: 130,
                    child: Image.asset(
                      'assets/images/login-logo.png',
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    "Sign Up For Leuke",
                    style: TextStyle(
                      color: Color(0xfffcb37b),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'QueenCamelot',
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Text(
                      "Create a profile, follow other creators build your fan following by creating your own videos.",
                      style: TextStyle(
                        height: 1.55,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _loginGoogle();
                    },
                    child: Image.asset(
                      'assets/images/google-b.png',
                      fit: BoxFit.fill,
                      width: 200,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _loginFb();
                    },
                    child: Image.asset(
                      'assets/images/facebook-b.png',
                      fit: BoxFit.fill,
                      width: 200,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "By continuing you agree to Leuke terms of use and confirm that you have read our privacy policy.",
                    style: TextStyle(
                      height: 1.55,
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _launchMapsUrl('https://leuke.app/terms.html');
                      },
                      child: Text(
                        "Terms of use",
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      width: 1,
                      height: 17,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchMapsUrl("https://leuke.app/privacy_policy.html");
                      },
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
