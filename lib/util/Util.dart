import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';

import 'Consts.dart';

showAlertDialog(BuildContext context, String message, Function onOKPressed) {
  PackageInfo _packageInfo = PackageInfo(
    appName: Consts.APP_NAME,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: onOKPressed,
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      Consts.APP_NAME,
      style: TextStyle(
        color: Colors.black87,
        fontFamily: "Philosopher",
      ),
    ),
    content: Text(
      message,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white,
        ),
        child: Container(child: alert),
      );
    },
  );
}

showAlertDialogWithCancel(
    BuildContext context, String message, Function onOKPressed) {
  PackageInfo _packageInfo = PackageInfo(
    appName: Consts.APP_NAME,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  var buttonStyleOK = TextStyle(
    color: Colors.blue,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  var buttonStyleCancel = TextStyle(
    color: Colors.blue,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // set up the button
  Widget okButton = TextButton(
    child: Text(
      "OK",
      style: buttonStyleOK,
    ),
    onPressed: onOKPressed,
  );
  Widget cancelButton = TextButton(
    child: Text(
      "Cancel",
      style: buttonStyleCancel,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    insetPadding: EdgeInsets.all(0),
    title: Text(
      Consts.APP_NAME,
      style: TextStyle(
        color: Colors.black87,
        fontFamily: "Philosopher",
      ),
    ),
    content: Text(
      message,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
    actions: [
      okButton,
      cancelButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white,
        ),
        child: Container(child: alert),
      );
    },
  );
}

showCustomToast(String message, [Color mColor]) {
  mColor ??= Color(0x99000000);
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    fontSize: 16.0,
    textColor: Colors.black,
  );
}
