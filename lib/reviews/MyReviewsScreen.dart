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

class MyReviewsScreen extends StatefulWidget {


  const MyReviewsScreen({Key key,}) : super(key: key);
  @override
  _MyReviewsScreenState createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {

  String _offers;
  bool hasItemsInCart;
  bool isApiCalled;

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
  double _subTotalPrice;
  @override
  void initState() {
    // TODO: implement initState
    _offers = "Test";
    hasItemsInCart = false;
    _searchKey = "";
    openSearch = false;
    mProductList = [];
    _productList = _getReviews();
    _subTotalPrice = 0;
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('user_id');

    var requestParam = "?";
    requestParam += "user_id=" + userID;
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
                        Stack(
                          children: [
                            customShape(),

                            Container(
                              alignment: Alignment.topCenter,
                              padding: new EdgeInsets.only(
                                top: Consts.shapeHeight * .35,
                                right: 20.0,
                                left: 20.0,
                              ),
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
                                                padding: const EdgeInsets.only(top:12,),
                                                child: ItemReview(
                                                  itemReview: item,
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                        }
                                        return isApiCalled ? Center(
                                            child: CircularProgressIndicator(),
                                          ):Container();
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
                "My Reviews",
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
