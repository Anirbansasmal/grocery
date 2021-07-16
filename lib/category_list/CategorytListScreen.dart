import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groceryapp/orders/MyOrdersScreen.dart';
import 'package:groceryapp/products/ProductModel.dart';
import 'package:groceryapp/shopping_cart/ShoppingCartScreen.dart';
import 'package:groceryapp/util/Variables.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../category_list/CategoryItem.dart';
import '../category_list/CategoryModel.dart';
import '../category_list/FreshItem.dart';
import '../navigation_drawer/Navigation.dart';
import '../products/ProductListScreen.dart';
import '../shapes/ShapeComponent.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'OfferSliderModel.dart';
import '../search/Search.dart';
class CategorytListScreen extends StatefulWidget {
  @override
  _CategorytListScreenState createState() => _CategorytListScreenState();
}

class _CategorytListScreenState extends State<CategorytListScreen> {
  List<String> imgList;
  Future<CategoryModel> _arrCategories;
  String _searchKey = "";
  bool openSearch;
  var _searchController = new TextEditingController();

  final double shapeheight = 170;

  Future<List<ProductModel>> _freshProductList;
  List<OfferSliderModel> _listOfferSlider;
  bool isAgent;
  int quantity;
  String deviceID;

  Future<CategoryModel> _getCategories() async {
    var url = Uri.parse(Consts.CATEGORY_LIST);
    debugPrint("$url");
    var response = await http.get(
      url,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      if (responseData['status'] == "success") {
        return CategoryModel.fromJson(responseData);
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast("Error while conneting to server");
      throw Exception("Error getting response  ${response.statusCode}");
    }
    return null;
  }

  Future<List<ProductModel>> _getFreshProducts() async {
    print("_getFreshProducts");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('user_id');

    if (prefs.get("usertype") != null && prefs.get("usertype") == "DI") {
      setState(() {
        isAgent = true;
      });
    }

    List<ProductModel> mList = [];

    var requestParam = "";

    http.Response response;

    if (userID != null && int.parse(userID) > 0) {
      requestParam += "?user_id=" + userID;
    }

    debugPrint("URl ${Uri.parse(Consts.GET_FRESH_ITEMS + requestParam)}");
    response = await http.get(
      Uri.parse(Consts.GET_FRESH_ITEMS + requestParam),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var productData = responseData['productdata'];
      if (responseData['status'] == "success") {
        if (productData.length > 0) {
          debugPrint("success ${productData.length}");
          for (int i = 0; i < productData.length; i++) {
            List<String> galleryImages = [];
            var itemData = productData[i];
            ProductModel item = ProductModel();
            // var productDetails = itemData['productDetails'];
            debugPrint("success ${productData.length}");
            item.productId = itemData['product_id'];
            item.productType = itemData['product_type'];
            item.productCode = itemData['product_code'];
            item.uniqueKey = itemData['unique_key'];
            item.productTitle = itemData['product_title'];
            item.productDescription = itemData['product_description'];
            item.gstId = itemData['gst_id'];
            item.productPrice = itemData['product_price'];
            item.productRegularPrice = itemData['product_regular_price'];
            item.productDistributorPrice =
                itemData['product_distributor_price'];
            item.productUnit = itemData['product_unit'];
            item.productBatchNo = itemData['product_batch_no'];
            item.productQuantityInfo = itemData['product_quantity_info'];
            item.productImage = itemData['productcatimg'];
            item.stockCount = itemData['stock_count'];
            item.status = itemData['status'];

            item.isInWishList =
                int.parse(itemData['is_in_wishlist'].toString());

            var glImages = itemData['gallery_images'];
            if (glImages.length > 0) {
              for (int gi = 0; gi < glImages.length; gi++) {
                galleryImages.add(glImages[gi]);
              }
            }
            item.galleryImages = galleryImages;

            //Extra data
            item.categoryId = itemData['categoryID'];
            item.categoryName = itemData['category_name'];

            // var brandDetails = itemData['brand_details'];
            item.brandId = itemData['brand_id'];
            item.brandName = itemData['brand_name'];
            item.brandDesc = itemData['brand_description'];

            mList.add(item);
          }
        }
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast("Error while conneting to server");
      throw Exception("Error getting response  ${response.statusCode}");
    }
    debugPrint("mList ${mList.length}");
    return mList;
  }

  void _getOfferSlider() async {
    List<String> mImages = [];
    debugPrint("URl ${Uri.parse(Consts.OFFER_SLIDER)}");
    var response = await http.get(
      Uri.parse(Consts.OFFER_SLIDER),
    );
    if (response.statusCode == 200) {
      debugPrint(response.body);
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var sliderData = responseData['slider_data'];
      if (responseData['status'] == "success") {
        if (sliderData.length > 0) {
          for (int i = 0; i < sliderData.length; i++) {
            var itemData = sliderData[i];
            OfferSliderModel item = OfferSliderModel();
            item.name = itemData['name'];
            item.categoryId = itemData['category_id'];
            item.offerDiscount = itemData['offer_discount'];
            item.offerText = itemData['offer_text'];
            mImages.add(itemData['slider_image']);
            _listOfferSlider.add(item);
          }
        }
        setState(() {
          imgList = mImages;
        });
      } else {}
    }
  }



  _gotoShoppinCartScreen() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingCartScreen(),
      ),
    );
    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data $openCart");
      _handleFetchCart();
      setState(() {});
    }
  }




  //======== Fetch Cart ======
  _handleFetchCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if (user_id == null) {
      return null;
    }
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    print(requestParam);
    final http.Response response = await http.get(
      Uri.parse(Consts.VIEW_CART + requestParam),
    );
    print(Consts.VIEW_CART + requestParam);
    print(response.body);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];
      if (serverCode == "200") {
        var arrCartProducts = responseData["productdata"];
        if (arrCartProducts.length > 0) {

          setState(() {
            quantity = Variables.itemCount;

          });
          Variables.itemCount = arrCartProducts.length;
        }
      } else {
        print("Else part");
        setState(() {
          quantity = 0;

        });
        Variables.itemCount = 0;

      }

    }
  }

  void _updateCart(){
    debugPrint("Update cart");
    _handleFetchCart();
  }

  //======== Firebase ======
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }
    debugPrint("Device id ${deviceId}");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      deviceID = deviceId;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    deviceID = '';

    initPlatformState();
    quantity = 0;
    _handleFetchCart();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {

        Map data = message.data;
        print(data['notification_type']);
        if(data['notification_type'] == "Order"){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyOrdersScreen(
              ),
            ),
          );
        }
      }
    });


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                "CHANNEL_ID",
                "CHANNEL_NAME",
                "CHANNEL_DESC",
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'drawable/app_icon',
              ),
            ));

      }
      // if (message != null) {
      //   Map data = message.data;
      //   print(data['notification_type']);
      // }
      print('A new onMessageOpenedApp event was published! ${message.data}');
    });



    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

    imgList = [];

    _arrCategories = _getCategories();
    _searchKey = "";
    openSearch = false;

    isAgent = false;
    _freshProductList = _getFreshProducts();
    _listOfferSlider = [];
    _getOfferSlider();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.text = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Navigation(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: <Widget>[
                    // The containers in the background
                    shapeComponet(context, Consts.shapeHeight),
                    // The card widget with top padding,
                    // incase if you wanted bottom padding to work,
                    // set the `alignment` of container to Alignment.bottomCenter
                    new Container(
                      alignment: Alignment.topCenter,
                      padding: new EdgeInsets.only(
                        top: Consts.shapeHeight * .65,
                        right: 0.0,
                        left: 0.0,
                      ),

                      child: imgList.length > 0
                          ? offerSlider()
                          : Container(
                        height: 100,
                            child: Center(
                                child: CircularProgressIndicator(),
                              ),
                          ),
                      // ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18.0,
                    right: 8.0,
                    top: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            color: AppColors.categoryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      CategoryList(arrCategories: _arrCategories),
                      SizedBox(
                        height: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(

                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fresh New Items",
                              style: TextStyle(
                                color: AppColors.categoryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // Text(
                            //   "More",
                            //   style: TextStyle(
                            //     color: AppColors.categoryTextColor,
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w700,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        height:250,
                        child: FutureBuilder(
                            initialData: null,
                            future: _freshProductList,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                var freshItems = snapshot.data;
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: freshItems.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, int index) {
                                      ProductModel item = freshItems[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: FreshItem(
                                          deviceId: deviceID,
                                          itemProduct: item,
                                          isAgent: isAgent,
                                          notifyCart: _updateCart,
                                        ),
                                      );
                                    });
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                        // child: ListView.builder(
                        //   shrinkWrap: true,
                        //   itemCount: 6,
                        //   scrollDirection: Axis.horizontal,
                        //   itemBuilder: (context, int index) {
                        //     return Padding(
                        //       padding: const EdgeInsets.only(right: 8.0),
                        //       child: FreshItem(),
                        //     );
                        //   },
                        // ),
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
    );
  }

  CarouselSlider offerSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        reverse: false,
        height: 130,
        // aspectRatio: 3.8,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      ),
      items: imgList
          .map(
            (item) => InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListScreen(
                      categoryID: _listOfferSlider[imgList.indexOf(item)].categoryId,
                      searchKeyword: "",
                      categoryName: _listOfferSlider[imgList.indexOf(item)].name,
                      isAgent: isAgent,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.categoryOverlayLayout,
                    borderRadius: BorderRadius.all(
                      Radius.circular(9),
                    ),
                    border: Border.all(
                        color: AppColors.categoryOverlayLayout, width: 1),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                          width: 300,
                        ),
                      ),
                      Positioned(
                        bottom: 40.0,
                        left: 40.0,
                        right: 0.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_listOfferSlider[imgList.indexOf(item)].name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_listOfferSlider[imgList.indexOf(item)].offerText}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget navDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.

          padding: EdgeInsets.only(top: 10),
          children: <Widget>[
            // DrawerHeader(
            //   child: Text('Drawer Header'),
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),
            ListTile(
              title: Text(
                'Item 1',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget CustomAppbar() {
    return AppBar(
      title: 
      // openSearch
          // ? Theme(
          //     data: Theme.of(context).copyWith(splashColor: Colors.transparent),
          //     child: TextField(
          //       controller: _searchController,
          //       autofocus: openSearch,
          //       onChanged: (value) => {
          //         setState(
          //           () {
          //             _searchKey = value;
          //           },
          //         ),
          //       },
          //       style: TextStyle(
          //         fontSize: 14.0,
          //         color: Color(0xff000000),
          //       ),
          //       keyboardType: TextInputType.text,
          //       decoration: InputDecoration(
          //         filled: true,
          //         fillColor: Color(0XFFF8F8F8),
          //         suffixIcon: IconButton(
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => ProductListScreen(
          //                   categoryID: "",
          //                   searchKeyword: _searchKey,
          //                 ),
          //               ),
          //             );
          //           },
          //           icon: IconButton(
          //             icon: Icon(
          //               Icons.clear,
          //               color: Colors.black,
          //               size: 20,
          //             ),
          //             onPressed: () {
          //               debugPrint("Test");
          //               setState(
          //                 () {
          //                   _searchKey = "";
          //                   _searchController.text = "";
          //                 },
          //               );
          //             },

          //             // icon:Icons.clear,
          //             // color: Colors.black,
          //             // size: 12,
          //           ),
          //         ),
          //         hintText: 'Search..',
          //         hintStyle: TextStyle(
          //           color: Colors.black,
          //         ),
          //         contentPadding: EdgeInsets.all(10.0),
          //         focusedBorder: OutlineInputBorder(
          //           borderSide: BorderSide(color: Colors.white),
          //           borderRadius: BorderRadius.circular(4),
          //         ),
          //         enabledBorder: UnderlineInputBorder(
          //           borderSide: BorderSide(color: Colors.white),
          //           borderRadius: BorderRadius.circular(4),
          //         ),
          //       ),
          //     ),
          //   )
          // : 
          Center(
              child: Text(
                "Vedic",
                style: TextStyle(
                  fontFamily: "Philosopher",
                  fontSize: 36,
                ),
              ),
            ),
      actions: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              width: 40,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Container(
                        width: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.appMainColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            Variables.itemCount == null ? "0":"${Variables.itemCount}",
                            // "$quantity",
                            style:
                            TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            // _handleAddCart(itemProduct);
            _gotoShoppinCartScreen();
          },
        ),
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
}

class CategoryList extends StatelessWidget {
  const CategoryList({
    Key key,
    @required Future<CategoryModel> arrCategories,
  })  : _arrCategories = arrCategories,
        super(key: key);

  final Future<CategoryModel> _arrCategories;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: FutureBuilder(
          initialData: null,
          future: _arrCategories,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var categories = snapshot.data.categorydata;
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    CategoryData categoryData = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CategoryItem(
                        categoryData: categoryData,
                      ),
                    );
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
