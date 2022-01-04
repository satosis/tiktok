import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions.dart';
import '../widgets/globals.dart';
import '../widgets/roundedDiagonal.dart';
import 'SlidingUpPanelContainer.dart';

class SignUpOTP extends StatefulWidget {
  var arguments;
  SignUpOTP(this.arguments);
  @override
  _SignUpOTPState createState() => _SignUpOTPState();
}

class _SignUpOTPState extends State<SignUpOTP> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _key = new GlobalKey();
  bool showLoader = false;
  bool _validate = false;
  String msg = '';
  String otp;
  int user_id;
  int countTimer = 60;
  bool bHideTimer = true;
  ScaffoldState scaffold;
  @override
  void initState() {
    super.initState();
    user_id = widget.arguments['user_id'];
    otp = "";
    msg = widget.arguments['msg'];
    WidgetsBinding.instance.addPostFrameCallback((_) => showSnackBar());
    startTimer();
  }

  startTimer() {
    Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        countTimer--;
        print(countTimer);
        if (countTimer == 0) {
          bHideTimer = false;
        }
        if (countTimer <= 0) timer.cancel();
      });
    });
  }

  void showSnackBar() {
    _scaffoldKey.currentState.showSnackBar(
      Functions.toast(msg, Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<String> resendOtpApi() async {
      showLoader = true;
      String apiUrl = apiUrlRoot + "api/v1/resend_otp";
      final response = await http
          .post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'USER': apiUser,
          'KEY': apiKey,
        },
        body: jsonEncode({
          'user_id': user_id,
        }),
      )
          .then((response) async {
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            showLoader = false;
            bHideTimer = true;
            countTimer = 60;
            startTimer();
            _scaffoldKey.currentState.showSnackBar(
              Functions.toast(jsonData['msg'], Colors.green),
            );
          } else {
            var jsonData = jsonDecode(response.body);
            var msg = jsonData['msg'];
            _scaffoldKey.currentState.showSnackBar(
              Functions.toast(msg, Colors.redAccent),
            );
          }
        } else {
          var msg = "There are some errors in send otp process.";
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.redAccent),
          );
        }
        showLoader = false;
      }).catchError((error) {
        throw error;
      });
    }

    Future<String> formSubmitApi() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      showLoader = true;
      String apiUrl = apiUrlRoot + "api/v1/verify-otp";
      final response = await http
          .post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'USER': apiUser,
          'KEY': apiKey,
        },
        body: jsonEncode({
          'user_id': user_id,
          'otp': otp,
        }),
      )
          .then((response) {
        if (response.statusCode == 200 && response != null) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            showLoader = false;
            var userData = jsonData['data'];
            prefs.setInt("user_id", userData['user_id']);
            prefs.setString("user_dp", userData['user_dp']);
            prefs.setString("app_token", userData['app_token']);
            prefs.setString(
                "name", userData['fname'] + " " + userData['lname']);
            prefs.setString("mobile", userData['mobile']);
            prefs.setString("email", userData['email']);
            prefs.setString("gender", userData['gender']);
            prefs.setString("gender", userData['gender']);
            prefs.setString("app_token", userData['app_token']);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
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
      if (otp.length == 4) {
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
      } else {
        _validate = false;
        var msg = "OTP should be atleast 4 digits";
        _scaffoldKey.currentState.showSnackBar(
          Functions.toast(msg, Colors.redAccent),
        );
      }
    }

    String validateOTP(String value) {
      if (value.length == 0) {
        return "OTP required!";
      } else if (value.length <= 4) {
        return "OTP length must be atleast 4 digits";
      } else {
        return null;
      }
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        extendBodyBehindAppBar: true,
        body: ModalProgressHUD(
          inAsyncCall: showLoader,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            color: Color(0XFF15161a),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'QueenCamelot',
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.037),
                  Form(
                    key: _key,
                    autovalidate: _validate,
                    child: Container(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(45.0)),
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
                                  height:
                                      MediaQuery.of(context).size.height * .04,
                                ),
                                Text(
                                  "Enter OTP",
                                  style: TextStyle(
                                    color: Color(0xfff5ae78),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'QueenCamelot',
                                    fontSize: 25,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.037),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 22.0, right: 22.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "OTP sent to your registered Mobile or Email ID",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Center(
                                        child: PinEntryTextField(
                                          fieldWidth: 60.0,
                                          fontSize: 40.0,
                                          isTextObscure: true,
                                          onSubmit: (String pin) {
                                            otp = pin;
                                            _validate = true;
                                          }, // end onSubmit
                                        ), // end Padding()
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            right: 15,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.09,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: GestureDetector(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset("assets/icons/next-b.png"),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  if (_validate) {
                                    formSubmit();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            bottom: 60,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 30,
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    (bHideTimer)
                                        ? Text(
                                            'Resend OTP in $countTimer seconds',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontFamily: 'RockWellStd',
                                                fontWeight: FontWeight.w400),
                                          )
                                        : Column(
                                            children: <Widget>[
                                              Text("Did not get OTP?",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontFamily: 'RockWellStd',
                                                      fontWeight:
                                                          FontWeight.w100)),
                                              InkWell(
                                                onTap: () {
                                                  resendOtpApi();
                                                },
                                                child: Text(
                                                    "Click here to resend OTP",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xfff5ae78),
                                                        fontSize: 17,
                                                        fontFamily:
                                                            'RockWellStd',
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              )
                                            ],
                                          )
                                  ],
                                ),
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
