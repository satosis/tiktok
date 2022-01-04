import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../functions.dart';
import '../services/SessionManager.dart';
import '../widgets/globals.dart';
import 'MyProfile.dart';
import 'showCupertinoDatePicker.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearbefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearbefore);
String initDatetime = formatter.format(yearbefore);

class EditProfile extends StatefulWidget {
  final Function updateProfileData;
  EditProfile(this.updateProfileData);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File image;
  // File imageUpload;
  final picker = ImagePicker();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  bool showLoader = false;
  GlobalKey<FormState> _key = new GlobalKey();
  // bool _validate = false;
  String personName = '';
  String username = '';
  String mobile = '';
  String email = '';
  String bio = '';
  DateTime dob;
  Gender selectedGender;
  int userId = 0;
  String appToken = '';
  var userData = [];
  String emailErr = '';
  String nameErr = '';
  String mobileErr = '';
  String smallProfilePic = '';
  String largeProfilePic = '';
  PanelController _pc = new PanelController();
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _mobileController;
  TextEditingController _bioController;
  final SessionManager sessions = new SessionManager();
  List<Gender> gender = <Gender>[
    const Gender('', 'Select'),
    const Gender('m', 'Male'),
    const Gender('f', 'Female'),
    const Gender('o', 'Other')
  ];

  @override
  void initState() {
    super.initState();
    nameErr = '';
    emailErr = '';
    mobileErr = '';
    _getSessionData();
  }

