import 'package:google_sign_in/google_sign_in.dart';

import '../shopping_cart/ShoppingCartScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Orders/MyOrdersScreen.dart';
import '../category_list/CategorytListScreen.dart';
import '../login/LoginScreen.dart';
import '../my_account/MyAccountScreen.dart';
import '../util/Util.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
class Navigation extends StatefulWidget {
  @override
  _Navigation createState() => _Navigation();
}

class _Navigation extends State<Navigation> {
  Future<int> _counter;
  var userData = {};
final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Object> _checkUserIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("user_id");
    String email = prefs.getString("email");
    String fname = prefs.getString("fname");
    String lname = prefs.getString("lname");
    if (userId == null) return null;
    userData.putIfAbsent("userId", () => userId);
    if (email == null) {
      userData.putIfAbsent("userEmail", () => '');
    } else {
      userData.putIfAbsent("userEmail", () => email);
    }
    if (fname == null) {
      userData.putIfAbsent("userName", () => '');
    } else {
      userData.putIfAbsent("userName", () => fname + ' ' + lname);
    }

    return userData;
  }

  void _logout(BuildContext context) async {
    showAlertDialogWithCancel(
      context,
      "Are you sure?",
      () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        Navigator.pop(context);
        await googleSignIn.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
    );
  }
Future<void> initPlatformState() async {
    String phone = "+919830946600";
    String whatsappUrl = "whatsapp://send?phone=$phone&text=" "";
    if (await canLaunch(whatsappUrl)) {
      await launch(
        whatsappUrl,
      );
    } else {
      print('Could not launch $whatsappUrl');
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
// return MaterialApp(

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 150,
              child: DrawerHeader(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
// AssetImage(image: 'images/image_bg.png'),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        // border: Border.all(color: Colors.white, width: 0.5),
                        image: DecorationImage(
                          image: AssetImage(
                            "images/app_logo.png",

                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
// child: Image.asset("images/image_bg.png"),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    FutureBuilder(
                      initialData: null,
                      future: _checkUserIsLoggedIn(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          var userObject = snapshot.data;
                          return Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  userObject['userName'] == null
                                      ? ""
                                      : userObject['userName'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(
                                  height: 9,
                                ),
                                Text(
                                  
                                  userObject['userEmail'] == null
                                      ? ""
                                      : "${userObject['userEmail']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(0XFFFFFF),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                height: 1,
                color: Color(0XFFe0e0e0),
              ),
            ),
            Expanded(
              child: ListView(
// Important: Remove any padding from the ListView.

                padding: EdgeInsets.only(top: 5),
                itemExtent: 45,
                children: <Widget>[


                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    title: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategorytListScreen(),
                        ),
                      );
                    },
                  ),
                  FutureBuilder(
                    initialData: null,
                    future: _checkUserIsLoggedIn(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        onTap: () {
                          Navigator.pop(context);
                          if (snapshot.hasData) {
                            debugPrint("has data");
                            var userObject = snapshot.data;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyAccountScreen(),
                              ),
                            );
                          } else {
                            debugPrint("no data");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          }
                        },
                        title: Text(
                          'My Account',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                  // FutureBuilder(
                  //   initialData: null,
                  //   future: _checkUserIsLoggedIn(),
                  //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //     return ListTile(
                  //       onTap: () {
                  //         Navigator.pop(context);
                  //         if (snapshot.hasData) {
                  //           debugPrint("has data");
                  //           var userObject = snapshot.data;
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => MyOrdersScreen(),
                  //             ),
                  //           );
                  //         } else {
                  //           debugPrint("no data");
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => LoginScreen(),
                  //             ),
                  //           );
                  //         }
                  //       },
                  //       title: Text(
                  //         'My Orders',
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  FutureBuilder(
                    initialData: null,
                    future: _checkUserIsLoggedIn(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        onTap: () {
                          Navigator.pop(context);
                          if (snapshot.hasData) {
                            debugPrint("has data");
                            var userObject = snapshot.data;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShoppingCartScreen(),
                              ),
                            );
                          } else {
                            debugPrint("no data");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          }
                        },
                        title: Text(
                          'My Cart',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                  FutureBuilder(
                    initialData: null,
                    future: _checkUserIsLoggedIn(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            _logout(context);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  // alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () => {
                      // FlutterOpenWhatsapp.sendSingleMessage("919830946600", "Hello"),
                      initPlatformState(),
                    },
                    child: Image.asset('images/icon_w.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
