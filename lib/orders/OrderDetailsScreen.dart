import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryapp/shopping_cart/ShoppingCartScreen.dart';
import 'package:groceryapp/util/AppColors.dart';
import 'package:groceryapp/util/Consts.dart';
import 'package:groceryapp/util/Util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'MyOrderModel.dart';
import 'OrderDetailsModel.dart';

class OrderDetailsScreen extends StatefulWidget {
  final MyOrderModel mItem;

  const OrderDetailsScreen({Key key, this.mItem}) : super(key: key);
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  MyOrderModel myOrderModel;
  Color mColor;
  String orderAddress = "";
  List<Widget> orderedProductsWidget = <Widget>[];

  double delieveryCharge;

  bool showLoader;

  @override
  void initState() {
    myOrderModel = widget.mItem;
    showLoader = false;

    delieveryCharge = double.parse(myOrderModel.orderTotalValue) -
        double.parse(myOrderModel.orderSubtotalValue);

    mColor = myOrderModel.orderStatus == "1"
        ? AppColors.orderProcessing
        : myOrderModel.orderStatus == "3"
            ? AppColors.orderCompleted
            : myOrderModel.orderStatus == "4"
                ? AppColors.orderCancelled
                : myOrderModel.orderStatus == "2"
                    ? AppColors.orderPending
                    : AppColors.orderCompleted;

    orderAddress += myOrderModel.billingFlatHouseFloorBuilding;
    orderAddress += " " + myOrderModel.billingLocality;
    orderAddress += " " + myOrderModel.billingLandmark;
    orderAddress += " " + myOrderModel.billingCity;
    orderAddress += " - " + myOrderModel.billingPincode;

    for (var i = 0; i < myOrderModel.orderDetails.length; i++) {
      bool addPadding = true;
      if(i == myOrderModel.orderDetails.length - 1){
        addPadding = false;
      }
      orderedProductsWidget.add(Container(
        child: orderItemsDetails(myOrderModel.orderDetails[i], addPadding),
      ));
    }

    super.initState();
  }

  //=== re order
  void _reOrderItems() async {
    setState(() {
      showLoader = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?user_id=" + user_id;
    requestParam += "&order_id=" + myOrderModel.orderId;
    final http.Response response = await http.get(
      Uri.parse(Consts.REORDER + requestParam),
    );
    print(Consts.REORDER + requestParam);
    if (response.statusCode == 200) {
      setState(() {
        showLoader = false;
      });
      print(response.body);
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      if (serverStatus == "success") {
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => ShoppingCartScreen(),
          ),
        );
      }
      showCustomToast(serverMessage);
    } else {
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
        title: Text(
          "Order Details",
          style: TextStyle(
            fontFamily: "Philosopher",
            fontSize: 26,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "#${myOrderModel.orderUniqueId}",
                                      style: TextStyle(
                                        color: AppColors.orderDetailHeading,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 5.0,
                                      ),
                                      child: Text(
                                        "${myOrderModel.orderDateStr}",
                                        style: TextStyle(
                                          color: AppColors.orderDetailHeading,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${myOrderModel.orderStatusText}",
                                  style: TextStyle(
                                    color: mColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Address",
                              style: TextStyle(
                                color: AppColors.orderDetailText,
                                fontSize: 14,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,

                              ),
                              child: Text(
                                "$orderAddress",
                                style: TextStyle(
                                  color: AppColors.orderDetailHeading,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            //Payment Method
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Payment Method",
                              style: TextStyle(
                                color: AppColors.orderDetailHeading,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                "${myOrderModel.paymentMethod}",
                                style: TextStyle(
                                  color: AppColors.orderDetailHeading,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Container(
                                height: 1,
                                color: Color(0XFFEBEBEB),
                              ),
                            ),
                            //=======  Order Items =========

                            Column(
                              children: orderedProductsWidget,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Container(
                                height: 1,
                                color: Color(0XFFEBEBEB),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Item total",
                                      style: TextStyle(
                                        color: AppColors.orderDetailHeading,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "\u20B9 ${myOrderModel.orderSubtotalValue}",
                                  style: TextStyle(
                                    color: AppColors.orderDetailHeading,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Delivery Charge",
                                      style: TextStyle(
                                        color: AppColors.orderDetailHeading,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "\u20B9 $delieveryCharge",
                                  style: TextStyle(
                                    color: AppColors.orderDetailHeading,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Amount",
                                      style: TextStyle(
                                        color: AppColors.orderDetailHeading,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Rs ${myOrderModel.orderTotalValue}",
                                  style: TextStyle(
                                    color: AppColors.orderDetailHeading,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 9.0,
                              ),
                              child: Container(
                                height: 1,
                                color: Color(0XFFEBEBEB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _reOrderItems();
                    },
                    child: Container(
                      height: 70,
                      color: AppColors.appMainColor,
                      child: Center(
                        child: Text(
                          "Reorder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            showLoader
                ? Container(
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget orderItemsDetails(OrderDetailsModel orderDetailsModel, bool addPadding) {
    var qty = double.parse(orderDetailsModel.quantity);
    var price = double.parse(orderDetailsModel.price);
    var totalPtice = qty * price;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  orderDetailsModel.productImage,
                  height: 50.0,
                  width: 50.0,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace stackTrace) {
                    return Container();
                  },
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 50.0,
                      width: 50.0,
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes !=
                                null
                                ? loadingProgress.cumulativeBytesLoaded /
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
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "${orderDetailsModel.productTitle}",
                      style: TextStyle(
                        color: AppColors.orderTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "\u20B9 ${orderDetailsModel.price} X ${orderDetailsModel.quantity}",
                    style: TextStyle(
                      color: AppColors.orderTextColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text("\u20B9 ${totalPtice}"),
          ],
        ),

        addPadding ? SizedBox(
          height: 10,
        ):Container(),
      ],
    );
  }
}
