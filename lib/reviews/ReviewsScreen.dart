import 'dart:convert';

import 'package:groceryapp/util/Util.dart';

import '../offer/ApplyPromoScreen.dart';
import '../reviews/ItemReviews.dart';
import '../reviews/PostReviewScreen.dart';
import '../reviews/ReviewModel.dart';
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
import 'package:groceryapp/search/SearchModel.dart';
class ReviewScreen extends StatefulWidget {
  final String productId;
  final String productTitle;
  final Productdata productdata;
  final bool isUserLoggedIn;

  const ReviewScreen({Key key, this.productId,this.productdata,this.productTitle, this.isUserLoggedIn}) : super(key: key);
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ProductModel itemProduct;
  String _offers;
  bool hasItemsInCart;
  bool isApiCalled;
String productId;
String productTitle;
  Future<List<ReviewsModel>> _productList;
  List<ReviewsModel> mProductList;

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
  bool isUserLoggedIn;

  @override
  void initState() {
    // TODO: implement initState
    isUserLoggedIn = widget.isUserLoggedIn !=null ? widget.isUserLoggedIn : false;
    productId = widget.productId;
    productTitle=widget.productTitle;
    _offers = "Test";
    hasItemsInCart = false;
    _searchKey = "";
    openSearch = false;
    mProductList = [];
    _productList = _getReviews();
    isApiCalled = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<ReviewsModel>> _getReviews() async {
    setState(() {
      isApiCalled = true;
    });
    List<ReviewsModel> mList = [];

    var requestParam = "?";
    requestParam += "product_id=" + productId;
    final http.Response response = await http.get(
      Uri.parse(Consts.GET_REVIEWS + requestParam),
    );
    print(Consts.GET_REVIEWS + requestParam);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['status'];
      var reviews = responseData["reviews"];
      print(responseData);
      if (responseData['status'] == "success") {
        // print(mList);
        if (reviews.length > 0) {
          for (int i = 0; i < reviews.length; i++) {
            // List<String> galleryImages =[];
            var itemData = reviews[i];
            print(itemData);
            ReviewsModel item = ReviewsModel();
            // var productDetails =itemData['productdata'];
            item.name = itemData['name'];
            item.reviewId = itemData['review_id'];
            item.productId = itemData['product_id'];
            item.productTitle = itemData['product_title'];
            item.firstname = itemData['firstname'];
            item.lastname = itemData['lastname'];
            item.message = itemData['message'];
            item.reviewDateStr = itemData['review_date_str'];
            mList.add(item);
          }
        }
      }
      else {
        showCustomToast(serverMessage);
      }

      // print(quentity);
    } else {
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }
    setState(() {
      isApiCalled = false;
    });
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
            child: Column(
              children: [
                Expanded(
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
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Container(
                                child: FutureBuilder(
                                  initialData: null,
                                  future: _productList,
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      mProductList = snapshot.data;

                                      debugPrint(
                                          "Reviews length ${mProductList.length} ");

                                      return ListView.builder(
                                        padding: EdgeInsets.all(0),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: mProductList.length,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (context, int index) {
                                          ReviewsModel item =
                                              mProductList[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6,),
                                            child: ItemReview(
                                              itemReview: item,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return isApiCalled ? Center(
                                        child: CircularProgressIndicator(),
                                      ):Container();
                                    }
                                  },
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
                isUserLoggedIn ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostReviewScreen(
                          productId: productId,
                          productTitle:productTitle,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 70,
                    width: double.infinity,
                    color: Color(0XFFc80718),
                    child: Center(
                      child: Text(
                        "Post Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ):Container(),
              ],
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
      title: Center(
        child: Text(
          "Vedic",
          style: TextStyle(
            fontFamily: "Philosopher",
            fontSize: 36,
          ),
        ),
      ),
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
                "Reviews",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 21,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "${productTitle}",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 18,
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
