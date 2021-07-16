import 'dart:convert';

import '../offer/ItemPaymentOffer.dart';
import '../offer/PaymentGatewayModel.dart';
import '../products/ProductListScreen.dart';
import '../shapes/screen_clip.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApplyPromoScreen extends StatefulWidget {
  final double totalAmount;

  ApplyPromoScreen({
    Key key,
    this.totalAmount,
  }) : super(key: key);
  @override
  _ApplyPromoScreenState createState() => _ApplyPromoScreenState();
}

class _ApplyPromoScreenState extends State<ApplyPromoScreen> {
  Future<List<PaymentGatewayModel>> _paymentGatewayOfferList;
  String promoCode;

  bool openSearch;
  var _searchController = new TextEditingController();
  String _searchKey = "";
  final double shapeHeight = 140;
  var promoData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchKey = "";
    promoCode = "";
    openSearch = false;
    promoData['payment_method'] = "COD";
    promoData['discount'] = 0;
    promoData['promo_code'] = '';
    promoData['promo_code_id'] = 0;

    _paymentGatewayOfferList = _getPaymentOfder();
  }

  Future<List<PaymentGatewayModel>> _getPaymentOfder() async {
    List<PaymentGatewayModel> mList = [];

    final http.Response response = await http.get(
      Uri.parse(Consts.GET_PAYMENT_GATEWAY_OFFER),
    );
    print(Uri.parse(Consts.GET_PAYMENT_GATEWAY_OFFER));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      var arrOffers = responseData["offers"];
      if (serverStatus == "success") {
        if (arrOffers.length > 0) {
          for (int i = 0; i < arrOffers.length; i++) {
            var itemData = arrOffers[i];
            PaymentGatewayModel item = PaymentGatewayModel();
            item.id = itemData['id'];
            item.paymentGatewayName = itemData['payment_gateway_name'];
            item.offer = itemData['offer'];
            mList.add(item);
          }
        }
      } else {
        showCustomToast(serverMessage);
      }
    }
    return mList;
  }

  _validatePromo(String promoCode) async {
    var requestParam = "?";
    requestParam += "code=" + promoCode;
    final http.Response response = await http.get(
      Uri.parse(Consts.VALIDATE_PROMO + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      var couponData = responseData['coupondata'];
      if (serverStatus == "success") {
        var couponAmount = couponData['coupon_amount'];
        var couponId = couponData['coupon_id'];
        debugPrint("couponAmount is $couponAmount");
        setState(
          () {
            promoData['discount'] = double.parse(couponAmount);
            promoData['promo_code'] = promoCode;
            promoData['promo_code_id'] = int.parse(couponId.toString());
            promoData['discount_type'] = "PromoCode";
          },
        );
        Navigator.pop(context, promoData);
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast("Something went wrong");
      debugPrint(
          "Error while connecting to server. Error code is ${response.statusCode} and error message is  ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, promoData);
      },
      child: Scaffold(
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
              physics: ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  customShape(),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          color: Colors.white,
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text("Enter Promo code"),
                                Expanded(
                                  child: Container(
                                    child: new TextField(
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Promo Code',
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0XFFFFFF),
                                            // width: 2,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) => {
                                        setState(
                                          () {
                                            promoCode = value;
                                          },
                                        ),
                                      },
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _validatePromo(promoCode);
                                  },
                                  child: Container(
                                    child: Text(
                                      "Apply",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          color: AppColors.offerColor,
                          height: 45,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Available Offers",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(height: 10,),
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              FutureBuilder(
                                initialData: null,
                                future: _paymentGatewayOfferList,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    var _mOfferList = snapshot.data;
                                    return _mOfferList.length <= 0
                                        ? Container()
                                        : ListView.separated(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: _mOfferList.length,
                                            scrollDirection: Axis.vertical,
                                            separatorBuilder:
                                                (context, int index) {
                                              return Divider();
                                            },
                                            itemBuilder: (context, int index) {
                                              PaymentGatewayModel itemOffer =
                                                  _mOfferList[index];
                                              return ItemPaymentOffer(
                                                paymentGatewayModel: itemOffer,
                                              );
                                            },
                                          );
                                  } else {
                                    return Container();
                                  }
                                },
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
                "Offers",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
