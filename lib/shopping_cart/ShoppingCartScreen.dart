import 'dart:convert';

import 'package:groceryapp/category_list/CategorytListScreen.dart';
import 'package:groceryapp/util/Variables.dart';

import '../offer/ApplyPromoScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../checkout/CheckoutScreen.dart';
import '../products/ProductListScreen.dart';
import '../products/ProductModel.dart';
import '../shapes/screen_clip.dart';
import '../shopping_cart/ItemShoppingCart.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import 'ShoppingCartModel.dart';

class ShoppingCartScreen extends StatefulWidget {
  final ProductModel itemProduct;

  const ShoppingCartScreen({Key key, this.itemProduct}) : super(key: key);
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  String _offers;
  bool hasItemsInCart;
  bool isApiCalled;
  bool isApply;
  Future<List<ShoppingCartModel>> _productList;
  List<ShoppingCartModel> mProductList;
  double shippingCharge;
  double taxAmount;
  double totalAmount;
  double totalAmountWithoutDiscount;
  double savedAmount;

  String discountType;
  double promoAmount;
  double promoDisAmount;
  String promoApplied;
  String paymentMethod;
  int couponId;

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
  String quentity;
  double _subTotalPrice;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _offers = "Test";
    hasItemsInCart = false;
    isApply = false;
    _searchKey = "";
    openSearch = false;
    mProductList = [];
    _handleFetchCart();
    _subTotalPrice = 0;
    isApiCalled = false;

    shippingCharge = 00;
    totalAmount = 0;
    savedAmount = 0;
    totalAmountWithoutDiscount = 0;
    taxAmount = 0;
    promoDisAmount = 0;

