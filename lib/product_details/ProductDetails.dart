import 'dart:convert';

import 'package:groceryapp/login/LoginScreen.dart';
import 'package:groceryapp/search/SearchModel.dart';
import 'package:groceryapp/util/Variables.dart';

import '../reviews/PostReviewScreen.dart';
import '../reviews/ReviewsScreen.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../products/ProductModel.dart';
import '../shapes/screen_clip.dart';
import '../shopping_cart/ShoppingCartScreen.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_viewer/image_viewer.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel itemProduct;
  final Productdata productdata;
  final bool isAgent;
  final String previousScreen;
  final bool isSearch;

  const ProductDetails(
      {Key key,
      this.itemProduct,
      this.isAgent,
      this.previousScreen,
      this.productdata,
      this.isSearch})
      : super(key: key);
  @override
  _ProductDetails createState() => _ProductDetails();
}

class _ProductDetails extends State<ProductDetails> {
  List<String> imgList = [];

  bool isApiCalling;

  bool isAgent;
  bool _isSearch;
  bool isWish;
  int _itemCount;
  double productPrice;
  double price;
  double priceCart = 0;
  int quantity;
  bool _isAddedToCart;
  bool _callingUpdateApi;
  int rowId;
  SharedPreferences prefs;

  String deviceID;
  var requestParam;
  TextEditingController quantityController;

  bool isUserLoggedIn;

