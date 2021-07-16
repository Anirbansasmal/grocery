import 'dart:convert';

import '../signup/RegisterModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveUserLoginPrefs(RegisterUserModel registerUserModel) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  preferences.setBool("isLoggedIn", true);

  preferences.setString("user_id", registerUserModel.userId.toString());
  preferences.setString("fname", registerUserModel.firstname.toString());
  preferences.setString("lname", registerUserModel.lastname.toString());
  preferences.setString("email", registerUserModel.email.toString());
  preferences.setString("phone", registerUserModel.phone.toString());
  preferences.setString("usertype", registerUserModel.userType.toString());
}