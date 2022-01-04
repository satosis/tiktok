import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'SlidingUpPanelContainer.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        extendBodyBehindAppBar: true,
        body: Container(
          padding: const EdgeInsets.only(
            left: 15.0,
            right: 15.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg-signup.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 25.0),
                Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'QueenCamelot',
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 55.0),
                Text(
                  "Login your Profile",
                  style: TextStyle(
                    color: Color(0xff06638f),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'QueenCamelot',
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 6.0),
                Container(
                  color: Colors.black26,
                  height: 1,
//                  width: MediaQuery.of(context).size.width * 70 - 100,
                  width: 270,
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 26.0,
                    right: 26.0,
                    top: 5,
                  ),
                  child: Text(
                    "Login your profile, follow other accounts, make your own video and more.",
                    style: TextStyle(
                      color: Color(0xff06638f),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'RockWellStd',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30.0,
                    top: 20.0,
                    right: 30.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        style: TextStyle(
                          fontFamily: 'RockWellStd',
                          fontSize: 16.0,
                          color: Color(0xff06638f),
                        ),
                        decoration: InputDecoration(
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff06638f)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff06638f)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff06638f)),
                          ),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FaIcon(
                                FontAwesomeIcons.user,
                                color: Color(0xff06638f),
                                size: 24.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Container(
                                  color: Color(0xff06638f),
                                  width: 1,
                                  height: 30,
                                ),
                              ),
                            ],
                          ),
//                    prefix:
                          hintText: "Enter Your Email",
                          hintStyle: TextStyle(
                            color: Color(0xff06638f),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        style: TextStyle(
                          fontFamily: 'RockWellStd',
                          fontSize: 16.0,
                          color: Color(0xff06638f),
                        ),
                        decoration: InputDecoration(
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff06638f)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff06638f)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff06638f)),
                          ),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FaIcon(
                                FontAwesomeIcons.lock,
                                color: Color(0xff06638f),
                                size: 24.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Container(
                                  color: Color(0xff06638f),
                                  width: 1,
                                  height: 30,
                                ),
                              ),
                            ],
                          ),
//                    prefix:
                          hintText: "Enter Your Password",
                          hintStyle: TextStyle(
                            color: Color(0xff06638f),
                            fontSize: 16,
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            print("SIGNUPNEXT");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),

                  // end PinEntryTextField()
                ),
                SizedBox(height: 80.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 70,
//                  width: 70,
//                  margin: EdgeInsets.only(left: 275),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
//                      fit: BoxFit.cover,
                    ),
                    child: RaisedButton(
                      padding: EdgeInsets.all(0),
                      color: Colors.transparent,
                      elevation: 0,
                      child: Container(
                        height: 70,
//                      width: 70,
//                    color: Color(0xff1f56ba),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
//                      fit: BoxFit.cover,
                        ),
                        child: Image.asset("assets/icons/next-b.png"),
                      ),
                      onPressed: () {
                        print("SIGNUPNEXT");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                  ),
                  child: RaisedButton(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
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
