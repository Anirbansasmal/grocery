import 'dart:io';

import 'package:groceryapp/shapes/screen_clip.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController tecNewPassword, tecConfirmPassword;
  @override
  void initState() {
    // TODO: implement initState
    tecNewPassword = TextEditingController();
    tecConfirmPassword = TextEditingController();

    super.initState();
  }

  void getUserPassword() async {}

  void _changePassword() async {
    if (tecNewPassword.text == "" || tecNewPassword.text.length < 6) {
      showCustomToast("Password must be at least six character long");
      return;
    }
    if (tecConfirmPassword.text != tecNewPassword.text) {
      showCustomToast("Confirm password must be same as new password");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('user_id');

    var requestParam = "";

    requestParam += "?user_id=" + userId;
    requestParam += "&new_assword=" + tecNewPassword.text;
    requestParam += "&confirm_password=" + tecConfirmPassword.text;

    print(Uri.parse(Consts.CHANGE_PASSWORD + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.CHANGE_PASSWORD + requestParam),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      if (serverStatus == "success") {
        tecNewPassword.text ="";
        tecConfirmPassword.text ="";
      }
      showCustomToast(serverMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: Navigation(),
      appBar: AppBar(
        title: Text("Vedic"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              debugPrint("Search Pressed");
            },
          )
        ],
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
              customShape(context, Consts.shapeHeight),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                  left: 40,
                  right: 40,
                ),
                child: Align(
                  alignment: Alignment.center,
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
              hintText: 'New Password',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            obscureText: true,
            controller: tecNewPassword,
            onChanged: (value) => {
              setState(() {
                tecNewPassword.text = value;
                tecNewPassword.selection = TextSelection.fromPosition(
                    TextPosition(offset: tecNewPassword.text.length));
              }),
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
              hintText: 'Confirm Password',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            obscureText: true,
            controller: tecConfirmPassword,
            onChanged: (value) => {
              setState(() {
                tecConfirmPassword.text = value;
                tecConfirmPassword.selection = TextSelection.fromPosition(
                  TextPosition(offset: tecConfirmPassword.text.length),
                );
              }),
            },
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.appMainColor,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextButton(
            onPressed: () {
              _changePassword();
            },
            child: Text(
              "Update",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          height: 30,
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

  Widget customShape(BuildContext context, double shapeHeight) {
    return ClipPath(
      clipper: RedShape(MediaQuery.of(context).size.width, shapeHeight),
      child: Container(
        height: shapeHeight,
        decoration: BoxDecoration(
          color: Color(0XFFc80718),
        ),
        child: Container(
          margin: EdgeInsets.only(
            left: 35,
            right: 35,
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
