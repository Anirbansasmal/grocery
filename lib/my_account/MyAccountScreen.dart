import 'package:flutter/material.dart';
import 'package:groceryapp/login/LoginScreen.dart';
import 'package:groceryapp/reviews/MyReviewsScreen.dart';
import 'package:groceryapp/search/Search.dart';
import 'package:groceryapp/util/Consts.dart';
import 'package:groceryapp/util/Util.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../manage_adresses/AllAddressesScreen.dart';
import '../navigation_drawer/Navigation.dart';
import '../orders/MyOrdersScreen.dart';
import '../products/ProductListScreen.dart';
import '../shapes/screen_clip.dart';
import '../util/AppColors.dart';
import 'ChangePassword.dart';
import 'EditProfileScreen.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  TextStyle headingtextStyle = TextStyle(
    fontSize: 18,
    color: AppColors.myAccountHeadingColor,
    fontWeight: FontWeight.bold,
  );
  TextStyle bottomLinktextStyle = TextStyle(
    fontSize: 15,
    color: AppColors.myAccountTextColor,
    fontWeight: FontWeight.bold,
  );
  String _searchKey = "";
  bool openSearch;
  var _searchController = new TextEditingController();

  String userFName;
  String userLName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchKey = "";
    openSearch = false;
  }

  final double shapeHeight = 160;

  void _logout(BuildContext context) {
    showAlertDialogWithCancel(
      context,
      "Are you sure?",
      () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
    );
  }

  void _handleContextMenu(String menuItem, BuildContext context) {
    // {'Change Password', 'Logout'}
    //
    if (menuItem == "Change Password") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(),
        ),
      );
    } else if (menuItem == "Logout") {
      _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      drawer: Navigation(),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/image_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              customShape(),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    // MY ORDERS
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 25.0,
                          left: 25,
                          right: 25,
                          bottom: 25,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Orders",
                              style: headingtextStyle,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              height: 0.5,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyOrdersScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "View All Orders",
                                    style: bottomLinktextStyle,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    // MY Favourites
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 25.0,
                          left: 25,
                          right: 25,
                          bottom: 25,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Favourites",
                              style: headingtextStyle,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              height: 0.5,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductListScreen(
                                          categoryID: '',
                                          searchKeyword: '',
                                          myFav: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "View All Favourites Items",
                                    style: bottomLinktextStyle,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    // MY Address
                    SizedBox(
                      height: 35,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 25.0,
                          left: 25,
                          right: 25,
                          bottom: 25,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Addresses",
                              style: headingtextStyle,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              height: 0.5,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllAdressScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "View All Adresses",
                                    style: bottomLinktextStyle,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    // MY Reviews
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 25.0,
                          left: 25,
                          right: 25,
                          bottom: 25,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Reviews",
                              style: headingtextStyle,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              height: 0.5,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyReviewsScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "View All Reviews",
                                    style: bottomLinktextStyle,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 100,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                        child: Center(
                          child: TextButton(
                              onPressed: () {
                                _logout(context);
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget CustomAppbar() {
    return AppBar(
      title: Center(
        child: Text(
          "Vedic",
          style: TextStyle(
            fontFamily: "Philosopher",
            fontSize: 36,
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Search(),
                ),
              );
          },
        ),

        // IconButton(
        //   icon: Icon(
        //     Icons.more_vert,
        //     color: Colors.white,
        //     size: 35,
        //   ),
        //   onPressed: () {
        //     debugPrint("Settings");
        //   },
        // ),
        Theme(
          data: Theme.of(context).copyWith(
            cardColor: Colors.white,
          ),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              _handleContextMenu(value, context);
            },
            itemBuilder: (BuildContext context) {
              return {'Change Password', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  var userData = {};
  Future<Object> _checkUserIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    String fname = prefs.getString("fname");
    String lname = prefs.getString("lname");
    if (email == null) return null;
    userData.putIfAbsent("userEmail", () => email);
    userData.putIfAbsent("userName", () => fname + ' ' + lname);

    return userData;
  }

  void showMenuOption() {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(),
                ),
              );
            },
            child: Text(
              "Change Password",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
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

  Widget customShape() {
    return FutureBuilder(
      initialData: null,
      future: _checkUserIsLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          debugPrint("has data");
          var userObject = snapshot.data;
          return ClipPath(
            clipper: RedShape(
              MediaQuery.of(context).size.width,
              shapeHeight,
            ),
            child: Container(
              height: shapeHeight,
              decoration: BoxDecoration(
                color: Color(0XFFc80718),
              ),
              child: Container(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 15,
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "My Account",
                      style: TextStyle(
                        fontFamily: "Philosopher",
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      userObject['userName'] == null
                          ? ""
                          : userObject['userName'],
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Philosopher",
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userObject['userEmail'] == null
                              ? ""
                              : userObject['userEmail'],
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Philosopher",
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // showMenuOption();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
