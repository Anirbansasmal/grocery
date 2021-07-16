import 'dart:convert';

import 'package:groceryapp/search/Search.dart';

import 'ItemOrder.dart';
import 'MyOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_drawer/Navigation.dart';
import '../products/ProductListScreen.dart';
import '../shapes/screen_clip.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'OrderDetailsModel.dart';

class MyOrdersScreen extends StatefulWidget {
  final String orderID;

  const MyOrdersScreen({Key key, this.orderID}) : super(key: key);
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _showLoder;
  Future<List<MyOrderModel>> _arrMyOrders;
  List<MyOrderModel> _mListOrder;
  final double shapeHeight = 140;
  String _searchKey = "";
  bool openSearch;
  var _searchController = new TextEditingController();

  String userFName;
  String userLName;
  String orderID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchKey = "";
    openSearch = false;
    _showLoder = false;
    _arrMyOrders = _getAllOrders();
    orderID = widget.orderID != null ? widget.orderID : "";
  }

  Future<List<MyOrderModel>> _getAllOrders() async {
    setState(() {
      _showLoder = true;
    });
    List<MyOrderModel> _listOrder = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    final http.Response response = await http.get(
      Uri.parse(Consts.getAllOrders + requestParam),
    );
    debugPrint("${Uri.parse(Consts.getAllOrders + requestParam)}");
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      var arrOrders = responseData["order_data"];

      debugPrint(response.body);

      if (serverStatus == "success") {
        if (arrOrders.length > 0) {
          for (int i = 0; i < arrOrders.length; i++) {
            var itemData = arrOrders[i];
            // print(itemData);
            MyOrderModel item = MyOrderModel();
            // var productDetails =itemData['productdata'];
            item.orderId = itemData['order_id'];
            item.userId = itemData['user_id'];
            item.orderUniqueId = itemData['order_unique_id'];
            item.orderTotalValue = itemData['order_total_value'];
            item.orderSubtotalValue = itemData['order_subtotal_value'];
            item.userDiscount = itemData['user_discount'];
            item.couponDiscount = itemData['coupon_discount'];
            item.couponId = itemData['coupon_id'];
            item.orderDate = itemData['order_date'];
            item.billingName = itemData['billing_name'];
            item.billingEmail = itemData['billing_email'];
            item.billingPhone = itemData['billing_phone'];
            item.billingFlatHouseFloorBuilding =
                itemData['billing_flat_house_floor_building'];
            item.billingLocality = itemData['billing_locality'];
            item.billingLandmark = itemData['billing_landmark'];
            item.billingCity = itemData['billing_city'];
            item.billingPincode = itemData['billing_pincode'];
            item.billingState = itemData['billing_state'];
            item.billingCountry = itemData['billing_country'];
            item.shippingName = itemData['shipping_name'];
            item.shippingPhone = itemData['shipping_phone'];
            item.shippingFlatHouseFloorBuilding =
                itemData['shipping_flat_house_floor_building'];
            item.shippingLocality = itemData['shipping_locality'];
            item.shippingLandmark = itemData['shipping_landmark'];
            item.shippingCity = itemData['shipping_city'];
            item.shippingPincode = itemData['shipping_pincode'];
            item.shippingCountry = itemData['shipping_country'];
            item.shippingCountry = itemData['shipping_country'];
            item.shippingAddressType = itemData['shipping_address_type'];
            item.orderStatus = itemData['order_status'];
            item.orderStatusText = itemData['order_status_text'];
            item.orderCurrencySign = itemData['order_currency_sign'];
            item.orderCurrency = itemData['order_currency'];
            item.orderCurrency = itemData['order_currency'];
            item.paymentStatus = itemData['payment_status'];
            item.paymentType = itemData['payment_type'];
            item.paymentMethod = itemData['payment_method'];
            item.paymentMethod = itemData['payment_method'];
            item.shippingAddressId = itemData['shipping_address_id'];
            item.billingAddressId = itemData['billing_address_id'];
            item.billingAddressId = itemData['billing_address_id'];
            item.orderDateStr = itemData['order_date_str'];
            //
            var arrOrderDetails = itemData['my_order_details'];
            List<OrderDetailsModel> listOrderDetails = [];
            if (arrOrderDetails.length > 0) {
              for (int j = 0; j < arrOrderDetails.length; j++) {
                var itemOrderDetails = arrOrderDetails[j];
                OrderDetailsModel itemDetails = OrderDetailsModel();
                itemDetails.orderDetailId = itemOrderDetails['order_detail_id'];
                itemDetails.orderId = itemOrderDetails['order_id'];
                itemDetails.productId = itemOrderDetails['product_id'];
                itemDetails.quantity = itemOrderDetails['quantity'];
                itemDetails.price = itemOrderDetails['price'];
                itemDetails.productTitle = itemOrderDetails['product_title'];
                itemDetails.productImage = itemOrderDetails['product_image'];

                listOrderDetails.add(itemDetails);
              }
            }
            item.orderDetails = listOrderDetails;

            _listOrder.add(item);
          }
        }

        debugPrint("${_listOrder.length} items");
      } else {
        showCustomToast(serverMessage);

        setState(() {
          _showLoder = false;
        });
        return null;
      }
    } else {
      showCustomToast(Consts.SERVER_NOT_RESPONDING);

      setState(() {
        _showLoder = false;
      });
      return null;
    }
    return _listOrder;
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
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                customShape(),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      FutureBuilder(
                        initialData: null,
                        future: _arrMyOrders,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            _mListOrder = snapshot.data;
                            return ListView.builder(
                              padding: EdgeInsets.all(0),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _mListOrder.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, int index) {
                                MyOrderModel mOrderModel = _mListOrder[index];
                                return ItemOrder(
                                  myOrderModel: mOrderModel,
                                  orderId: orderID,
                                );
                              },
                            );
                          } else {
                            return _showLoder
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Container();
                          }
                        },
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
        )
      ],
    );
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
                "My Orders",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 24,
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
