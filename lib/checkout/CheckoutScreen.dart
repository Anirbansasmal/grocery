import 'dart:convert';

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

class CheckoutScreen extends StatefulWidget {
  final String DiscountType;
  final String paymentMethod;
  final int cartQuantity;
  final int couponId;
  final double shippingCost;
  final double tax;
  final double totalAmpount;
  final double subTotalAmpount;
  final double couponAmount;

  const CheckoutScreen({
    Key key,
    this.cartQuantity,
    this.couponId,
    this.shippingCost,
    this.tax,
    this.totalAmpount,
    this.subTotalAmpount,
    this.couponAmount,
    this.DiscountType,
    this.paymentMethod,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isOrderPlaced;
  List<AddressModel> _mAddressList;
  Future<List<AddressModel>> _addressList;
  AddressModel defaultAddress;

  String selectedAddress;
  String selectedPaymmentMethod;
  String paymentStatus;
  bool isPaid;
  String addressId;

  int couponId;
  double taxAmount;
  double shippingCost;
  double totalAmpount;
  double subTotalAmpount;
  double couponAmount;

  bool isAgent;
  double creditLimit;
  bool isAdressApiCalling;

  @override
  void initState() {
    isOrderPlaced = false;
    isAdressApiCalling = false;
    selectedAddress = " Azhar, Sdf building";
    selectedPaymmentMethod = "COD";
    paymentStatus = "Unpaid";

    // _addressList = _getAddress();
    isPaid = true;
    addressId = "";
    defaultAddress = new AddressModel();

    couponId = widget.couponId;
    taxAmount = widget.tax;
    shippingCost = widget.shippingCost;
    totalAmpount = widget.totalAmpount;
    subTotalAmpount = widget.subTotalAmpount;
    couponAmount = widget.couponAmount;

    isAgent = false;
    creditLimit = 0.0;
    _mAddressList = [];
    _getAddress();

    getAgentCredit();
    // TODO: implement initState
    super.initState();

  }

  //===========
  void getAgentCredit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var userType = prefs.getString('usertype');
    setState(() {
      if (userType == "DI") {
        isAgent = true;
      }
    });

    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    final http.Response response = await http.get(
      Uri.parse(Consts.GET_CREDIT_LIMIT + requestParam),
    );
    print(Consts.GET_CREDIT_LIMIT + requestParam);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      if (serverStatus == "success") {
        var crdLimit = responseData['credit_limit'];
        if (double.parse(crdLimit) > 0) {
          setState(() {
            creditLimit = double.parse(crdLimit);
          });
        }
      }
    }
  }

  // ==============
  _changePaymentMethod(String paymentMethod) {
    setState(() {
      selectedPaymmentMethod = paymentMethod;
      if (selectedPaymmentMethod == "COD") {
        isPaid = true;
      } else if (selectedPaymmentMethod == "Credit") {
        if (creditLimit > totalAmpount) {
          isPaid = true;
        } else {
          isPaid = false;
        }
      } else {
        isPaid = false;
      }
    });
  }

  /*Future<List<AddressModel>> _getAddress() async {
    double totalPrice = 0;
    List<AddressModel> mList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    final http.Response response = await http.get(
      Uri.parse(Consts.USER_ADDRESSES_LIST + requestParam),
    );
    print(Consts.USER_ADDRESSES_LIST + requestParam);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['status'];
      var arrAddress = responseData["userdata"];
      print(responseData);
      if (responseData['status'] == "success") {
        if (arrAddress.length > 0) {
          for (int i = 0; i < arrAddress.length; i++) {
            var itemData = arrAddress[i];
            print(itemData);
            if (itemData['default_billing'] == "1") {
              AddressModel item = AddressModel();
              // var productDetails =itemData['productdata'];
              item.id = itemData['id'];
              setState(() {
                addressId = item.id;
              });
              item.userId = itemData['user_id'];
              item.defaultBilling = itemData['default_billing'];
              item.name = itemData['name'];
              item.phone = itemData['phone'];
              item.pincode = itemData['pincode'];
              item.flatHouseFloorBuilding =
                  itemData['flat_house_floor_building'];
              item.locality = itemData['locality'];
              item.landmark = itemData['landmark'];
              item.city = itemData['city'];
              item.state = itemData['state'];
              item.country = itemData['country'];
              item.country = itemData['country'];
              item.addressType = itemData['address_type'];
              setState(() {
                defaultAddress = item;
              });
              mList.add(item);
            }
          }
        }
      } else {
        showCustomToast(serverMessage);
        return null;
      }
    } else {
      showCustomToast("Something went wrong.\nPlease try again.");
      return null;
    }
    debugPrint("Address Size ${mList.length}");
    return mList;
  }*/