  Future updateProfilePic(File file) async {
    print("updateProfilePic");
    setState(() {
      // imageUpload = file;
      showLoader = true;
    });
    try {
      String apiUrl = apiUrlRoot + "api/v1/update_profile_pic";
      String fileName = file.path.split('/').last;
      print("fileName" + fileName);
      FormData formData = FormData.fromMap({
        "profile_pic":
            // MultipartFile.fromFileSync(file.path, filename: fileName),
            await MultipartFile.fromFile(file.path, filename: fileName),
      });
      var response = await Dio().post(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          data: formData,
          queryParameters: {"user_id": userId, "app_token": appToken});
      print(response.data);
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          setState(() {
            smallProfilePic = response.data['small_pic'];
            largeProfilePic = response.data['large_pic'];
            this.widget.updateProfileData(response.data);
          });
        } else {
          var msg = response.data['msg'];
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.red),
          );
        }
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      var msg = e;
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(msg, Colors.red),
      );
      setState(() {
        showLoader = false;
      });
    }
  }

  getImageOption(bool isCamera) async {
    if (isCamera) {
      final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
    if (image != null) {
      print(image.path);
      updateProfilePic(image);
    }
  }

  _getSessionData() async {
    sessions.getUserInfo().then((obj) {
      setState(() {
        userId = obj['user_id'];
        appToken = obj['app_token'];
        fetchData();
        _scrollController = new ScrollController();
      });
    });
  }

  fetchData() async {
    print(userId);
    showLoader = true;
    try {
      String apiUrl = apiUrlRoot + "api/v1/user_information";
      var rs = await Dio().get(apiUrl,
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': apiUser,
              'KEY': apiKey,
            },
          ),
          queryParameters: {"user_id": userId});
      if (rs.data['status'] == 'success') {
        setState(() {
          personName =
              rs.data['content']['fname'] + " " + rs.data['content']['lname'];
          username = rs.data['content']['username'];
          mobile = rs.data['content']['mobile'];
          email = rs.data['content']['email'];
          bio = rs.data['content']['bio'];
          dob = DateTime.parse(rs.data['content']['dob']);
          selectedGender = (rs.data['content']['gender'] != '')
              ? (rs.data['content']['gender'] == 'm')
                  ? gender[1]
                  : (rs.data['content']['gender'] == 'f')
                      ? gender[2]
                      : gender[3]
              : gender[0];
          smallProfilePic = rs.data['small_pic'];
          largeProfilePic = rs.data['large_pic'];
          _nameController = new TextEditingController(text: personName);
          _emailController = new TextEditingController(text: email);
          _mobileController = new TextEditingController(text: mobile);
          _bioController = new TextEditingController(text: bio);
        });
      } else {
        var msg = rs.data['msg'];
        _scaffoldKey.currentState.showSnackBar(
          Functions.toast(msg, Colors.red),
        );
      }
      showLoader = false;
    } catch (e) {
      throw (e);
    }
  }

  Future updateInformation() async {
    setState(() {
      if (personName.length == 0) {
        nameErr = "Name Field is required";
      } else {
        nameErr = "";
      }
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (email.length == 0) {
        emailErr = 'Email Field is required';
      } else if (!regex.hasMatch(email)) {
        emailErr = 'You entered invalid email!';
      } else {
        emailErr = '';
      }
      if (mobile.length == 0) {
        mobileErr = "Mobile Field is required";
      } else {
        mobileErr = "";
      }
    });
    if (nameErr == '' && emailErr == '' && mobileErr == '') {
      setState(() {
        showLoader = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        String apiUrl = apiUrlRoot + "api/v1/update_user_information";
        var rs = await Dio().post(apiUrl,
            options: Options(
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'USER': apiUser,
                'KEY': apiKey,
              },
            ),
            queryParameters: {
              "user_id": userId,
              "name": personName,
              "email": email,
              "mobile": mobile,
              "dob": dob,
              "bio": bio,
              "gender": selectedGender.value,
            });
        if (rs.statusCode == 200) {
          showLoader = false;
          if (rs.data['status'] == 'success') {
            setState(() {
              prefs.setString("name", personName);
              prefs.setString("mobile", mobile);
              prefs.setString("email", email);
              prefs.setString("gender", selectedGender.value);
              var nameArr = new Map();
              nameArr['name'] = personName;
              this.widget.updateProfileData(nameArr);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfile(),
                ),
              );
            });
          } else {
            var msg = "There are some errors in api process.";
            _scaffoldKey.currentState.showSnackBar(
              Functions.toast(msg, Colors.red),
            );
          }
        } else {
          var msg = "There are some errors in api process.";
          _scaffoldKey.currentState.showSnackBar(
            Functions.toast(msg, Colors.red),
          );
        }
        setState(() {
          showLoader = false;
        });
      } catch (e) {
        throw Exception("Error: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void onChanged(value) {
      setState(() {
        dob = value;
      });
    }

    /*formProcess() {
      if (_key.currentState.validate()) {
        //no any error in validation..
        _key.currentState.save();
        updateInformation();
      } else {
        //validation error..
        setState(() {
          // _validate = true;
        });
      }
    }*/

    /*myToast(String text, color) {
      _scaffoldKey.currentState.showSnackBar(
        Functions.toast(text, color),
      );
    }*/

    final nameField = TextFormField(
      controller: _nameController,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.text,
      onSaved: (String val) {
        personName = val;
      },
      onChanged: (String val) {
        personName = val;
      },
      decoration: new InputDecoration(
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Enter Your Name",
          hintStyle: TextStyle(color: Colors.black)),
    );

    final emailField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      onSaved: (String val) {
        email = val;
      },
      onChanged: (String val) {
        email = val;
      },
      decoration: new InputDecoration(
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Enter Email",
          hintStyle: TextStyle(color: Colors.black)),
    );

    final mobileField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.phone,
      controller: _mobileController,
      onSaved: (String val) {
        mobile = val;
      },
      onChanged: (String val) {
        mobile = val;
      },
      decoration: new InputDecoration(
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Enter Mobile No.",
          hintStyle: TextStyle(color: Colors.black)),
    );

    final bioField = TextFormField(
      textAlign: TextAlign.right,
      maxLength: 80,
      maxLines: null,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.multiline,
      controller: _bioController,
      onSaved: (String val) {
        bio = val;
      },
      onChanged: (String val) {
        bio = val;
      },
      decoration: new InputDecoration(
          counterText: "",
          errorStyle: TextStyle(
            color: Color(0xFFf5ae78),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Enter Bio (80 chars)",
          hintStyle: TextStyle(color: Colors.black)),
    );

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            backgroundColor: Colors.white60,
            title: Text(
              "EDIT PROFILE",
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            centerTitle: true,
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  updateInformation();
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                      color: Color(0xff4BB543),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                shape:
                    CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: SlidingUpPanel(
            controller: _pc,
            isDraggable: false,
            backdropEnabled: true,
            panelSnapping: false,
            color: Color(0xffffffff),
            maxHeight: 95.0,
            minHeight: 0,
            panel: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          getImageOption(true);
                          _pc.close();
                        },
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/icons/camera.png',
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 0),
                              child: Text(
                                "Camera",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          getImageOption(false);
                          _pc.close();
                        },
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/icons/gallery.png',
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 0),
                              child: Text(
                                "Gallery",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return Scaffold(
                                appBar: PreferredSize(
                                  preferredSize: Size.fromHeight(45.0),
                                  child: AppBar(
                                    iconTheme: IconThemeData(
                                      color:
                                          Colors.black, //change your color here
                                    ),
                                    backgroundColor: Color(0xff15161a),
                                    title: Text(
                                      "PROFILE PICTURE",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    centerTitle: true,
                                  ),
                                ),
                                backgroundColor: Colors.black,
                                body: Center(
                                  child: PhotoView(
                                    enableRotation: true,
                                    imageProvider: CachedNetworkImageProvider(
                                      (largeProfilePic
                                                  .toLowerCase()
                                                  .contains(".jpg") ||
                                              largeProfilePic
                                                  .toLowerCase()
                                                  .contains(".jpeg") ||
                                              largeProfilePic
                                                  .toLowerCase()
                                                  .contains(".png") ||
                                              largeProfilePic
                                                  .toLowerCase()
                                                  .contains(".gif") ||
                                              largeProfilePic
                                                  .toLowerCase()
                                                  .contains(".bmp") ||
                                              largeProfilePic
                                                  .toLowerCase()
                                                  .contains("fbsbx.com") ||
                                              largeProfilePic
                                                  .toLowerCase()
                                                  .contains(
                                                      "googleusercontent.com"))
                                          ? largeProfilePic
                                          : apiUrlRoot +
                                              "imgs/user-dummy-pic.png",
                                    ),
                                  ),
                                ));
                          }));
                          _pc.close();
                        },
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/icons/view.png',
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 0),
                              child: Text(
                                "View Picture",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: ModalProgressHUD(
              inAsyncCall: showLoader,
              child: Center(
                  child: Container(
                color: Color(0xffffffff),
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _scrollController.animateTo(
                                70,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 1000),
                              );
                              _pc.open();
                            });
                          },
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(100.0)),
                              border: new Border.all(
                                color: Colors.white,
                                width: 5.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image: new CachedNetworkImageProvider(
                                      (smallProfilePic
                                                  .toLowerCase()
                                                  .contains(".jpg") ||
                                              smallProfilePic
                                                  .toLowerCase()
                                                  .contains(".jpeg") ||
                                              smallProfilePic
                                                  .toLowerCase()
                                                  .contains(".png") ||
                                              smallProfilePic
                                                  .toLowerCase()
                                                  .contains(".gif") ||
                                              smallProfilePic
                                                  .toLowerCase()
                                                  .contains(".bmp") ||
                                              smallProfilePic
                                                  .toLowerCase()
                                                  .contains("fbsbx.com") ||
                                              smallProfilePic
                                                  .toLowerCase()
                                                  .contains(
                                                      "googleusercontent.com"))
                                          ? smallProfilePic
                                          : apiUrlRoot +
                                              "imgs/user-dummy-pic.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(100.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _scrollController.animateTo(
                                    70,
                                    curve: Curves.easeOut,
                                    duration:
                                        const Duration(milliseconds: 1000),
                                  );
                                  _pc.open();
                                });
                              },
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[200],
                                size: 25.0,
                              ),
                            )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 0),
                      child: Container(
                        child: Form(
                          // autovalidate: _validate,
                          key: _key,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "Username",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2, 5, 0, 0),
                                              child: Text(
                                                username,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "Name",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2, 5, 0, 0),
                                              child: nameField,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "Email",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Container(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        2, 5, 0, 0),
                                                child: emailField),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "Gender",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30.0,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                140,
                                        child: Container(
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              canvasColor: Color(0xffffffff),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child:
                                                    new DropdownButton<Gender>(
                                                  iconEnabledColor:
                                                      Colors.white,
                                                  style: new TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                  ),
                                                  value: selectedGender,
                                                  onChanged: (Gender newValue) {
                                                    setState(() {
                                                      selectedGender = newValue;
                                                    });
                                                  },
                                                  items:
                                                      gender.map((Gender user) {
                                                    return new DropdownMenuItem<
                                                        Gender>(
                                                      value: user,
                                                      child: new Text(
                                                        user.name,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: new TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "Mobile",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2, 5, 0, 0),
                                              child: mobileField,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "DOB",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 30.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Container(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        2, 5, 0, 0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showCupertinoDatePicker(
                                                        context,
                                                        mode:
                                                            CupertinoDatePickerMode
                                                                .date,
                                                        initialDateTime: dob,
                                                        leftHanded: false,
                                                        minimumYear:
                                                            int.parse(minYear),
                                                        maximumYear:
                                                            int.parse(maxYear),
                                                        onDateTimeChanged:
                                                            (DateTime date) {
                                                      DateTime result;
                                                      if (date.year > 0) {
                                                        result = DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            dob.hour,
                                                            dob.minute);
                                                      } else {
                                                        // The user has hit the cancel button.
                                                        result = dob;
                                                      }
                                                      onChanged(result);
                                                    });
                                                  },
                                                  child: (dob != null)
                                                      ? Text(
                                                          formatterDate
                                                              .format(dob),
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black))
                                                      : Container(),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 100.0,
                                        width: 100,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 5, 0, 0),
                                            child: Text(
                                              "Bio",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: 100.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2, 5, 0, 0),
                                              child: bioField,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      (nameErr != '')
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  nameErr,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          'RockWellStd'),
                                                ),
                                              ),
                                            )
                                          : Text(''),
                                      (emailErr != '')
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  emailErr,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          'RockWellStd'),
                                                ),
                                              ),
                                            )
                                          : Text(''),
                                      (mobileErr != '')
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  mobileErr,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          'RockWellStd'),
                                                ),
                                              ),
                                            )
                                          : Text(''),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}

class Gender {
  const Gender(this.value, this.name);

  final String name;
  final String value;
}
