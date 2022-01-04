import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String MIN_DATETIME = '2010-05-12';
const String MAX_DATETIME = '2021-11-25';
const String INIT_DATETIME = '2019-05-17';
const String DATE_FORMAT = 'MMM,d,yyyy';

class SearchGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: null,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg-signup.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 30.0),
                Image.asset("assets/images/logo.png", height: 130.0),
                SizedBox(height: 40.0),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'QueenCamelot',
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 40.0),
                TabBarDemo(),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    "By continuing, you agree to company name. "
                    "Terms of use and confirm that you have read Privacy policy",
                    style: TextStyle(
                      height: 1.55,
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 85.0),
                RaisedButton(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    color: Color(0xff1f56ba),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                'SEND OTP',
                                style: TextStyle(
                                  height: 1.5,
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    print("SIGNUPNEXT");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => null),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: TabBar(tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      color: Color(0xff1f56ba),
                      fontSize: 22,
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
                      color: Color(0xff1f56ba),
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            //Add this to give height
            height: MediaQuery.of(context).size.height / 14,
            child: TabBarView(children: [
              Container(
                child: TextField(
                  style: TextStyle(fontSize: 20.0, color: Color(0xff1f56ba)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color(0xff1f56ba),
                      size: 24.0,
                    ),
                    hintText: "Enter Your Email",
                  ),
                ),
              ),
              Container(
                child: TextField(
                  style: TextStyle(fontSize: 20.0, color: Color(0xff1f56ba)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: Text(
                      "+91",
                      style: TextStyle(
                        fontSize: 21.0,
                        height: 1.9,
                        color: Colors.grey[400],
                      ),
                    ),
                    hintText: "Enter Your Mobile",
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
