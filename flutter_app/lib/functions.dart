import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/Videos.dart';
import 'pages/SlidingUpPanelContainer.dart';

class Functions {
  static toast(String msg, Color color) {
    msg = removeTrailing("\n", msg);
    return SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  static String removeTrailing(String pattern, String from) {
    int i = from.length;
    while (from.startsWith(pattern, i - pattern.length)) i -= pattern.length;
    return from.substring(0, i);
  }

  static fSafeChar(var data) {
    if (data == null) {
      return "";
    } else {
      return data;
    }
  }

  static fSafeNum(var data) {
    if (data == null) {
      return 0;
    } else {
      return data;
    }
  }
}

void logout(BuildContext context) async {
  VideoModel video;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Dialog fancyDialog = Dialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12))),
    child: Container(
      height: 210.0,
      width: 300.0,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        //color: Colors.white,
        borderRadius: BorderRadius.all(new Radius.circular(12.0)),
      ),
      child: Column(
        children: <Widget>[
          Container(
              height: 150,
              decoration: BoxDecoration(
                //color: Color(0xff2e2f34),
                borderRadius: BorderRadius.all(new Radius.circular(12.0)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Image.asset('assets/images/gif-logo.gif',
                          width: 80, fit: BoxFit.fill),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Text(
                          "Do you really want to logout?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
            child: Container(
                decoration: BoxDecoration(
                  //color: Color(0xff2e2f34),
                  borderRadius: BorderRadius.all(new Radius.circular(32.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop("Discard");
                        },
                        child: Container(
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            gradient: Gradients.blush,
                            borderRadius:
                                BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'RockWellStd'),
                            ),
                          ),
                        )),
                    GestureDetector(
                        onTap: () {
                          String uniqueId =
                              (prefs.getString('unique_id') == null)
                                  ? ""
                                  : prefs.getString('unique_id');
                          Navigator.of(context, rootNavigator: true)
                              .pop("Discard");
                          _logOutFromSocial(prefs);
                          prefs.clear();
                          prefs.setString("unique_id", uniqueId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(video),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            gradient: Gradients.blush,
                            borderRadius:
                                BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: Center(
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'RockWellStd'),
                            ),
                          ),
                        )),
                  ],
                )),
          ),
        ],
      ),
    ),
  );
  showDialog(context: context, builder: (BuildContext context) => fancyDialog);
}

Future<Null> _logOutFromSocial(prefs) async {
  if (prefs.getString("login_type") != null) {
    if (prefs.getString("login_type") == 'FB') {
      prefs.clear();
      FacebookLogin facebookSignIn = new FacebookLogin();
      await facebookSignIn.logOut();
    } else {
      prefs.clear();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    }
  } else {
    prefs.clear();
  }
}
