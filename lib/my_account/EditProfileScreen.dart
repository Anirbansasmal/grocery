import 'dart:convert';

import 'package:groceryapp/my_account/MyAccountScreen.dart';

import '../category_list/CategorytListScreen.dart';
import '../manage_adresses/AllAddressesScreen.dart';
import '../shapes/screen_clip.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String previousScreen;

  const EditProfileScreen({Key key, this.previousScreen}) : super(key: key);
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _addressType;
  double shapeHeight = 140;
  // String flatName, streetName, landMark, areaName, zipCode;
  TextEditingController firstNameController;
  TextEditingController lastNamController;
  TextEditingController mobileNumberController;

  @override
  void initState() {
    //===================================
    firstNameController = TextEditingController();
    lastNamController = TextEditingController();
    mobileNumberController = TextEditingController();

    firstNameController.text = "";
    lastNamController.text = "";
    mobileNumberController.text = "";
    //===================================
    getSharedPrefs();
    super.initState();
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email =
        prefs.getString("email") == null ? '' : prefs.getString("email");
    var mobile =
        prefs.getString("phone") == null ? '' : prefs.getString("phone");
    var fName =
        prefs.getString("fname") == null ? '' : prefs.getString("fname");
    var lName =
        prefs.getString("lname") == null ? '' : prefs.getString("lname");
    setState(() {
      mobileNumberController = new TextEditingController(text: mobile);
      firstNameController = new TextEditingController(text: fName);
      lastNamController = new TextEditingController(text: lName);
    });
  }

  _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('user_id');
    if (firstNameController.text == null ||
        firstNameController.text.trim() == "") {
      showCustomToast("Please enter first name");
      return;
    }
    if (lastNamController.text == null || lastNamController.text.trim() == "") {
      showCustomToast("Please enter last name");
      return;
    }
    if (mobileNumberController.text == null ||
        mobileNumberController.text.trim() == "") {
      showCustomToast("Please enter mobile number");
      return;
    }

    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (!regExp.hasMatch(mobileNumberController.text)) {
      showCustomToast("Please enter valid mobile number");
      return;
    }

    String fName = firstNameController.text.trim();
    String lName = lastNamController.text.trim();
    String mobile = mobileNumberController.text.trim();
    var requestParam = jsonEncode(
      <String, dynamic>{
        "user_id": userId,
        "first_name": fName,
        "lastt_name": lName,
        "mobile_number": mobile
      },
    );

    print(Consts.UPDATE_PROFIL);
    final http.Response response = await http.post(
      Uri.parse(Consts.UPDATE_PROFIL),
      body: requestParam,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['status'];
      var serverMessage = responseData['message'];

      if (serverCode == "success") {
        showCustomToast(serverMessage);
        prefs.setString("fname", fName);
        prefs.setString("lname", lName);
        prefs.setString("phone", mobile);
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }
  }

  _selectAddress(String addresstype) {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // FocusScope.of(context).unfocus();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyAccountScreen(),
          ),
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                // Navigator.pop(context);
                // Navigator.pop(context);
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAccountScreen(),
                  ),
                );
              }),
          title: Text(
            "Vedic",
            style: TextStyle(
              fontFamily: "Philosopher",
              fontSize: 36,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/image_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(children: [
                    customShape(),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: new EdgeInsets.only(
                        top: shapeHeight * .50,
                        right: 20.0,
                        left: 20.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: Color(0XFFf9f7f7),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0XFFf9f7f7),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15.0,
                            right: 15,
                            bottom: 25,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              buildTextField("First Name"),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              buildTextField("Last Name"),
                              SizedBox(
                                height: 20,
                              ),
                              buildTextField("Mobile Number"),
                              SizedBox(
                                height: 50,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.appMainColor,
                                ),
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: TextButton(
                                  onPressed: () {
                                    _updateProfile();
                                  },
                                  child: Text(
                                    "Update".toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customShape() {
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
                height: 20,
              ),
              Text(
                "Edit Profile",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText) {
    return TextField(
      style: TextStyle(color: Colors.black),
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
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      controller: hintText == "First Name"
          ? firstNameController
          : hintText == "Last Name"
              ? lastNamController
              : hintText == "Mobile Number"
                  ? mobileNumberController
                  : null,
      onChanged: (value) => {
        setState(() {
          if (hintText == "First Name") {
            firstNameController.text = value;
            firstNameController.selection = TextSelection.fromPosition(
                TextPosition(offset: firstNameController.text.length));
          } else if (hintText == "Last Name") {
            lastNamController.text = value;
            lastNamController.selection = TextSelection.fromPosition(
                TextPosition(offset: lastNamController.text.length));
          } else if (hintText == "Mobile Number") {
            mobileNumberController.text = value;
            mobileNumberController.selection = TextSelection.fromPosition(
                TextPosition(offset: mobileNumberController.text.length));
          }
        }),
      },
    );
  }
}
