import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceryapp/product_details/ProductDetails.dart';
import 'package:groceryapp/products/ProductModel.dart';
import 'package:groceryapp/util/AppColors.dart';
import 'package:groceryapp/util/Consts.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/Util.dart';
import 'package:http/http.dart' as http;

class FreshItem extends StatefulWidget {
  final String deviceId;
  final ProductModel itemProduct;
  final bool isAgent;
  final Function() notifyCart;

  const FreshItem({Key key, this.itemProduct, this.isAgent, this.notifyCart, this.deviceId}) : super(key: key);
  @override
  _FreshItemState createState() => _FreshItemState();
}

class _FreshItemState extends State<FreshItem> {
  ProductModel item;
  bool isAgent;
  String deviceId;
  @override
  void initState() {

    // TODO: implement initState
    deviceId = widget.deviceId;
    item = widget.itemProduct;
    isAgent = widget.isAgent !=null ? widget.isAgent : false;
    super.initState();
  }



  _handleAddCart(ProductModel itemProduct) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');

    if (user_id == null) {
      user_id = '';
    }

    print(user_id);

    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&device_id=" + deviceId.toString();
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
        debugPrint(response.body);
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

  void gotoDetails() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(
          itemProduct: item,
          isAgent: isAgent,
          
        ),
      ),
    );

    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data $openCart");
      widget.notifyCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    // var size=MediaQuery.of(context).size.width/2 -50;
    // print(size);
    return InkWell(
      onTap: () {
        gotoDetails();
      },
      child: Container(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Image.network(
                  item.productImage,
                  height: 140.0,
                  width: MediaQuery.of(context).size.width/2 -90,
                  fit: BoxFit.contain,

                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace stackTrace) {
                    return Container();
                  },
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 120.0,
                      width: MediaQuery.of(context).size.width/2 -50,
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
              height: 0,
            ),
            Center(
              child: Text(
                item.productTitle,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  "\u20B9 ${isAgent ? item.productDistributorPrice : item.productPrice}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.productPriceColor,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "\u20B9 ${item.productRegularPrice}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.productRegularColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                    Radius.circular(4.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0,),
                child: InkWell(
                  onTap: () => {
                    gotoDetails()
                  },
                  child: Text(
                    "Buy Now",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
