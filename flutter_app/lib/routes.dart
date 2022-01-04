import 'package:flutter/material.dart';

import 'main.dart';
// import 'pages/Login.dart';
import 'pages/MyProfile.dart';
// import 'pages/SignUpDOB.dart';
// import 'pages/SignUpOTP.dart';
// import 'pages/SignUpPage.dart';
// import 'pages/SignUpSendOTP.dart';
import 'pages/SlidingUpPanelContainer.dart';
import 'pages/VideoRecorder.dart';
// import 'pages/editProfile.dart';
// import 'pages/UserProfile.dart';
// import 'pages/Comments.dart';

Route generateRoute(RouteSettings settings) {
  // var arguments = settings.arguments;
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => MainPage());
    /*case 'login':
      return MaterialPageRoute(builder: (context) => Login());
    case 'sign-up':
      return MaterialPageRoute(builder: (context) => SignUpPage());
    case 'sign-up-dob':
      return MaterialPageRoute(builder: (context) => SignUpDOB());
    case 'login':
      return MaterialPageRoute(builder: (context) => Login());
    case 'sign-up-send-otp':
      return MaterialPageRoute(builder: (context) => SignUpSendOTP(arguments));
    case 'sign-up-otp':
      return MaterialPageRoute(builder: (context) => SignUpOTP(arguments));*/
    case 'home':
      return MaterialPageRoute(builder: (context) => HomePage());
    case 'camera':
      return MaterialPageRoute(builder: (context) => VideoRecorder());
    case 'my-profile':
      return MaterialPageRoute(builder: (context) => MyProfile());
    default:
      return MaterialPageRoute(builder: (context) => HomePage());
  }
}
