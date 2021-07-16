import '../offer/PaymentGatewayModel.dart';
import 'package:flutter/material.dart';

class ItemPaymentOffer extends StatefulWidget {
  final PaymentGatewayModel paymentGatewayModel;

  const ItemPaymentOffer({Key key, this.paymentGatewayModel}) : super(key: key);
  @override
  _ItemPaymentOfferState createState() => _ItemPaymentOfferState();
}

class _ItemPaymentOfferState extends State<ItemPaymentOffer> {
  PaymentGatewayModel item;
  @override
  void initState() {
    // TODO: implement initState
    item = widget.paymentGatewayModel;
    super.initState();
  }

  void _applyPaymentGatewayOffer(String discountType, String paymentGatewayName,
      String promoCodeID, double couponAmount) {
    var promoData = {};
    promoData['discount'] = couponAmount;
    promoData['promo_code'] = paymentGatewayName;
    promoData['promo_code_id'] = int.parse(promoCodeID);
    promoData['discount_type'] = discountType;
    if (paymentGatewayName == "Paytm" || paymentGatewayName == "RazorPay") {
      promoData['payment_method'] = paymentGatewayName;
    } else {
      promoData['payment_method'] = "COD";
    }
    Navigator.pop(context, promoData);
  }

  @override
  Widget build(BuildContext context) {
    return item.paymentGatewayName == "Paytm" ||
            item.paymentGatewayName == "RazorPay"
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Make payment through",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Image.asset(
                                item.paymentGatewayName == "Paytm"
                                    ? "images/paytm_logo.png"
                                    : "images/razor_logo.png",
                                width: 80,
                              ),
                            ],
                          ),
                          Text(
                            "Get flat ${item.offer} % off",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _applyPaymentGatewayOffer(
                            "PaymentGateway",
                            item.paymentGatewayName,
                            item.id,
                            double.parse(item.offer));
                      },
                      child: Text(
                        "Apply",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 0.4,
                  color: Colors.grey,
                )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.paymentGatewayName}",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Get flat ${item.offer} %  off",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _applyPaymentGatewayOffer(
                            "PaymentGateway",
                            item.paymentGatewayName,
                            item.id,
                            double.parse(item.offer));
                      },
                      child: Text(
                        "Apply",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 0.4,
                  color: Colors.grey,
                )
              ],
            ),
          );
  }
}
