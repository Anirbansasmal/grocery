import 'dart:convert';

import '../products/ProductModel.dart';
import '../util/AppColors.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../product_details/ProductDetails.dart';
import '../util/Consts.dart';
import 'SearchModel.dart';

class SearchItemProduct extends StatefulWidget {
  final Productdata productdata;
  // final bool isAgent;
  final Function() notifyCart;

  const SearchItemProduct({
    Key key,
    this.productdata,
    // this.isAgent, 
    this.notifyCart
  }) : super(key: key);
  @override
  _ItemProductState createState() => _ItemProductState();
}

class _ItemProductState extends State<SearchItemProduct> {
  bool isAgent;
  bool isWish;
  Productdata itemProduct;
  var requestParam;
  String deviceID;

  @override
  initState() {
    deviceID = '';

    initPlatformState();
    itemProduct = widget.productdata;
    print(itemProduct.brandName);
    isWish = itemProduct.isInWishlist == 1 ? true : false;
    isAgent = false;
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }
    debugPrint("Please device id ${deviceId}");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      deviceID = deviceId;
      print("deviceId->$deviceID");
    });
  }

  wishAdd(bool isWish, Productdata itemProduct) async {
    print(isWish);
    var addwis = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if (user_id == null) {
      user_id = '';
    }
    if (isWish) {
      addwis = "add";
    } else {
      addwis = "remove";
    }
    requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&device_id=" + deviceID.toString();
    requestParam += "&product_id=" + itemProduct.productId;
    requestParam += "&action=" + addwis;
    print(Consts.ADD_TO_WISHLIST + requestParam);
    final http.Response response = await http.get(
      Uri.parse(Consts.ADD_TO_WISHLIST + requestParam),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];
      if (serverCode == "200") {
        showCustomToast(serverMessage);
        if (user_id == '') {
          prefs.setString("user_id", responseData['user_id'].toString());
          prefs.setString("usertype", responseData['user_type'].toString());
        }
        setState(() {
          widget.productdata.isInWishlist = isWish ? 1 : 0;
        });
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }
  }

  _handleAddCart(Productdata itemProduct) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');

    if (user_id == null) {
      user_id = '';
    }

    print(user_id);

    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&device_id=" + deviceID.toString();
    requestParam += "&product_id=" + itemProduct.productId;
    requestParam += "&name=" + itemProduct.productTitle.trim();
    requestParam += "&price=" + itemProduct.productPrice;
    requestParam += "&quantity=1" ;
    print(Uri.parse(Consts.ADD_CART + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.ADD_CART + requestParam),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      if (serverCode == "200") {
        if (user_id == '') {
          prefs.setString("user_id", responseData['user_id'].toString());
          prefs.setString("usertype", responseData['user_type'].toString());
        }
        widget.notifyCart();
      }

      var serverMessage = responseData['message'];
      showCustomToast(serverMessage);
    } else {}
  }

  _gotoDetail() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(
          productdata: itemProduct,
          isAgent: isAgent,
          isSearch:true,
        ),
      ),
    );

    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data detail page $openCart");
      widget.notifyCart();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // double containerWidth = 100;
    return InkWell(
      onTap: () {
        _gotoDetail();
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                height: MediaQuery.of(context).size.height - 200,
                  width: MediaQuery.of(context).size.width-50,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(15),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.network(
                          itemProduct.galleryImages[0],
                          height: 100.0,
                          width: 100.0,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace stackTrace) {
                            return Container();
                          },
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 100.0,
                              width: 100.0,
                              child: Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                      Colors.grey,
                                    ),
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemProduct.productTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0XFF0D0D0D),
                              ),
                              softWrap: true,
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                              children: [
                                Text(
                                  "\u20B9 ${isAgent ? itemProduct.productDistributorPrice : itemProduct.productPrice}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.productPriceColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "\u20B9 ${itemProduct.productRegularPrice}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.productRegularColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 7,),
                            Text(
                              "${itemProduct.brandName}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0XFF0D0D0D),
                              ),
                              softWrap: true,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // _productListwish
                                  InkWell(
                                    onTap: () => {
                                      // if(isWish==true){
                                      setState(
                                        () {
                                          isWish = !isWish;
                                        },
                                      ),
                                      wishAdd(isWish, itemProduct),

                                      // wishAdd(),
                                    },
                                    child: itemProduct.isInWishlist == 1
                                        ? Image.asset(
                                            "images/ic_wishlistActive.png",
                                            height: 25,
                                          )
                                        : Image.asset(
                                            "images/ic_wishlist.png",
                                            height: 25,
                                          ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () => {
                                      _handleAddCart(itemProduct)
                                    },
                                    child: Image.asset(
                                      "images/busket.png",
                                      height: 25,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   right: 15,
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 15.0),
            //     child: Container(
            //       height: 50,
            //       width: 50,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: AppColors.appMainColor,
            //       ),
            //       child: Icon(
            //         Icons.shop,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
