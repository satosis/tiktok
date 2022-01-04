import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions.dart';
import '../widgets/globals.dart';
import '../widgets/roundedDiagonal.dart';

//var d = DateTime.now();
var date = new DateTime.now();

class SignUpSendOTP extends StatefulWidget {
//  final DateTime dob;
  var arguments;
  SignUpSendOTP(this.arguments);
  @override
  _SignUpSendOTPState createState() => _SignUpSendOTPState();
}

class _SignUpSendOTPState extends State<SignUpSendOTP> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  bool showLoader = false;
//  String DateOfBirth = '';
  String email = '';
  String mobile = '';
  String _timezone = 'Unknown';
  int userId;
  int _curIndex;
  Future<void> initPlatformState() async {
    String timezone;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _timezone = timezone;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Widget build(BuildContext context) {
    Future<String> formSubmitApi() async {
      showLoader = true;
      String apiUrl = apiUrlRoot + "api/v1/register";
      final response = await http
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
          'dob': widget.arguments['dob'].toIso8601String(),
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
        var msg = "There are some errors in registration process.";
        _scaffoldKey.currentState.showSnackBar(
          Functions.toast(msg, Colors.redAccent),
        );
      });
    }

    formSubmit() {
      print("submit");
      if (_key.currentState.validate()) {
        //no any error in validation..
        _key.currentState.save();
        formSubmitApi();
      } else {
        //validation error..
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
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        /*appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: null,
          backgroundColor: Colors.transparent,b
          elevation: 0.0,
        ),*/
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: showLoader,
            child: Container(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg-signup.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Form(
                  key: _key,
                  autovalidate: _validate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'QueenCamelot',
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.037),
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
                                      MediaQuery.of(context).size.height / .2,
//                          height: 440,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(45.0),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: null,
//                          Center(child: Text("RoundedDiagonalPathClipper()")),
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.022),
                                  Text(
                                    "Create An Account",
                                    style: TextStyle(
                                      color: Color(0xff06638f),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'QueenCamelot',
                                      fontSize: 32,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .005),
                                  Container(
                                    color: Colors.black26,
                                    height: 1,
//                  width: MediaQuery.of(context).size.width * 70 - 100,
                                    width: 270,
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .020),
                                  /*Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Text(
                                      "Create a profile, follow other accounts, make your own video and more.",
                                      style: TextStyle(
                                        color: Color(0xff06638f),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'RockWellStd',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),*/
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
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
                                              indicatorColor: Color(0xff06638f),
                                              labelColor: Color(0xff06638f),
                                              unselectedLabelColor:
                                                  Colors.grey[400],
                                              indicatorWeight: 2.0,
                                              tabs: [
                                                Tab(
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Email",
                                                      style: TextStyle(
//                        color: Color(0xff06638f),
                                                        fontSize: 22,
                                                        fontFamily:
                                                            'RockWellStd',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Tab(
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Mobile",
                                                      style: TextStyle(
//                        color: Color(0xff06638f),
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
                                            //Add this to give height
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                10,
                                            child: TabBarView(children: [
                                              Container(
                                                child: TextFormField(
                                                  style: TextStyle(
                                                    fontFamily: 'RockWellStd',
                                                    fontSize: 16.0,
                                                    color: Color(0xff06638f),
                                                  ),
                                                  validator: _curIndex == 0
                                                      ? validateEmail
                                                      : null,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  onSaved: (String val) {
                                                    email = val;
                                                  },
                                                  decoration: InputDecoration(
                                                    errorStyle: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      wordSpacing: 2.0,
                                                    ),
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.cyan),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.cyan),
                                                    ),
                                                    errorBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
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
                                                              Color(0xff06638f),
                                                          size: 24.0,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10.0),
                                                          child: Container(
                                                            color: Color(
                                                                0xff06638f),
                                                            width: 1,
                                                            height: 30,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
//                    prefix:
                                                    hintText:
                                                        "Enter Your Email",
                                                    hintStyle: TextStyle(
                                                      color: Color(0xff06638f),
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
                                                    color: Color(0xff06638f),
                                                    fontFamily: 'RockWellStd',
                                                  ),
                                                  decoration: InputDecoration(
                                                    errorStyle: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      wordSpacing: 2.0,
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.cyan),
                                                    ),
                                                    errorBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.cyan),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.cyan),
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
                                                            color: Color(
                                                                0xff06638f),
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
                                                            color: Color(
                                                                0xff06638f),
                                                            width: 1,
                                                            height: 30,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    hintText:
                                                        "Enter Your Mobile",
                                                    hintStyle: TextStyle(
                                                      color: Color(0xff06638f),
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
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .03),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.09,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
//                      fit: BoxFit.cover,
                                ),
                                child: GestureDetector(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.09,
//                      width: 70,
//                    color: Color(0xff1f56ba),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
//                      fit: BoxFit.cover,
                                    ),
                                    child:
                                        Image.asset("assets/icons/next-b.png"),
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
                                        MediaQuery.of(context).size.height / .2,
//                            height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(45.0),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: null,
//                          Center(child: Text("RoundedDiagonalPathClipper()")),
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
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              "have an account ",
                                              style: TextStyle(
                                                height: 1.55,
                                                color: Color(0xff06638f),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
//                SizedBox(width: 5.0),
                                      RaisedButton(
                                        padding: EdgeInsets.all(0),
                                        child: Container(
                                          height: 45,
                                          color: Color(0xff06638f),
                                          child: Center(
                                            child: Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
//                          fontWeight: FontWeight.w600,
                                                fontFamily: 'RockWellStd',
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          print("SIGNUPDOB");
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
        ),
      ),
    );
  }
}