  @override
  void initState() {
    // TODO: implement initState

    isAgent = widget.isAgent;
    productPrice = 0;
    quantityController = TextEditingController();
    isWish = widget.itemProduct.isInWishList == 1 ? true : false;
    _itemCount = 1;
    quantityController.text = "$_itemCount";
    _isAddedToCart = false;
    _callingUpdateApi = false;
    _isSearch = false;
    quantity = 0;
    super.initState();

    _isSearch = widget.isSearch;
    if (_isSearch == null) {
      _isSearch = false;
    }
    if (_isSearch) {
      imgList = widget.productdata.galleryImages;
      if (isAgent) {
        productPrice =
            double.parse(widget.productdata.productDistributorPrice.toString());
      } else {
        productPrice = double.parse(widget.productdata.productPrice.toString());
      }
    } else {
      imgList = widget.itemProduct.galleryImages;
      debugPrint('imgList');
      print(imgList);
      if (isAgent) {
        productPrice =
            double.parse(widget.itemProduct.productDistributorPrice.toString());
      } else {
        productPrice = double.parse(widget.itemProduct.productPrice.toString());
      }
    }

    price = productPrice * _itemCount;

    isApiCalling = false;

    isUserLoggedIn = false;

    _handleFetchCart();

    initPlatformState();
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

  Future<Null> _handleAddCart(
      String productId, String productTitle, String productPrice) async {
    prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');

    if (user_id == null) {
      user_id = '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      print(user_id);

      var requestParam = "?";
      requestParam += "user_id=" + user_id;
      // requestParam += "&device_id=" + deviceID.toString();
      requestParam += "&product_id=" + productId;
      requestParam += "&name=" + productTitle.trim();
      requestParam += "&price=" + productPrice;
      requestParam += "&quantity=" + _itemCount.toString();
      print(Uri.parse(Consts.ADD_CART + requestParam));

      setState(() {
        _callingUpdateApi = true;
      });

      final http.Response response = await http.get(
        Uri.parse(Consts.ADD_CART + requestParam),
      );

      if (response.statusCode == 200) {
        print(response.body);
        var responseData = jsonDecode(response.body);
        var serverCode = responseData['code'];
        if (serverCode == "200") {
          if (user_id == '') {
            prefs.setString("user_id", responseData['user_id'].toString());
            prefs.setString("usertype", responseData['user_type'].toString());
          }
          setState(() {
            _isAddedToCart = true;
            quantity += 1;
            rowId = int.parse(responseData['row_id'].toString());
          });
          Variables.itemCount = quantity;
        }

        var serverMessage = responseData['message'];
        showCustomToast(serverMessage);
      } else {}

      setState(() {
        _callingUpdateApi = false;
      });
    }
  }

  Future<Null> _handleFetchCart() async {
    prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    String productId;
    if (user_id == null) {
      return null;
    }
    setState(() {
      isUserLoggedIn = true;
      _isAddedToCart = false;
      _itemCount = 1;
    });
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    print(requestParam);
    final http.Response response = await http.get(
      Uri.parse(Consts.VIEW_CART + requestParam),
    );

    print(Consts.VIEW_CART + requestParam);
    print(response.body);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];
      if (serverCode == "200") {
        var arrCartProducts = responseData["productdata"];
        if (arrCartProducts.length > 0) {
          for (int i = 0; i < arrCartProducts.length; i++) {
            if (_isSearch) {
              productId = widget.productdata.productId;
            } else {
              productId = widget.itemProduct.productId;
            }
            if (productId == arrCartProducts[i]['product_id'].toString()) {
              setState(() {
                _isAddedToCart = true;
                rowId = int.parse(arrCartProducts[i]['row_id'].toString());
                _itemCount = int.parse(arrCartProducts[i]['qty'].toString());

                quantityController.text = "$_itemCount";

                price = productPrice * _itemCount;
              });
            }
          }
          setState(() {
            quantity = arrCartProducts.length;
          });
          Variables.itemCount = quantity;
        } else {
          setState(() {
            quantityController.text = "$_itemCount";
          });
        }
      } else {
        print("Else part");
        setState(() {
          quantity = 0;
          _itemCount = 1;
          _isAddedToCart = false;
          price = productPrice * _itemCount;
          _callingUpdateApi = false;

          quantityController.text = "$_itemCount";
        });
        Variables.itemCount = quantity;
      }
    }
  }

  _updateCart(String productId, int quantity) async {
    if (quantity <= 0) {}
    setState(() {
      _callingUpdateApi = true;
    });
    var requestParam = "?";
    requestParam += "row_id=" + rowId.toString();
    requestParam += "&quantity=" + quantity.toString();
    final http.Response response = await http.get(
      Uri.parse(Consts.UPDATE_CART + requestParam),
    );
    print(Consts.UPDATE_CART + requestParam);
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        _callingUpdateApi = false;
      });
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];

      if (serverCode == "200") {
        showCustomToast(serverMessage);
      }
    } else {}
  }

  _gotoShoppinCartScreen() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingCartScreen(),
      ),
    );

    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data $openCart");
      _handleFetchCart();
      setState(() {});
    }
  }

  _addtocartBtnPressed() {
    debugPrint("_addtocartBtnPressed pressed");

    if (_isAddedToCart) {
      if (_isSearch == true) {
        if (_itemCount == 0) {
          _handleRemove(widget.productdata.productId);
        } else {
          _updateCart(widget.productdata.productId, _itemCount);
        }
      } else {
        if (_itemCount == 0) {
          _handleRemove(widget.itemProduct.productId);
        } else {
          _updateCart(widget.itemProduct.productId, _itemCount);
        }
      }
    } else {
      if (_isSearch) {
        _handleAddCart(widget.productdata.productId,
            widget.productdata.productTitle, widget.productdata.productPrice);
      } else {
        _handleAddCart(widget.itemProduct.productId,
            widget.itemProduct.productTitle, widget.itemProduct.productPrice);
      }
    }
  }

  _handleRemove(String productId) async {
    prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');

    if (user_id == null) {
      return;
    }
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&product_id=" + productId;
    print(Uri.parse(Consts.DELETE_CART_FROM_DETAILS + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.DELETE_CART_FROM_DETAILS + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['status'];
      if (serverCode == "success") {
        quantity = quantity - 1;
        Variables.itemCount = Variables.itemCount - 1;
        setState(() {
          _isAddedToCart = false;
          rowId = 0;
          _itemCount = 1;
          quantityController.text = "$_itemCount";
          price = productPrice * _itemCount;
        });
      }

      var serverMessage = responseData['message'];
      showCustomToast(serverMessage);
    } else {}
  }

  wishAdd(bool isWish, ProductModel itemProduct) async {
    print(isWish);
    var addwis = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if (user_id == null) {
      user_id = '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
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
            widget.itemProduct.isInWishList = isWish ? 1 : 0;
          });
        } else {
          showCustomToast(serverMessage);
        }
      } else {
        showCustomToast(Consts.SERVER_NOT_RESPONDING);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ProductModel itemProduct = widget.itemProduct;
    double shapeHeight = 170;
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "refresh cart");
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // drawer: Navigation(),
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: Center(
              child: Text(
            "Vedic",
            style: TextStyle(fontFamily: "Philosopher", fontSize: 36),
          )),
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  width: 40,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Container(
                            width: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.appMainColor,
                              border: Border.all(
                                color: Colors.white,
                                width: 0.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                Variables.itemCount == null
                                    ? "0"
                                    : "${Variables.itemCount}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                // _handleAddCart(itemProduct);
                _gotoShoppinCartScreen();
              },
            )
          ],
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
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: <Widget>[
// The containers in the background
                              new Column(
                                children: <Widget>[
                                  // shapeComponet(context, Consts.shapeHeight),
                                  ClipPath(
                                    clipper: RedShape(
                                        MediaQuery.of(context).size.width,
                                        shapeHeight),
                                    child: Container(
                                      height: shapeHeight,
                                      decoration: BoxDecoration(
                                        color: Color(0XFFc80718),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 20,
                                          right: 10,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 15,
                                          ),
                                          child: Text(
                                            _isSearch != true
                                                ? itemProduct.productTitle
                                                : widget
                                                    .productdata.productTitle,
                                            style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
// The card widget with top padding,
// incase if you wanted bottom padding to work,
// set the `alignment` of container to Alignment.bottomCenter
                              new Container(
                                alignment: Alignment.topCenter,
                                color: Colors.transparent,
                                padding: new EdgeInsets.only(
                                  top: shapeHeight * .60,
                                  right: 0.0,
                                  left: 0.0,
                                ),
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    autoPlay: true,
                                    enlargeCenterPage: true,
                                    reverse: false,
                                    // aspectRatio: 2.2,
                                    height: 150,
                                    viewportFraction: 0.8,
                                    enlargeStrategy:
                                        CenterPageEnlargeStrategy.height,
                                  ),
                                  items: imgList
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Container(
                                            height: 300,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(9),
                                              ),
                                              border: Border.all(
                                                  color: AppColors
                                                      .categoryProductLayout,
                                                  width: 1),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 120,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      50,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                    child: Image.network(
                                                      item,
                                                      fit: BoxFit.cover,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              50,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: InkWell(
                                                    onTap: () {
                                                      // _addtocartBtnPressed();
                                                      ImageViewer
                                                          .showImageSlider(
                                                        images: imgList,
                                                        startingPosition: 0,
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 60,
                                                      width: 60,
                                                      // decoration: BoxDecoration(
                                                      //   shape: BoxShape.circle,
                                                      //   // color: AppColors
                                                      //   //     .appMainColor,
                                                      // ),
                                                      child: Image.asset(
                                                        "images/view_img.png",
                                                        height: 50,
                                                        width: 50,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
// ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 18.0,
                              right: 8.0,
                              top: 20,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    // color: AppColors.appBarColor,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                _isSearch != true
                                                    ? itemProduct.productTitle
                                                    : widget.productdata
                                                        .productTitle,
                                                style: TextStyle(
                                                  color: AppColors
                                                      .categoryTextColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        //   ],
                                        // ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                              child:
                                                  itemProduct.isInWishList == 1
                                                      ? Image.asset(
                                                          "images/ic_wishlistActive.png",
                                                          height: 25,
                                                        )
                                                      : Image.asset(
                                                          "images/ic_wishlist.png",
                                                          height: 25,
                                                        ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "\u20B9 $price",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            // Row(
                                            //   mainAxisSize: MainAxisSize.min,
                                            //   mainAxisAlignment: MainAxisAlignment.end,
                                            //   children: [
                                            //     Container(
                                            //       child: Stack(
                                            //         children: [
                                            //           Row(
                                            //             children: [
                                            //               Container(
                                            //                 height: 50,
                                            //                 width: 50,
                                            //                 child: IconButton(
                                            //                   icon: Image.asset(
                                            //                       'images/ic_minus.png'),
                                            //                   onPressed: () {
                                            //                     DcrBtn();
                                            //                   },
                                            //                 ),
                                            //               ),
                                            //               Container(
                                            //                 width: 60,
                                            //                 alignment: Alignment.center,
                                            //                 child: TextField(
                                            //                   enableInteractiveSelection:
                                            //                       false,
                                            //                   keyboardType:
                                            //                       TextInputType.number,
                                            //                   inputFormatters: <
                                            //                       TextInputFormatter>[
                                            //                     FilteringTextInputFormatter
                                            //                         .allow(
                                            //                       RegExp(r'[0-9]'),
                                            //                     ),
                                            //                   ],
                                            //                   controller:
                                            //                       quantityController,
                                            //                   textAlign:
                                            //                       TextAlign.center,
                                            //                   style: TextStyle(
                                            //                     color: Colors.black,
                                            //                   ),
                                            //                   decoration:
                                            //                       InputDecoration(
                                            //                     filled: true,
                                            //                     fillColor:
                                            //                         Color(0XFFF8F8F8),
                                            //                     focusedBorder:
                                            //                         UnderlineInputBorder(
                                            //                       borderSide:
                                            //                           BorderSide(
                                            //                         color: Color(
                                            //                             0XFFD4DFE8),
                                            //                         width: 2,
                                            //                       ),
                                            //                     ),
                                            //                     hintText: "0",
                                            //                     hintStyle: TextStyle(
                                            //                       color: Colors.black,
                                            //                     ),
                                            //                   ),
                                            //                   onChanged: (value) {
                                            //                     if (value != "") {
                                            //                       setState(() {
                                            //                         _itemCount =
                                            //                             int.parse(
                                            //                                 value);
                                            //                         if (value == "") {
                                            //                           price =
                                            //                               productPrice *
                                            //                                   1;
                                            //                         }
                                            //
                                            //                         if (_itemCount >=
                                            //                             1) {
                                            //                           price =
                                            //                               productPrice *
                                            //                                   _itemCount;
                                            //                         } else if (_itemCount ==
                                            //                             0) {
                                            //                           price =
                                            //                               productPrice *
                                            //                                   1;
                                            //                         } else {
                                            //                           price =
                                            //                               productPrice *
                                            //                                   1;
                                            //                         }
                                            //                       });
                                            //                     } else {
                                            //                       debugPrint("Blank");
                                            //                       setState(() {
                                            //                         price =
                                            //                             productPrice *
                                            //                                 1;
                                            //                         _itemCount = 0;
                                            //                       });
                                            //                     }
                                            //                   },
                                            //                 ),
                                            //               ),
                                            //               Container(
                                            //                 height: 50,
                                            //                 width: 50,
                                            //                 child: IconButton(
                                            //                   icon: Image.asset(
                                            //                       'images/ic_plus.png'),
                                            //                   onPressed: () {
                                            //                     IncrBtn();
                                            //                   },
                                            //                 ),
                                            //               ),
                                            //             ],
                                            //           ),
                                            //           _callingUpdateApi
                                            //               ? Center(
                                            //                   child: Container(
                                            //                     margin: EdgeInsets.only(
                                            //                       top: 15,
                                            //                     ),
                                            //                     height: 20,
                                            //                     width: 20,
                                            //                     child:
                                            //                         CircularProgressIndicator(
                                            //                       valueColor:
                                            //                           new AlwaysStoppedAnimation<
                                            //                                   Color>(
                                            //                               Colors
                                            //                                   .blueGrey),
                                            //                       strokeWidth: 2,
                                            //                     ),
                                            //                   ),
                                            //                 )
                                            //               : Container(),
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
// height: 150,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _isSearch != true
                                                    ? itemProduct
                                                        .productDescription
                                                    : widget.productdata
                                                        .productDescription,
                                                style: TextStyle(
                                                  color: AppColors
                                                      .categoryTextColor,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              // Text(
                                              //   "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like",
                                              //   style: TextStyle(
                                              //       color: AppColors.categoryTextColor,
                                              //       fontSize: 16,
                                              //       fontWeight: FontWeight.w400,
                                              //       fontFamily: "Philosopher"),
                                              // ),
                                              SizedBox(
                                                height: 50,
                                              ),
                                              // Center(
                                              //   child: Container(
                                              //     width:
                                              //         MediaQuery.of(context).size.width - 100,
                                              //     height: 45,
                                              //     decoration: BoxDecoration(
                                              //       color: Colors.black,
                                              //       borderRadius:
                                              //           BorderRadius.all(Radius.circular(9)),
                                              //     ),
                                              //     child: !_isAddedToCart
                                              //         ? TextButton(
                                              //             onPressed: () {
                                              //               _handleAddCart(itemProduct);
                                              //             },
                                              //             child: Text(
                                              //               'Add to cart'.toUpperCase(),
                                              //               style: TextStyle(
                                              //                 color: Colors.white,
                                              //               ),
                                              //             ))
                                              //         : TextButton(
                                              //             onPressed: () {
                                              //               Navigator.push(
                                              //                 context,
                                              //                 MaterialPageRoute(
                                              //                   builder: (context) =>
                                              //                       ShoppingCartScreen(),
                                              //                 ),
                                              //               );
                                              //             },
                                              //             child: Text(
                                              //               'Go to cart'.toUpperCase(),
                                              //               style: TextStyle(
                                              //                 color: Colors.white,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //   ),
                                              // ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              isUserLoggedIn
                                                  ? Column(
                                                      children: [
                                                        Container(
                                                          height: 1,
                                                          color:
                                                              Color(0XFFCECDCD),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        )
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewScreen(
                                        productId: _isSearch != true
                                            ? widget.itemProduct.productId
                                            : widget.productdata.productId,
                                        productTitle: _isSearch != true
                                            ? itemProduct.productTitle
                                            : widget.productdata.productTitle,
                                        // itemProduct: _isSearch != true ? widget.productdata:itemProduct,
                                        // itemProduct: _isSearch != true ? widget.productdata:itemProduct,
                                        isUserLoggedIn: isUserLoggedIn,
                                      )),
                            );
                          },
                          child: Text(
                            'Reviews'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: 0.5,
                        color: Colors.white,
                      ),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: _isAddedToCart
                                ? Stack(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 50,
                                            child: IconButton(
                                              icon: Image.asset(
                                                  'images/ic_minus.png'),
                                              onPressed: () {
                                                DcrBtn();
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 70,
                                              alignment: Alignment.center,
                                              child: TextField(
                                                enableInteractiveSelection:
                                                    false,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[0-9]'),
                                                  ),
                                                ],
                                                controller: quantityController,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.all(10),
                                                  filled: true,
                                                  fillColor: Color(0XFFF8F8F8),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0XFFD4DFE8),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  hintText: "Qantity",
                                                  hintStyle: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                onSubmitted: (value) {
                                                  debugPrint(
                                                      "Value in  input box $value");
                                                  if (value == "" ||
                                                      value == null) {
                                                    showCustomToast(
                                                        "Please input quantity");
                                                  } else {
                                                    if (int.parse(value) > 0) {
                                                      _addtocartBtnPressed();
                                                    } else {
                                                      showCustomToast(
                                                          "Please input quantity");
                                                    }
                                                  }
                                                },
                                                onChanged: (value) {
                                                  if (value != "") {
                                                    setState(() {
                                                      _itemCount =
                                                          int.parse(value);
                                                      if (value == "") {
                                                        price =
                                                            productPrice * 1;
                                                      }

                                                      if (_itemCount >= 1) {
                                                        price = productPrice *
                                                            _itemCount;
                                                      } else if (_itemCount ==
                                                          0) {
                                                        price =
                                                            productPrice * 1;
                                                      } else {
                                                        price =
                                                            productPrice * 1;
                                                      }
                                                    });
                                                  } else {
                                                    debugPrint("Blank");
                                                    setState(() {
                                                      price = productPrice * 1;
                                                      _itemCount = 0;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 70,
                                            width: 50,
                                            child: IconButton(
                                              icon: Image.asset(
                                                  'images/ic_plus.png'),
                                              onPressed: () {
                                                IncrBtn();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      _callingUpdateApi
                                          ? Center(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  top: 15,
                                                ),
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors.blueGrey),
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : InkWell(
                                    onTap: () {
                                      _addtocartBtnPressed();
                                    },
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          "Add To Cart".toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IncrBtn() {
    // setState(() => _itemCount++);
    // priceCart=price*_itemCount;
    setState(() {
      _itemCount++;
      quantityController.text = "$_itemCount";
      price = productPrice * _itemCount;

      quantityController.selection = TextSelection.fromPosition(
          TextPosition(offset: quantityController.text.length));
    });
    _addtocartBtnPressed();
  }

  DcrBtn() {
    setState(() {
      _itemCount <= 0 ? _itemCount = 0 : _itemCount--;
      _itemCount == 0
          ? quantityController.clear()
          : quantityController.text = "$_itemCount";
      price = _itemCount > 0 ? productPrice * _itemCount : productPrice * 1;

      quantityController.selection = TextSelection.fromPosition(
          TextPosition(offset: quantityController.text.length));
    });

    _addtocartBtnPressed();
  }

  setQuantity() {
    showCustomToast("${quantityController.text}");
    setState(() {});
  }
}
