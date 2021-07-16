import '../checkout/CheckoutScreen.dart';
import '../shapes/screen_clip.dart';
import '../util/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaceOrderScreen extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<PlaceOrderScreen> {
  @override
  String _searchKey = "";
  bool openSearch;
  var _searchController = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    _searchKey = "";
    openSearch = false;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customShape(),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.white,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 5,
                              offset: Offset(
                                  0, 3.0), // shadow direction: bottom right
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 9),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    child: Image.asset("images/car.png"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      "DELIVERY ADDRESS",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // color: AppColors.checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 45),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "SDF building saltlake",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      // color: AppColors.checkoutDeliveryHeadingColor,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 40,
                                  // ),
                                  Text(
                                    "SDF building saltlake",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      // color: AppColors.checkoutDeliveryHeadingColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.white,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 5,
                              offset: Offset(
                                  0, 3.0), // shadow direction: bottom right
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 9),
                              child: Row(
                                children: [
                                  Container(
                                      height: 20,
                                      child: Image.asset("images/card.png")),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      "PAYMENT METHOD",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // color: AppColors.checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Ending********9999",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Container(
                                    height: 24,
                                    child: Text("Subtotal"),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "\u20B9",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors
                                            .checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                    Text(
                                      " 550",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors
                                            .checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Container(
                                    height: 24,
                                    child: Text("Shipping fees"),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "\u20B9",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors
                                            .checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                    Text(
                                      " 200",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        // color: AppColors.checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Container(
                                    height: 24,
                                    child: Text("Tax"),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "\u20B9",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors
                                            .checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                    Text(
                                      " 20",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        // color: AppColors.checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Container(
                                    height: 24,
                                    child: Text("Total"),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "\u20B9",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors
                                            .checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                    Text(
                                      " 770",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // color: AppColors.checkoutDeliveryHeadingColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget CustomAppbar() {
    return AppBar(
      centerTitle: true,
      title: openSearch
          ? Theme(
              data: Theme.of(context).copyWith(splashColor: Colors.transparent),
              child: TextField(
                controller: _searchController,
                autofocus: openSearch,
                onChanged: (value) => {
                  setState(
                    () {
                      _searchKey = value;
                    },
                  ),
                },
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFFbdc6cf),
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0XFFF8F8F8),
                  suffixIcon: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(),
                        ),
                      );
                    },
                    icon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        debugPrint("Test");
                        setState(
                          () {
                            _searchKey = "";
                            _searchController.text = "";
                          },
                        );
                      },

                      // icon:Icons.clear,
                      // color: Colors.black,
                      // size: 12,
                    ),
                  ),
                  hintText: 'Search..',
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.all(10.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                "Vedic",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 36,
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
                height: 50,
              ),
              Text(
                "ORDER CONFIRMATION",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
