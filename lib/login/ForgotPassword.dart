import '../util/Consts.dart';
import 'package:flutter/material.dart';
import '../util/AppColors.dart';
import '../util/Util.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String forgotEmail;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    forgotEmail = "";
  }

  void _submitForgot() async {
    if (forgotEmail.trim() == "") {
      showCustomToast("Please enter email.");
      return;
    }
    FocusScope.of(context).unfocus();
    var requestParam = "?email=" + forgotEmail.trim();
    final http.Response response = await http.get(
      Uri.parse(Consts.FORGOT_PASSWORD + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];
      if (serverCode == "200") {
        showCustomToast(serverMessage);
      } else {
        showCustomToast(serverMessage);
      }
      // print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Then, the content of your dialog.
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 1.0,
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            children: [
              Theme(
                data: ThemeData(
                  primaryColor: Colors.redAccent,
                  primaryColorDark: Colors.red,
                ),
                child: new TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFFD4DFE8),
                        width: 1,
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
                        forgotEmail = value;
                      },
                    )
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.appMainColor,
                ),
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    _submitForgot();
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
      ],
    );
  }
}
