import 'dart:convert';

import '../category_list/CategorytListScreen.dart';
import '../manage_adresses/AllAddressesScreen.dart';
import '../shapes/screen_clip.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddAdressScreen extends StatefulWidget {
  final String previousScreen;

  const AddAdressScreen({Key key, this.previousScreen}) : super(key: key);
  @override
  _AddAdressScreenState createState() => _AddAdressScreenState();
}

class _AddAdressScreenState extends State<AddAdressScreen> {
  String _addressType;
  double shapeHeight = 140;
  // String flatName, streetName, landMark, areaName, zipCode;
  TextEditingController nameController;
  TextEditingController emailController;
  TextEditingController mobileNumberController;
  TextEditingController flatNumberController;
  TextEditingController localityController;
  TextEditingController landMarkController;
  TextEditingController areaNameController;
  TextEditingController zipCodeController;

  var mAddress = {};
  String newAddress;
  String previousPage;
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  @override
  void initState() {
    //===================================
    nameController = TextEditingController();
    emailController = TextEditingController();
    mobileNumberController = TextEditingController();
    flatNumberController = TextEditingController();
    localityController = TextEditingController();
    landMarkController = TextEditingController();
    areaNameController = TextEditingController();
    zipCodeController = TextEditingController();

    nameController.text = "";
    emailController.text = "";
    mobileNumberController.text = "";
    flatNumberController.text = "";
    localityController.text = "";
    landMarkController.text = "";
    areaNameController.text = "";
    zipCodeController.text = "";

    _addressType = "";

    newAddress = "My new address.\nKolkata";
    mAddress['id'] = "333";
    mAddress['address'] = newAddress;

    getSharedPrefs();
    previousPage = widget.previousScreen;
    //===================================
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

      emailController = new TextEditingController(text: email);
      if (fName != '' && lName != '') {
        nameController = new TextEditingController(text: fName + ' ' + lName);
      } else {
        nameController = new TextEditingController(text: '');
      }
    });
  }

  _addNewAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if (nameController.text == null || nameController.text.trim() == "") {
      showCustomToast("Please enter name");
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

    if (emailController.text == null || emailController.text.trim() == "") {
      showCustomToast("Please enter an email");
      return;
    }
    if (!isEmail(emailController.text.trim())) {
      showCustomToast("Please enter a valid email");
      return;
    }
    if (flatNumberController.text == null ||
        flatNumberController.text.trim() == "") {
      showCustomToast("Please enter flat number");
      return;
    }
    if (localityController.text == null ||
        localityController.text.trim() == "") {
      showCustomToast("Please enter locality");
      return;
    }
    if (landMarkController.text == null ||
        landMarkController.text.trim() == "") {
      showCustomToast("Please enter landmark");
      return;
    }
    // if(areaNameController.text == null || areaNameController.text.trim() ==""){
    //   showCustomToast("Please enter area name");
    //   return;
    // }
    // String zipPatttern = r'(^(?:[+0]9)?[0-9]{6}$)';
    String zipPatttern = r'(^[1-9][0-9]{5}$)';
    RegExp regExpZip = new RegExp(zipPatttern);
    if (zipCodeController.text == null || zipCodeController.text.trim() == "") {
      showCustomToast("Please enter Pin Code");
      return;
    }
    if (!regExpZip.hasMatch(zipCodeController.text)) {
      showCustomToast("Please enter a valid Pin Code");
      return;
    }
    if (_addressType == null || _addressType == "") {
      showCustomToast("Please select address type");
      return;
    }

    var requestParam = "?user_id=" + user_id;
    requestParam += "&name=" + nameController.text.trim();
    requestParam += "&phone=" + mobileNumberController.text.trim();
    requestParam += "&email=" + emailController.text.trim();
    requestParam +=
        "&flat_house_floor_building=" + flatNumberController.text.trim();
    requestParam += "&locality=" + localityController.text.trim();
    requestParam += "&landmark=" + landMarkController.text.trim();
    requestParam += "&city=Kolkata";
    requestParam += "&state=WB";
    requestParam += "&country=India";
    requestParam += "&address_type=" + _addressType;
    requestParam += "&pincode=" + zipCodeController.text.trim();
    requestParam += "&default_billing=1";
    debugPrint("${Uri.parse(Consts.addNewAddress + requestParam)}");

    final http.Response response = await http.get(
      Uri.parse(Consts.addNewAddress + requestParam),
    );
    print(Uri.parse(Consts.addNewAddress + requestParam));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];

      if (serverCode == "200") {
        var rowId = responseData["row_id"].toString();
        print(responseData);
        if (int.parse(rowId) > 0) {
          setState(() {
            mobileNumberController.clear();
            flatNumberController.clear();
            localityController.clear();
            landMarkController.clear();
            areaNameController.clear();
            zipCodeController.clear();
            _addressType = "";
          });
          Navigator.pop(
            context,
            previousPage,
          );
        }
        showCustomToast(serverMessage);
      } else {
        showCustomToast(serverMessage);
      }
    }
  }

  _selectAddress(String addresstype) {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).unfocus();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AllAdressScreen()
        //   ),
        // );
        Navigator.pop(
          context,
          previousPage,
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
                FocusScope.of(context).unfocus();
                Navigator.pop(
                  context,
                  previousPage,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Name"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Mobile Number"),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 20,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Email"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),


                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Flat Number"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Locality"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Landmark"),
                                  ),
                                ],
                              ),
                              // SizedBox(height: 20,),
                              // buildTextField("Area Name"),
                              SizedBox(
                                height: 20,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTextField("Pin Code"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Container(

                                    height: 20,
                                    child: Text(
                                      "*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                            unselectedWidgetColor: Colors.red),
                                        child: Radio(
                                            activeColor: Colors.black,
                                            value: "Home",
                                            groupValue: _addressType,
                                            onChanged: (value) => {
                                                  _selectAddress(value),
                                                  setState(() {
                                                    _addressType = value;
                                                  }),
                                                }),
                                      ),
                                      Text(
                                        "Home",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                        softWrap: true,
                                      ),
                                      SizedBox(width: 10,),
                                      Row(
                                        children: <Widget>[
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                                unselectedWidgetColor:
                                                AppColors.appBarColor),
                                            child: Radio(
                                                activeColor: Colors.black,
                                                value: "Office",
                                                groupValue: _addressType,
                                                onChanged: (value) => {
                                                  _selectAddress(value),
                                                  setState(() {
                                                    _addressType = value;
                                                  }),
                                                }),
                                          ),
                                          Text(
                                            "Office",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ],
                              ),

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
                                    _addNewAddress();
                                  },
                                  child: Text(
                                    "Submit",
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
                "Add Address",
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
      controller: hintText == "Name"
          ? nameController
          : hintText == "Mobile Number"
              ? mobileNumberController
              : (hintText == "Email")
                  ? emailController
                  : (hintText == "Flat Number")
                      ? flatNumberController
                      : (hintText == "Locality")
                          ? localityController
                          : (hintText == "Landmark")
                              ? landMarkController
                              : (hintText == "Area name")
                                  ? areaNameController
                                  : (hintText == "Pin Code")
                                      ? zipCodeController
                                      : null,
      onChanged: (value) => {
        // setState(() {
        //   if (hintText == "Name") {
        //     nameController.text = value;
        //     nameController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: nameController.text.length));
        //   } else if (hintText == "Mobile Number") {
        //     mobileNumberController.text = value;
        //     mobileNumberController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: mobileNumberController.text.length));
        //   } else if (hintText == "Email") {
        //     emailController.text = value;
        //     emailController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: emailController.text.length));
        //   } else if (hintText == "Flat Number") {
        //     flatNumberController.text = value;
        //     flatNumberController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: flatNumberController.text.length));
        //   } else if (hintText == "Locality") {
        //     localityController.text = value;
        //     localityController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: localityController.text.length));
        //   } else if (hintText == "Landmark") {
        //     landMarkController.text = value;
        //     landMarkController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: landMarkController.text.length));
        //   } else if (hintText == "Area name") {
        //     areaNameController.text = value;
        //     areaNameController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: areaNameController.text.length));
        //   } else if (hintText == "Zip Code") {
        //     zipCodeController.text = value;
        //     zipCodeController.selection = TextSelection.fromPosition(
        //         TextPosition(offset: zipCodeController.text.length));
        //   }
        // }),
      },
    );
  }
}
