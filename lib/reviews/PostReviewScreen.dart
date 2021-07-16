import 'dart:convert';

import '../products/ProductModel.dart';
import '../shapes/screen_clip.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../category_list/CategorytListScreen.dart';
import '../manage_adresses/AddAdressScreen.dart';
import '../manage_adresses/AddressModel.dart';
import '../manage_adresses/AllAddressesScreen.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'ReviewsScreen.dart';

class PostReviewScreen extends StatefulWidget {
  final String productId;
  final String productTitle;
  const PostReviewScreen({
    Key key,
    this.productId,
    this.productTitle,
  }) : super(key: key);
  @override
  _PostReviewScreenState createState() => _PostReviewScreenState();
}

class _PostReviewScreenState extends State<PostReviewScreen> {
  TextEditingController reviewMessageController;
  ProductModel mProductModel;
  String productId;
  String productTitle;
  @override
  void initState() {
    // TODO: implement initState
    productId = widget.productId;
    productTitle = widget.productTitle;
    reviewMessageController = TextEditingController();
    super.initState();
  }

  postReview() async {
    var reviewMessage = reviewMessageController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var email =
        prefs.getString("email") == null ? '' : prefs.getString("email");
    var fName =
        prefs.getString("fname") == null ? '' : prefs.getString("fname");
    var lName =
        prefs.getString("lname") == null ? '' : prefs.getString("lname");
    var requestParam = "?user_id=" + user_id;
    requestParam += "&user_review=" + reviewMessageController.text.trim();
    requestParam += "&product_id=" + productId;
    if (fName != '' && lName != '') {
      requestParam += "&user_name=" + fName + " " + lName;
    } else {
      requestParam += "&user_name=" + fName;
    }
    requestParam += "&user_email=" + email;

    debugPrint("${Uri.parse(Consts.postReview + requestParam)}");
    final http.Response response = await http.get(
      Uri.parse(Consts.postReview + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];

      if (serverStatus == "success") {
        reviewMessageController.clear();

        showCustomToast(serverMessage);
      } else {
        showCustomToast(serverMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ReviewScreen(
                    productId: productId,
                  )),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: Text(
            "Vedic",
            style: TextStyle(
              fontFamily: "Philosopher",
              fontSize: 36,
            ),
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SafeArea(
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
                          top: shapeHeight * .65,
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
                                buildTextField("Message"),
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
                                      postReview();
                                    },
                                    child: Text(
                                      "Post",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
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
      ),
    );
  }

  final double shapeHeight = 140;
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
                "Post Review",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "${productTitle}",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 15,
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
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
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
      controller: hintText == "Message" ? reviewMessageController : null,
      onChanged: (value) => {
        setState(() {
          if (hintText == "Message") {
            reviewMessageController.text = value;
            reviewMessageController.selection = TextSelection.fromPosition(
                TextPosition(offset: reviewMessageController.text.length));
          }
        }),
      },
    );
  }
}
