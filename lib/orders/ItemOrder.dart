import 'dart:convert';

import 'OrderDetailsScreen.dart';
import 'package:groceryapp/shopping_cart/ShoppingCartScreen.dart';
import 'package:groceryapp/util/Consts.dart';
import 'package:groceryapp/util/Util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MyOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/AppColors.dart';
import 'OrderDetailsModel.dart';

class ItemOrder extends StatefulWidget {
  final int index;
  final MyOrderModel myOrderModel;
  final String orderId;

  const ItemOrder({
    Key key,
    this.index,
    this.myOrderModel, this.orderId,
  }) : super(key: key);

  @override
  _ItemOrderState createState() => _ItemOrderState();
}

class _ItemOrderState extends State<ItemOrder> {
  Color mColor;
  double deliveryCharge;
  double serviceCharge;
  double toatalAmount;

  MyOrderModel myOrderModel;
  String dateTime;
  bool showDetails;

  List<Widget> orderedProductsWidget = <Widget>[];
  var amonutTextStyle = TextStyle(
    color: AppColors.orderTextColor,
    fontSize: 16,
  );

  // int itemIndex = widget.index;
  // Color mColor = itemIndex == 0
  //     ? AppColors.orderCompleted
  //     : itemIndex == 1
  //     ? AppColors.orderProcessing
  //     : itemIndex == 2
  //     ? AppColors.orderPending
  //     : itemIndex == 3
  //     ? AppColors.orderCancelled
  //     : AppColors.orderCompleted;



  void _reOrderItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?user_id=" + user_id;
    requestParam += "&order_id=" + widget.myOrderModel.orderId;
    final http.Response response = await http.get(
      Uri.parse(Consts.REORDER + requestParam),
    );
    print(Consts.REORDER + requestParam);
    if(response.statusCode ==200){
      print(response.body);
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      if(serverStatus == "success"){
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => ShoppingCartScreen(

            ),

          ),
        );
      }
      showCustomToast(serverMessage);
    }
    else{
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }
  }


  @override
  void initState() {
    // TODO: implement initState

    deliveryCharge = 40;
    serviceCharge = 45;
    toatalAmount = double.parse(widget.myOrderModel.orderSubtotalValue) +
        deliveryCharge +
        serviceCharge;

    myOrderModel = widget.myOrderModel;

    showDetails = false;
    if(widget.orderId == myOrderModel.orderId){
      showDetails = true;
    }
    for (var i = 0; i < myOrderModel.orderDetails.length; i++) {
      orderedProductsWidget.add(Container(
        height: 50,
        child: orderItemsDetails(myOrderModel.orderDetails[i]),
      ));
    }

    mColor = myOrderModel.orderStatus == "1"
        ? AppColors.orderProcessing
        : myOrderModel.orderStatus == "3"
            ? AppColors.orderCompleted
            : myOrderModel.orderStatus == "4"
                ? AppColors.orderCancelled
                : myOrderModel.orderStatus == "2"
                    ? AppColors.orderPending
                    : AppColors.orderCompleted;

    super.initState();
  }

  bool _showDetailWidget() {
    setState(() {
      showDetails = !showDetails;
    });
    return showDetails;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              top: 15,
              bottom: 8,
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                        // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              "Order Date : ",
                              style: TextStyle(
                                color: AppColors.orderLabelText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${myOrderModel.orderDateStr}",
                              style: TextStyle(
                                color: AppColors.orderLabelText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order ID : ",
                              style: TextStyle(
                                color: AppColors.orderLabelText,
                                fontSize: 14,
                              ),
                            ),

                            Text(
                              "#${myOrderModel.orderUniqueId}",
                              style: TextStyle(
                                color: AppColors.orderTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order Amount : ",
                              style: TextStyle(
                                color: AppColors.orderLabelText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "\u20B9 ${myOrderModel.orderTotalValue}",
                              style: TextStyle(
                                color: AppColors.orderTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Status : ",
                              style: TextStyle(
                                color: AppColors.orderLabelText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              myOrderModel.orderStatusText,
                              style: TextStyle(
                                color: mColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 25,
                        ),
                        Row(

                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                                border: Border.all(
                                  color: AppColors.orderBoxBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0,
                                  ),
                                  child: TextButton(
                                    onPressed: (){
                                      // _showDetailWidget();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderDetailsScreen(
                                            mItem: myOrderModel,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Order',
                                      style: TextStyle(
                                        color: AppColors.orderButtonText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                                border: Border.all(
                                  color: AppColors.orderBoxBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextButton(
                                    onPressed: () {
                                      _reOrderItems();
                                    },
                                    child: Text(
                                      'Re Order',
                                      style: TextStyle(
                                        color: AppColors.orderButtonText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                showDetails
                    ? Container(
                        color: AppColors.orderDetailsBG,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 25,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    children: orderedProductsWidget,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Sub Total"),
                                          SizedBox(
                                            width: 50,
                                          ),
                                          Text(
                                            "\u20B9 ${myOrderModel.orderSubtotalValue}",
                                            style: amonutTextStyle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Service chanrge (4%)"),
                                          SizedBox(
                                            width: 50,
                                          ),
                                          Text(
                                            "\u20B9 +${serviceCharge}",
                                            style: amonutTextStyle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Delivery chanrges"),
                                          SizedBox(
                                            width: 50,
                                          ),
                                          Text(
                                            "\u20B9 +${deliveryCharge}",
                                            style: amonutTextStyle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 25,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${myOrderModel.paymentMethod}",
                                    style: TextStyle(
                                      color: AppColors.orderDetailsPaidWith,
                                    ),
                                  ),
                                  Text(
                                    "\u20B9 ${toatalAmount}",
                                    style: TextStyle(
                                      color: AppColors.orderTextColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.check_circle,
              color: mColor,
              size: 35,
            ),
          )
        ],
      ),
    );
  }

  Widget orderItemsDetails(OrderDetailsModel orderDetailsModel) {
    var qty = double.parse(orderDetailsModel.quantity);
    var price = double.parse(orderDetailsModel.price);
    var totalPtice = qty * price;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${orderDetailsModel.productTitle} (${orderDetailsModel.quantity})",
          style: TextStyle(
            color: AppColors.orderTextColor,
            fontSize: 18,
          ),
        ),
        Text("\u20B9 ${totalPtice}"),
      ],
    );
  }
}
