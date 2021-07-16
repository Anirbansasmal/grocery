import 'dart:io';

import '../category_list/CategorytListScreen.dart';
import '../signup/RegisterModel.dart';
import 'package:flutter/material.dart';
import '../login/ForgotPassword.dart';
import '../shapes/ShapeComponent.dart';
import '../signup/SignUpScreen.dart';
import '../userdata/UserPrefs.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert' as JSON;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ],
);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //===========================
  GoogleSignInAccount _currentUser;
  String userEmail = "";
  String userPassword = "";
  String forgotEmail = "";
  String userFirstname = "";
  String userLastname = "";
  String userMobile = "";
  String deviceToken;
  Map userProfile = new Map<String, dynamic>();
  List<String> userTypeList = ["Select Type", "Retailer", "Agent"];
  String userType;
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  getToken() async {
    if (Platform.isIOS == TargetPlatform.iOS ||
        Platform.isMacOS == TargetPlatform.macOS) {
      print('FlutterFire Messaging Example: Getting APNs token...');
      String token = await FirebaseMessaging.instance.getAPNSToken();
      setState(() {
        deviceToken = token;
      });
      print('FlutterFire Messaging Example: Got APNs token: $token');
    } else if (Platform.isAndroid) {
      FirebaseMessaging.instance.getToken().then((token) {
        print(token);
        setState(() {
          deviceToken = token;
        });
      });
    } else {
      print(
          'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.');
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  //========== Login handler =========
  void loginUser(BuildContext context) async {
    if (userEmail.trim() == "") {
      showCustomToast("Please enter email.");
      return;
    }
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (isNumeric(userEmail) && !regExp.hasMatch(userEmail)) {
      showCustomToast("Pleaase enter a valid phone number");
      return;
    } else if (!isEmail(userEmail)) {
      showCustomToast("Pleaase enter a valid email");
      return;
    }
    if (userPassword.trim() == "") {
      showCustomToast("Pleaase enter password");
      return;
    }
    var requestParam =
        "?email=" + userEmail.trim() + "&password=" + userPassword.trim();

    requestParam += "&device_token=" + deviceToken;

    print(Uri.parse(Consts.LOGIN_USER + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.LOGIN_USER + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      if (responseData['status'] == "success") {
        var userData = responseData['userdata'];
        RegisterUserModel registerUserModel = RegisterUserModel();

        registerUserModel.userId = userData['user_id'];
        registerUserModel.firstname = userData['firstname'];
        registerUserModel.lastname = userData['lastname'];
        registerUserModel.email = userData['email'];
        registerUserModel.userType = userData['user_type'];
        registerUserModel.phone = userData['phone'];
        saveUserLoginPrefs(registerUserModel);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CategorytListScreen(),
          ),
        );
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast("Error while conneting to server");
      print("Error getting response  ${response.statusCode}");
      throw Exception("Error getting response  ${response.statusCode}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    deviceToken = "";
    getToken();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        print(_currentUser);
        // _handleGetContact(_currentUser);
        _handleUserInfo(_currentUser);
      }
    });
    // _googleSignIn.signInSilently();

    userType = userTypeList[0];
    super.initState();
  }

  Future<void> _handleSignInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  _handleUserInfo(GoogleSignInAccount user) async {
    if (user != null) {
      var arrName = user.displayName.split(" ");

      if (arrName.length > 0) {
        print(arrName[0] + "\n");
        print(arrName[arrName.length - 1]);

        if (arrName[0] != null && arrName[0] != "") {
          setState(() {
            userFirstname = arrName[0];
          });
        }
        if (arrName.length > 1 &&
            arrName[arrName.length - 1] != null &&
            arrName[arrName.length - 1] != "") {
          setState(() {
            userLastname = arrName[arrName.length - 1];
          });
        }
        if (user.email != null) {
          setState(() {
            userEmail = user.email;
          });
        }
      }
    }
    _signUpWithGoogleServer();
  }

  _handleLogininfo(String profileFb) async {
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${profileFb}'));
    final profile = JSON.jsonDecode(graphResponse.body);
    // final profile = JSON.jsonDecode(profileFb);
    userProfile = profile;
    print('profile valu$userProfile');
    if (userProfile != null) {
      userProfile.forEach((k, v) {
        // print(k)
        print("got key $k with $v");

        if (k == "name") {
          var arrName = v.split(" ");
          if (arrName.length > 0) {
            print(arrName[0] + "\n");
            print(arrName[arrName.length - 1]);

            if (arrName[0] != null && arrName[0] != "") {
              setState(() {
                userFirstname = arrName[0];
              });
            }
            if (arrName.length > 1 &&
                arrName[arrName.length - 1] != null &&
                arrName[arrName.length - 1] != "") {
              setState(() {
                userLastname = arrName[arrName.length - 1];
              });
            }
          }
        }
        if (k == "email") {
          if (v != null) {
            setState(() {
              userEmail = v;
            });
          }
        }
      });
    }
    _signUpWithGoogleServer();
  }

  _signUpWithGoogleServer() async {
    var userRegType = "CU";
    if (userType == userTypeList[2]) {
      userRegType = "DI";
    }
    var requestParam = "?";
    requestParam += "firstname=" + userFirstname.trim();
    requestParam += "&lastname=" + userLastname.trim();
    requestParam += "&email=" + userEmail.trim();
    requestParam += "&phone=" + userMobile.trim();
    requestParam += "&password=" + userPassword.trim();
    requestParam += "&user_type=" + userRegType;
    requestParam += "&device_token=" + deviceToken;

    print(requestParam);

    final http.Response response = await http.get(
      Uri.parse(Consts.SIGNUP_USER + requestParam),
    );
    var responseData = jsonDecode(response.body);
    var serverMessage = responseData['message'];
    var serverCode = responseData['code'];
    print(response.body);
    if (response.statusCode == 200) {
      if (serverCode == "200") {
        RegisterUserModel registerUserModel = RegisterUserModel();

        registerUserModel.userId = responseData['user_id'].toString();
        registerUserModel.firstname = responseData['firstname'];
        registerUserModel.lastname = responseData['lastname'];
        registerUserModel.email = responseData['email'];
        registerUserModel.userType = responseData['user_type'];
        registerUserModel.phone = responseData['phone'];

        saveUserLoginPrefs(registerUserModel);
        showCustomToast(serverMessage);
        Navigator.pop(
          context,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorytListScreen(),
          ),
        );
      } else if (serverCode == "201") {
        var userData = responseData['user_data'][0];
        RegisterUserModel registerUserModel = RegisterUserModel();

        registerUserModel.userId = userData['user_id'];
        registerUserModel.firstname = userData['firstname'];
        registerUserModel.lastname = userData['lastname'];
        registerUserModel.email = userData['email'];
        registerUserModel.userType = userData['user_type'];
        registerUserModel.phone = userData['phone'];

        saveUserLoginPrefs(registerUserModel);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorytListScreen(),
          ),
        );
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast("Something went wrong");
    }
  }

  void _loginWithFacebook() async {
    var userObject = {};
    FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]).then((value) {
      FacebookAuth.instance.getUserData().then((userData) {
        print(userData);
        debugPrint("Name ${userData['name']}");
        debugPrint("Name ${userData['email']}");

        var arrName = userData['name'].split(' ');
        if (arrName.length >= 2) {
          setState(() {
            userFirstname = arrName[0];
            userLastname = arrName[1];
          });
        } else {
          setState(() {
            userFirstname = userData['name'];
          });
        }
        setState(() {
          userEmail = userData['email'];
        });
        _signUpWithGoogleServer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: Navigation(),
      appBar: AppBar(
        title: Text("Vedic"),
        actions: <Widget>[],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "images/image_bg.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              shapeComponet(context, Consts.shapeHeight),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 70.0,
                  left: 40,
                  right: 40,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(3),
                        ),
                        border: Border.all(
                            color: AppColors.loginContainerBorder, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: loginForm(context),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget navDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.

          padding: EdgeInsets.only(top: 10),
          children: <Widget>[
            // DrawerHeader(
            //   child: Text('Drawer Header'),
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),
            ListTile(
              title: Text(
                'Item 1',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget loginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 60,
        ),
        Theme(
          data: ThemeData(
            primaryColor: Colors.redAccent,
            primaryColorDark: Colors.red,
          ),
          child: new TextField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              hintText: 'Mobile / Email',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            onChanged: (value) => {
              setState(
                () {
                  userEmail = value;
                },
              )
            },
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Theme(
          data: ThemeData(
            primaryColor: Colors.redAccent,
            primaryColorDark: Colors.red,
          ),
          child: new TextField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            obscureText: true,
            onChanged: (value) => {
              setState(
                () {
                  userPassword = value;
                },
              )
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: _forgotDialogPopup,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: AppColors.forgotPasswordColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.appMainColor,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextButton(
            onPressed: () {
              loginUser(context);
              ;
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                color: AppColors.loginwithDivider,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "OR",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                height: 2,
                color: AppColors.loginwithDivider,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _handleSignInWithGoogle,
              child: Image.asset(
                "images/ic_goggle.png",
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            InkWell(
              onTap: () {
                _loginWithFacebook();
              },
              child: Image.asset(
                "images/ic_facebook.png",
                height: 35,
                width: 35,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                color: AppColors.loginTextColor,
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(
                  context,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  ),
                );
              },
              child: Text(
                "Sign up",
                style: TextStyle(
                  color: AppColors.forgotPasswordColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 80,
        ),
      ],
    );
  }

  void _forgotDialogPopup() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: Colors.white,
                ),
                child: AlertDialog(
                  title: Text(
                    "Forgot password",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  content: StatefulBuilder(
                    // You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
                      return ForgotPassword();
                    },
                  ),
                ),
              );
            });
      },
    );
  }
}
