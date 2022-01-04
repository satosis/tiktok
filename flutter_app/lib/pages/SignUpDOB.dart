import 'dart:math' as math; // import this

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/roundedDiagonal.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearbefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-mm-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');

String MIN_YEAR = formatterYear.format(minDate);
String MAX_YEAR = formatterYear.format(yearbefore);
String INIT_DATETIME = formatter.format(yearbefore);
const String DATE_FORMAT = 'MMM-d-yyyy';

class SignUpDOB extends StatefulWidget {
  @override
  _SignUpDOBState createState() => _SignUpDOBState();
}

class _SignUpDOBState extends State<SignUpDOB> {
  DateTime dob;
  @override
  void initState() {
    setState(() {
      dob = DateTime.parse(INIT_DATETIME);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          color: Color(0XFF15161a),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'QueenCamelot',
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.037),
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
                              height: MediaQuery.of(context).size.height * .04,
                            ),
                            Text(
                              "Enter your date of birth",
                              style: TextStyle(
                                color: Color(0xfff5ae78),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'QueenCamelot',
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.037),
                            Padding(
                              padding: EdgeInsets.only(left: 22.0, right: 22.0),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    child: Center(
                                      child: Text(
                                        "What's your birthday?",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.037,
                                    left: 20,
                                    child: Container(
                                      child: Text(
                                        "Your birthday won't be shown publicly",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 65.0),
                                      child: Container(
                                        height: 100,
                                        child: DefaultTextStyle.merge(
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Color(0xff06638f),
                                          ),
                                          child: Theme(
                                            data: ThemeData(
                                                cupertinoOverrideTheme:
                                                    CupertinoThemeData(
                                                        textTheme:
                                                            CupertinoTextThemeData(
                                              dateTimePickerTextStyle:
                                                  TextStyle(
                                                      color: Color(0xfff5ae78),
                                                      fontSize: 22),
                                              pickerTextStyle: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12),
                                            ))),
                                            child: CupertinoDatePicker(
                                              maximumDate: new DateTime(
                                                yearbefore.year,
                                                yearbefore.month,
                                                yearbefore.day,
                                              ),
                                              minimumYear: int.parse(MIN_YEAR),
                                              maximumYear: int.parse(MAX_YEAR),
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              initialDateTime: new DateTime(
                                                yearbefore.year,
                                                yearbefore.month,
                                                yearbefore.day,
                                              ),
                                              onDateTimeChanged:
                                                  (DateTime dateTime) {
                                                setState(() {
                                                  dob = dateTime;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
                              height: MediaQuery.of(context).size.height * 0.09,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset("assets/icons/next-b.png"),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, 'sign-up-send-otp',
                                  arguments: {
                                    'dob': dob,
                                  });
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          color: Color(0xfff5ae78),
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
    );
  }
}
