import '../shopping_cart/ShoppingCartScreen.dart';
import '../util/Util.dart';

import '../util/Consts.dart';
import 'package:flutter/material.dart';
import '../util/AppColors.dart';
import 'ShoppingCartModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemShoppingCart extends StatefulWidget {
  final ShoppingCartModel itemShopingCart;
  final Function() notifyParent;
  final Function(int index, String rowId) delItem;
  final int itemIndex;

  const ItemShoppingCart(
      {Key key,
      this.itemShopingCart,
      this.notifyParent,
      this.delItem,
      this.itemIndex})
      : super(key: key);
  @override
  _ItemShoppingCartState createState() => _ItemShoppingCartState();
}

class _ItemShoppingCartState extends State<ItemShoppingCart> {
  ShoppingCartModel item;
  int _itemCount;
  double _productTotal;
  double _productRegularTotal;
  int rowId;
  var strImageURL =
      "https://cdn.britannica.com/17/196817-050-6A15DAC3/vegetables.jpg";
  bool _callingUpdateApi;

  @override
  void initState() {
    // TODO: implement initState
    _callingUpdateApi = false;
    item = widget.itemShopingCart;
    _itemCount = int.parse(item.qty);
    _productTotal = (double.parse(item.price) * int.parse(item.qty));
    _productRegularTotal =
        (double.parse(item.regularPrice) * int.parse(item.qty));
    rowId = int.parse(item.row_id);
  }

  _updateCart(String productId, int quantity) async {
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
      setState(() {
        _callingUpdateApi = false;
      });
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      if (serverCode == "200") {
        widget.notifyParent();
      }

      var serverMessage = responseData['message'];
      showCustomToast(serverMessage);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              bottom: 15.0,
              top: 5,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 10,
                ),
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      item.product_image,
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
                  width: 20,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "${item.name} ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0XFF0D0D0D),
                                ),
                                softWrap: true,
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: IconButton(
                                onPressed: () {
                                  _handleRemove(widget.itemShopingCart.row_id,
                                      widget.itemIndex);
                                },
                                icon: Image.asset("images/ic_remove_cart.png"),
                                iconSize: 15,
                                color: Color(0XFF747474),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        !_callingUpdateApi
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "\u20B9",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0XFFD20014),
                                            ),
                                          ),
                                          Text(
                                            "$_productTotal",
                                            // item.price,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0XFFD20014),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "\u20B9 ${_productRegularTotal}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.productRegularColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            child: IconButton(
                                              icon: Image.asset(
                                                  'images/ic_minus.png'),
                                              onPressed: () {
                                                DcrBtn();
                                              },
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              _itemCount.toString(),
                                              style: TextStyle(
                                                color:
                                                    AppColors.categoryTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 50,
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
                                    ],
                                  ),
                                ],
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  IncrBtn() {
    setState(() {
      _itemCount++;
      _productTotal = (double.parse(item.price) * _itemCount);
      _updateCart(item.product_id, _itemCount);
    });
  }

  DcrBtn() {
    setState(() {
      _itemCount <= 1 ? _itemCount = 1 : _itemCount--;
      _productTotal = (double.parse(item.price) * _itemCount);
      _updateCart(item.product_id, _itemCount);
    });
  }
  // Widget customerView(){

  // }

  _handleRemove(String rowId, int index) async {
    var requestParam = "?";
    requestParam += "row_id=" + rowId;
    final http.Response response = await http.get(
      Uri.parse(Consts.DELETE_CART + requestParam),
    );
    if (response.statusCode == 200) {
      setState(() {
        _callingUpdateApi = false;
      });
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      if (serverCode == "200") {
        debugPrint("delete $index");
        widget.delItem(widget.itemIndex, rowId);
      }

      var serverMessage = responseData['message'];
      showCustomToast(serverMessage);
    } else {}
  }
}