  _getAddress() async {

    setState(() {
      isAdressApiCalling = true;
      _mAddressList = [];
    });
    double totalPrice = 0;
    List<AddressModel> mList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    final http.Response response = await http.get(
      Uri.parse(Consts.USER_ADDRESSES_LIST + requestParam),
    );
    print(Consts.USER_ADDRESSES_LIST + requestParam);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var arrAddress = responseData["userdata"];
      print(responseData);
      if (responseData['status'] == "success") {
        if (arrAddress.length > 0) {
          for (int i = 0; i < arrAddress.length; i++) {
            var itemData = arrAddress[i];
            print(itemData);
            if (itemData['default_billing'] == "1") {
              AddressModel item = AddressModel();
              // var productDetails =itemData['productdata'];
              item.id = itemData['id'];
              setState(() {
                addressId = item.id;
              });
              item.userId = itemData['user_id'];
              item.defaultBilling = itemData['default_billing'];
              item.name = itemData['name'];
              item.phone = itemData['phone'];
              item.pincode = itemData['pincode'];
              item.flatHouseFloorBuilding =
                  itemData['flat_house_floor_building'];
              item.locality = itemData['locality'];
              item.landmark = itemData['landmark'];
              item.city = itemData['city'];
              item.state = itemData['state'];
              item.country = itemData['country'];
              item.country = itemData['country'];
              item.addressType = itemData['address_type'];
              setState(() {
                defaultAddress = item;
              });
              mList.add(item);
            }
          }
        }
      } else {
        showCustomToast(serverMessage);

      }
    } else {
      showCustomToast("Something went wrong.\nPlease try again.");

    }
    debugPrint("Address Size ${mList.length}");
    setState(() {
      _mAddressList = mList;
      isAdressApiCalling = false;
    });
  }

  _addAdress() async {
    var newAddress = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => AddAdressScreen(
            previousScreen: "checkout",
          ),
          fullscreenDialog: true,
        ));

    // debugPrint("Returned data ${newAddress['id']} ${newAddress['address']}");
    if (newAddress != null) {
      debugPrint("Returned data2 ${newAddress}");
      _getAddress();
      // setState(() {
      //   selectedAddress = newAddress['address'];
      // });
    }
  }

  _showSuccessDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog(
          barrierDismissible: false,
          context: context,
          useSafeArea: true,
          builder: (BuildContext context) {
            return Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: Colors.white,
              ),
              child: AlertDialog(
                title: null,
                content: StatefulBuilder(
                  // You need this, notice the parameters below:
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Icon(
                          Icons.check_circle,
                          size: 60,
                          color: AppColors.appMainColor,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "You can track your order from the "+"My Order""+ section.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
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
                                          CategorytListScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Shop More',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  _placeOrder() async {

    if (selectedPaymmentMethod == "Credit" && creditLimit < totalAmpount) {
      showAlertDialog(context,
          "Your credit limit is less than your order total.\nPlease contact admin for incresing your limit or select another method",
          () {
        Navigator.pop(context);
      });
      return;
    }
    if (!isPaid) {
      showCustomToast("Please select payment method");
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if(defaultAddress.id == null){
      showCustomToast("Please add an address");
      return;
    }
    var addressId = defaultAddress.id;

    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&address_id=" + addressId;
    requestParam += "&total_amount=" + totalAmpount.toString();
    requestParam += "&subtotal_value=" + subTotalAmpount.toString();
    requestParam += "&coupon_amount=" + couponAmount.toString();
    requestParam += "&coupon_id=" + couponId.toString();
    requestParam += "&shipping_cost=" + shippingCost.toString();
    requestParam += "&payment_status=" + paymentStatus;
    requestParam += "&payment_type=" + selectedPaymmentMethod;
    requestParam += "&payment_method=" + selectedPaymmentMethod;
    setState(() {
      isOrderPlaced = true;
    });

    debugPrint(Consts.placeOrder + requestParam);
    final http.Response response = await http.get(
      Uri.parse(Consts.placeOrder + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      if (serverStatus == "success") {
        _showSuccessDialog(serverMessage);
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }
    setState(() {
      isOrderPlaced = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              children: [
                customShape(),
                SizedBox(
                  height: 20,
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Address",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.checkoutDeliveryHeadingColor,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _addAdress();
                              },
                              child: Icon(
                                Icons.add,
                                size: 30,
                                color: AppColors.checkoutAddDeleiverColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        /*FutureBuilder(
                          initialData: null,
                          future: _addressList,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              _mAddressList = snapshot.data;
                              return _mAddressList.length <= 0
                                  ? Container()
                                  : Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors
                                              .checkoutAddDeleiverColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 15.0,
                                          right: 15.0,
                                          top: 15.0,
                                          bottom: 15.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    "${defaultAddress.flatHouseFloorBuilding} ${defaultAddress.locality} "
                                                    "${defaultAddress.landmark} \n ${defaultAddress.city} - ${defaultAddress.pincode}",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .checkoutAddressColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {},
                                                  child: Container(
                                                    width: 50,
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      size: 25,
                                                      color: defaultAddress
                                                                  .defaultBilling ==
                                                              "1"
                                                          ? AppColors
                                                              .checkoutAddDeleiverColor
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            } else {
                              return Container();
                            }
                          },
                        ),*/
                        isAdressApiCalling ? Center(
                          child: CircularProgressIndicator(),
                        ):Container(),
                        _mAddressList.length <= 0
                            ? Container()
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.checkoutAddDeleiverColor,
                                    width: 0.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 15.0,
                                    bottom: 15.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "${defaultAddress.flatHouseFloorBuilding} ${defaultAddress.locality} "
                                              "${defaultAddress.landmark} \n ${defaultAddress.city} - ${defaultAddress.pincode}",
                                              softWrap: true,
                                              style: TextStyle(
                                                color: AppColors
                                                    .checkoutAddressColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Container(
                                              width: 50,
                                              child: Icon(
                                                Icons.check_circle,
                                                size: 25,
                                                color:
                                                    defaultAddress
                                                                .defaultBilling ==
                                                            "1"
                                                        ? AppColors
                                                            .checkoutAddDeleiverColor
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                _viewAllAdresses();
                              },
                              child: Text(
                                "View all",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Payment Methods",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.checkoutDeliveryHeadingColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _changePaymentMethod("COD");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0XFFF1F1F1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 25,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "COD",
                                        style: TextStyle(
                                          color: AppColors
                                              .checkoutAddDeleiverColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Text(
                                        "(Cash On Delivery)",
                                        style: TextStyle(
                                          color: AppColors
                                              .checkoutDeliveryHeadingColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 50,
                                    child: selectedPaymmentMethod == "COD"
                                        ? Icon(
                                            Icons.check_circle,
                                            size: 25,
                                            color: AppColors
                                                .checkoutAddDeleiverColor,
                                          )
                                        : Icon(
                                            Icons.check_circle,
                                            size: 25,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        isAgent && creditLimit > 0
                            ? InkWell(
                                onTap: () {
                                  _changePaymentMethod("Credit");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0XFFF1F1F1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 25,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Credit",
                                              style: TextStyle(
                                                color: AppColors
                                                    .checkoutAddDeleiverColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                              "(Buy with credit you have ${creditLimit})",
                                              style: TextStyle(
                                                color: AppColors
                                                    .checkoutDeliveryHeadingColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 50,
                                          child:
                                              selectedPaymmentMethod == "Credit"
                                                  ? Icon(
                                                      Icons.check_circle,
                                                      size: 25,
                                                      color: AppColors
                                                          .checkoutAddDeleiverColor,
                                                    )
                                                  : Icon(
                                                      Icons.check_circle,
                                                      size: 25,
                                                      color: Colors.grey,
                                                    ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        /*SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _changePaymentMethod("PAYTM");
                          },
                          child: Container(
                            decoration: BoxDecoration(color: Color(0XFFF1F1F1)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 25,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  new SizedBox(
                                    height: 25.0,
                                    child: Image.asset(
                                      "images/paytm_logo.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    child: selectedPaymmentMethod == "PAYTM"
                                        ? Icon(
                                            Icons.check_circle,
                                            size: 25,
                                            color: AppColors
                                                .checkoutAddDeleiverColor,
                                          )
                                        : Icon(
                                            Icons.check_circle,
                                            size: 25,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _changePaymentMethod("RAZOR");
                          },
                          child: Container(
                            decoration: BoxDecoration(color: Color(0XFFF1F1F1)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 25,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  new SizedBox(
                                    width: 90.0,
                                    child: Image.asset(
                                      "images/razor_logo.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    child: selectedPaymmentMethod == "RAZOR"
                                        ? Icon(
                                            Icons.check_circle,
                                            size: 25,
                                            color: AppColors
                                                .checkoutAddDeleiverColor,
                                          )
                                        : Icon(
                                            Icons.check_circle,
                                            size: 25,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),*/
                        SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(
                                Radius.circular(9),
                              ),
                            ),
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  !isOrderPlaced ? _placeOrder(): showCustomToast("Please wait order is getting placed.");
                                },
                                child: Text(
                                  'Place Order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
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
                "Checkout",
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
                "${widget.cartQuantity} items",
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

  _viewAllAdresses() async {
    var dataReturned = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllAdressScreen(
          mAddressList: _mAddressList,
        ),
      ),
    );

    setState(() {
      defaultAddress = dataReturned;
    });
    _getAddress();

    // print(defaultAddress.flatHouseFloorBuilding);
    // _getAddress();
  }
}
