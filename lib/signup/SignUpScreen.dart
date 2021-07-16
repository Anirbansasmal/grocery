import 'dart:collection';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:passwordfield/passwordfield.dart';

import '../category_list/CategorytListScreen.dart';
import '../login/LoginScreen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../userdata/UserPrefs.dart';
import 'package:flutter/material.dart';
import '../shapes/ShapeComponent.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'RegisterModel.dart';
import 'dart:convert' as JSON;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ],
);

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GoogleSignInAccount _currentUser;
  // static final FacebookLogin facebookSignIn = new FacebookLogin();
  // Map userProfile;
  Map userProfile = new Map<String, dynamic>();
  // final facebookLogin = FacebookLogin();

  List<String> userTypeList = ["Select Type", "Retailer", "Agent"];
  String userType;
  //===========================
  String userGoogleID = "";
  String userFirstname = "";
  String userLastname = "";
  String userEmail = "";
  String userMobile = "";
  String userPassword = "";
  String forgotEmail = "";
  String deviceToken;
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  //========== Login handler =========
  void loginUser(BuildContext context) async {
    if (userType == "" || userType == userTypeList[0]) {
      showCustomToast("Please select user type");
      return;
    }
    if (userFirstname.trim() == "") {
      showCustomToast("Please enter first name.");
      return;
    }
    if (userLastname.trim() == "") {
      showCustomToast("Please enter last name.");
      return;
    }
    if (userMobile.trim() == "") {
      showCustomToast("Please enter mobile.");
      return;
    }
    if (userEmail.trim() == "" || !isEmail(userEmail)) {
      showCustomToast("Please enter a valid email.");
      return;
    }
    if (userPassword.trim() == "") {
      showCustomToast("Pleaase enter password");
      return;
    }
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

    print(Uri.parse(Consts.SIGNUP_USER + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.SIGNUP_USER + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var serverCode = responseData['code'];
      if (serverCode == "200") {
        print(response.body);
        RegisterUserModel registerUserModel = RegisterUserModel();

        registerUserModel.userId = responseData['user_id'].toString();
        registerUserModel.firstname = responseData['firstname'];
        registerUserModel.lastname = responseData['lastname'];
        registerUserModel.email = responseData['email'];
        registerUserModel.userType = responseData['user_type'];
        registerUserModel.phone = responseData['phone'];

        if (userRegType == "CU") {
          saveUserLoginPrefs(registerUserModel);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorytListScreen(),
            ),
          );
        } else {
          showCustomToast(serverMessage);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpScreen(),
            ),
          );
        }
      } else {
        showCustomToast(serverMessage);
      }
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
/*
  Future<Null> _handleFbLogin() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    print(result);
    // final result = await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        // print(accessToken.permissions);
        final token = accessToken.token;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}'));
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        _handleLogininfo(token);
        // _showMessage('''
        //  Logged in!

        //  Token: ${accessToken.token}
        //  User id: ${accessToken.userId}
        //  Expires: ${accessToken.expires}
        //  Permissions: ${accessToken.permissions}
        //  Declined permissions: ${accessToken.declinedPermissions}
        //  ''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        // _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        // _showMessage('Something went wrong with the login process.\n'
        //     'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }
*/

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
      appBar: AppBar(
        title: Text("Vedic"),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(
        //       Icons.search,
        //       color: Colors.white,
        //       size: 35,
        //     ),
        //     onPressed: () {
        //       debugPrint("Search Pressed");
        //     },
        //   )
        // ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "images/image_bg.png",
                ),
                fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              shapeComponet(context, 200),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                  left: 40,
                  right: 40,
                  top: 120,
                ),
                child: SingleChildScrollView(
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
                ),
              )
            ],
          ),
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
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          color: Color(0XFFFFFFFF),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.white,
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: userType,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              iconSize: 24,
              elevation: 16,
              items: userTypeList.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  userType = value;
                });
              },
            ),
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
              hintText: 'First Name',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            onChanged: (value) => {
              setState(
                () {
                  userFirstname = value;
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
              hintText: 'Last Name',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            onChanged: (value) => {
              setState(
                () {
                  userLastname = value;
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
              hintText: 'Mobile',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            onChanged: (value) => {
              setState(
                () {
                  userMobile = value;
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
              hintText: 'Email',
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
          child: new PasswordField(
            color: Colors.deepPurple,
            hasFloatingPlaceholder: false,
            // border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(2),
            //       borderSide: BorderSide(width: 2, color: Colors.purple)),
              // focusedBorder: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(10),
              //     borderSide: BorderSide(width: 2, color: Colors.purple)),
              errorStyle: TextStyle(color: Colors.green, fontSize: 18),
              hintText: "Password",
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              suffixIconEnabled: true,
              autoFocus:true,
          ),
          // new TextField(
          //   decoration: InputDecoration(
          //     enabledBorder: UnderlineInputBorder(
          //       borderSide: BorderSide(
          //         color: Color(0XFFD4DFE8),
          //         width: 2,
          //       ),
          //     ),
          //     focusedBorder: UnderlineInputBorder(
          //       borderSide: BorderSide(
          //         color: Color(0XFFD4DFE8),
          //         width: 2,
          //       ),
          //     ),
          //     hintText: 'Password',
          //     hintStyle: TextStyle(
          //       color: Colors.black,
          //     ),
          //   ),
          //   obscureText: true,
          //   onChanged: (value) => {
          //     setState(
          //       () {
          //         userPassword = value;
          //       },
          //     )
          //   },
          // ),
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
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
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
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: Text(
                "Login",
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
          height: 30,
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
          height: 80,
        ),
      ],
    );
  }
}