    discountType = '';
    promoAmount = 0;
    promoApplied = "";
    paymentMethod = "COD";
    couponId = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("ShoppingCartScreen shown");
    }
  }

  _handleFetchCart() async {
    double totalPrice = 0;
    double savedPrice = 0;
    List<ShoppingCartModel> mList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    print(user_id);
    final http.Response response = await http.get(
      Uri.parse(Consts.VIEW_CART + requestParam),
    );
    print(Consts.VIEW_CART + requestParam);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['status'];
      var productdataCount = responseData["productdata"];
      print(responseData);
      if (responseData['status'] == "success") {
        // print(mList);

        if (productdataCount.length > 0) {
          for (int i = 0; i < productdataCount.length; i++) {
            // List<String> galleryImages =[];
            var itemData = productdataCount[i];
            print(itemData);
            ShoppingCartModel item = ShoppingCartModel();
            // var productDetails =itemData['productdata'];
            item.name = itemData['name'];
            item.product_id = itemData['product_id'];
            item.qty = itemData['qty'];
            item.row_id = itemData['row_id'];
            item.user_id = itemData['user_id'];
            item.price = itemData['price'];
            item.regularPrice = itemData['regular_price'];

            item.product_image = itemData['product_image'];
            totalPrice += (double.parse(item.price) * int.parse(item.qty));

            if (item.regularPrice == "0.00") {
              savedPrice = 0.0;
              debugPrint("savedAmount" + item.regularPrice);
            } else {
              savedPrice +=
                  ((double.parse(item.regularPrice) * int.parse(item.qty)) -
                      (double.parse(item.price) * int.parse(item.qty)));
            }

            mList.add(item);
          }

          Variables.itemCount = productdataCount.length;
          double shippingFee =
              double.parse(responseData['shipping_fee'].toString());
          double tax = double.parse(responseData['tax'].toString());
          setState(() {
            if (shippingFee > 0) {
              shippingCharge = shippingFee;
            }
            if (tax > 0) {
              taxAmount = tax;
            }
          });
        } else {
          Variables.itemCount = 0;
        }
      } else {
        Variables.itemCount = 0;
      }
      double total = totalPrice + shippingCharge + taxAmount;
      debugPrint("Returned total $total");
      if (total <= 999.00) {
        setState(() {
          isApply = false;
          promoAmount = 0;
        });
      } else {
        setState(() {
          isApply = true;
          promoAmount = ((total * promoDisAmount) / 100);
        });
      }
      setState(() {
        mProductList = mList;
        quentity = productdataCount.length.toString();
        _subTotalPrice = totalPrice;

        totalAmount = totalPrice + shippingCharge + taxAmount;
        totalAmountWithoutDiscount = totalAmount;
        savedAmount = savedPrice;
        if (mList.length > 0) {
          hasItemsInCart = true;
        } else {
          hasItemsInCart = false;
        }
        isApiCalled = true;
      });
      // print(quentity);

    } else {}

    // Variables.itemCount = int.parse(quentity);

    return mList;
  }

  final double shapeHeight = 140;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "refresh cart");
        // Navigator.pop(context);
        // if(mProductList.length > 0){
        //   Navigator.pop(context);
        //   Navigator.pop(context);
        // }
        // else {
        //   Navigator.pop(context);
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => CategorytListScreen(),
        //     ),
        //   );
        // }
      },
      child: Scaffold(
        appBar: CustomAppbar(),
        // drawer: Navigation(),
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
              physics: ScrollPhysics(),
              child: !hasItemsInCart
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Color(0XFFf9f7f7),
                                width: 4,
                              ),
                            ),
                            height: MediaQuery.of(context).size.height - 200,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: isApiCalled
                                  ? Text("No items in cart")
                                  : CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        customShape(),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Container(
                                child: mProductList.length > 0
                                    ? ListView.builder(
                                        padding: EdgeInsets.all(0),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: mProductList.length,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (context, int index) {
                                          ShoppingCartModel item =
                                              mProductList[index];
                                          return ItemShoppingCart(
                                            key: UniqueKey(),
                                            itemShopingCart: item,
                                            notifyParent: refresh,
                                            delItem: deleteItemFromList,
                                            itemIndex: index,
                                          );
                                        },
                                      )
                                    : Container(),
                                // FutureBuilder(
                                //   initialData: null,
                                //   future: _productList,
                                //   builder: (BuildContext context,
                                //       AsyncSnapshot snapshot) {
                                //     if (snapshot.hasData) {
                                //       mProductList = snapshot.data;
                                //       return ListView.builder(
                                //         padding: EdgeInsets.all(0),
                                //         shrinkWrap: true,
                                //         physics: NeverScrollableScrollPhysics(),
                                //         itemCount: mProductList.length,
                                //         scrollDirection: Axis.vertical,
                                //         itemBuilder: (context, int index) {
                                //           ShoppingCartModel item =
                                //               mProductList[index];
                                //           return ItemShoppingCart(
                                //             itemShopingCart: item,
                                //             notifyParent: refresh,
                                //             delItem: deleteItemFromList,
                                //             itemIndex: index,
                                //           );
                                //         },
                                //       );
                                //     } else {
                                //       return Container();
                                //     }
                                //   },
                                // ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 1,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Offers",
                                      style: TextStyle(
                                        color: Color(0XFF232323),
                                        fontSize: 22,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            // Icon(Icons.close,color: Colors.red,),
                                            // Image.asset(
                                            //   "images/cross1.png",
                                            //   fit: BoxFit.contain,
                                            // ),
                                            Text(
                                              "Select a promo code",
                                              style: TextStyle(
                                                color: Color(0XFF232323),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _applyPromo();
                                              },
                                              child: Text(
                                                // _offers,
                                                "View offers",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0XFFD20014),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 1,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Sub total",
                                      style: TextStyle(
                                        color: Color(0XFF232323),
                                        fontSize: 22,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "\u20B9",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0XFFD20014),
                                          ),
                                        ),
                                        Text(
                                          "$_subTotalPrice",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0XFFD20014),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Shipping",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.shoppingCartDesctext,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "\u20B9",
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            // color: Color(0XFFD20014),
                                          ),
                                        ),
                                        Text(
                                          " $shippingCharge",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                AppColors.shoppingCartDesctext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tax",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.shoppingCartDesctext,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "\u20B9",
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            // color: Color(0XFFD20014),
                                          ),
                                        ),
                                        Text(
                                          " $taxAmount",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                AppColors.shoppingCartDesctext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: promoAmount == 0 ? 0 : 10,
                              ),
                              // totalAmount <= 1000
                              promoAmount == 0
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: isApply == true
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${promoApplied} is applied",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors
                                                        .shoppingCartDesctext,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "\u20B9",
                                                      style: TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        // color: Color(0XFFD20014),
                                                      ),
                                                    ),
                                                    Text(
                                                      " -$promoAmount",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .shoppingCartDesctext,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ),
                              SizedBox(
                                height: 0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "You saved",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.shoppingCartDesctext,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "\u20B9",
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            // color: Color(0XFFD20014),
                                          ),
                                        ),
                                        Text(
                                          " $savedAmount",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                AppColors.shoppingCartDesctext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.shoppingCartDesctext,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "\u20B9",
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            // color: Color(0XFFD20014),
                                          ),
                                        ),
                                        Text(
                                          " $totalAmount",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                AppColors.shoppingCartDesctext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                  ),
                                  child: Center(
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CheckoutScreen(
                                                cartQuantity:
                                                    int.parse(quentity),
                                                couponId: couponId,
                                                shippingCost: shippingCharge,
                                                tax: taxAmount,
                                                totalAmpount: totalAmount,
                                                subTotalAmpount: _subTotalPrice,
                                                couponAmount: promoAmount,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Checkout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(9),
                                    ),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CategorytListScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Continue Shopping',
                                          style: TextStyle(
                                            color: Color(0XFF050505),
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
        ),
      ),
    );
  }

  Widget CustomAppbar() {
    return AppBar(
      centerTitle: true,
      leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, "refresh cart");
            // Navigator.pop(context);
          }),
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
                          builder: (context) => ProductListScreen(
                            categoryID: "",
                            searchKeyword: _searchKey,
                          ),
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
      actions: <Widget>[
        // IconButton(
        //   icon: Icon(
        //     Icons.search,
        //     color: Colors.white,
        //     size: 35,
        //   ),
        //   onPressed: () {
        //     setState(() {
        //       openSearch = !openSearch;
        //     });
        //   },
        // )
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
                "Shopping Cart",
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
                Variables.itemCount == null
                    ? "0 Items"
                    : "${Variables.itemCount} Items",
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

  refresh() async {
    setState(() {});
    debugPrint("refresh called");
    // _applyPromo();
    _handleFetchCart();
  }

  deleteItemFromList(int index, String rowID) async {
    debugPrint("deletedd $index called ${mProductList[index].name}");

    // mProductList.removeAt(index);
    //
    // setState(() {
    //   setState(() {
    //     mProductList = List.from(mProductList)..removeAt(index);
    //   });
    // });
    debugPrint("_handleFetchCart called");
    setState(() {});
    _handleFetchCart();
  }

  _applyPromo() async {
    setState(() {
      totalAmount = totalAmountWithoutDiscount;
    });
    var result = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => ApplyPromoScreen(
          totalAmount: totalAmount,
        ),
        fullscreenDialog: true,
      ),
    );

    debugPrint("Returned data $result");
    debugPrint("Returned data $totalAmount");
    if (totalAmount > 999.00) {
      setState(() {
        discountType = result['discount_type'];
        if (discountType == "PromoCode") {
          promoAmount = result['discount'];
          promoDisAmount = result['discount'];
        } else {
          promoAmount = result['discount'];
          promoDisAmount = result['discount'];
          promoAmount = ((totalAmount * promoAmount) / 100);
        }
        promoApplied = result['promo_code'];
        couponId = result['promo_code_id'];
        paymentMethod = result['payment_method'];
        totalAmount = totalAmount - promoAmount;
      });
    } else {}
  }
}
