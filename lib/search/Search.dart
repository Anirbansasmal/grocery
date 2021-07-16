import 'dart:convert';

import 'package:groceryapp/shopping_cart/ShoppingCartScreen.dart';
import 'package:groceryapp/util/AppColors.dart';
import 'package:groceryapp/util/Variables.dart';

import '../products/WishListModel.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_drawer/Navigation.dart';
import '../products/ItemProduct.dart';
import '../shapes/screen_clip.dart';
import '../util/Consts.dart';
import 'SearchItemProduct.dart';
import 'SearchModel.dart';

class Search extends StatefulWidget {
  // final String searchKeyword;
  // final String categoryID;
  // final String categoryName;
  // const Search({
  //   Key key,
  //   this.searchKeyword,
  //   this.categoryID,
  //   this.categoryName,
  // }) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<Search> {
  bool isApiCalling;
  String _pageTitle;
  Future<SearchModel> _productList;
  Future<List<WishListModel>> _productwishList;
  bool _showLoder;
  List<String> sortByList = ["Product Sorting"];
  String _searchKey;
  String _categoryID;
  bool openSearch;
  bool isAvailable = true;
  String noProductMessage;
  var _searchController = new TextEditingController();
  FocusNode myFocusNode;
  bool isAgent;
  bool showMyFavourite;

  int quantity;

  @override
  void initState() {
    // TODO: implement initState
    quantity = 0;
    _handleFetchCart();

    noProductMessage = '';
    _pageTitle = "";
    _categoryID = "";
    _searchKey="";
    openSearch = false;
    myFocusNode = FocusNode();
    // if (_searchKey != null && !_searchKey.isEmpty) {
    //   openSearch = true;
    // } else {
    //   openSearch = false;
    // }
    _showLoder = false;
    // _searchKey = widget.searchKeyword;

    // isUserLoggedIn = false;
    // debugPrint("mList _productList main ${_searchKey}");
    isApiCalling = false;
    if (_searchKey == "") {
      // debugPrint("mList _productList main${_productList}");
    } else {
      // debugPrint("mList _productList main${_productList}");
      // _productList=_getProducts(_categoryID);
    }
    // _productwishList = fetchWish();
    isAgent = false;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.text = "";
    myFocusNode.dispose();
    super.dispose();
  }

  Future<SearchModel> _getProducts(String _searchKey) async {
    String catID="";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('user_id');

    if (prefs.get("usertype") != null && prefs.get("usertype") == "DI") {
      setState(() {
        isAgent = true;
      });
    }

    // List<ProductModel> mList = [];
    print(_searchKey);
if(_searchKey!=""){
  print(_searchKey);
// }
    var requestParam;

    http.Response response;
    if (_searchKey != null && _searchKey != "") {
      requestParam = "?keyword=" + _searchKey;
      if (userID != null && int.parse(userID) > 0) {
        requestParam += "&user_id=" + userID;
      }
    } else if (showMyFavourite == true) {
      requestParam = "?my_wishlist=1";
      if (userID != null && int.parse(userID) > 0) {
        requestParam += "&user_id=" + userID;
      }
    } else {
      requestParam = "?cat_id=" + catID;
      if (userID != null && int.parse(userID) > 0) {
        requestParam += "&user_id=" + userID;
      }
    }

    response = await http.get(
      Uri.parse(Consts.PRODUCT_LIST + requestParam),
    );

    debugPrint("URl ${Uri.parse(Consts.PRODUCT_LIST + requestParam)}");

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var productData = responseData['productdata'];
      if (responseData['status'] == "success") {
        if (productData.length > 0) {
          return SearchModel.fromJson(responseData);
        }
        _showLoder = true;
        isApiCalling = true;
      } else {
        setState(() {
          isAvailable = false;
          noProductMessage = serverMessage;
        });
        showCustomToast(serverMessage);
      }
      setState(() {
        _showLoder = false;
      });
    } else {
      showCustomToast("Error while conneting to server");
      throw Exception("Error getting response  ${response.statusCode}");
    }
    }else{
  
}
    // debugPrint("mList ${mList}");
    return null;
  }

  _gotoShoppinCartScreen() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingCartScreen(),
      ),
    );
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
          Variables.itemCount = arrCartProducts.length;
          setState(() {
            quantity = Variables.itemCount;
          });
        }
      } else {
        print("Else part");
        setState(() {
          quantity = 0;
        });
      }
    }
  }

  void _updateCart() {
    debugPrint("Update cart");
    _handleFetchCart();
  }

  searchitem(String value) {
    _showLoder = false;
    setState(() {
      _pageTitle = value;
    });
    _categoryID = "";
    _productList = _getProducts(value);
    debugPrint("_productList _productList search${_productList}");
  }

  @override
  Widget build(BuildContext context) {
    double shapeHeight = 150;
    // print(_searchKey);
    return Scaffold(
      backgroundColor: Colors.white,
      // key: UniqueKey(),
      drawer: Navigation(),
      appBar: CustomAppbar(),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "images/image_bg.png",
              ),
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
                    ClipPath(
                      clipper: RedShape(
                          MediaQuery.of(context).size.width, shapeHeight),
                      child: Container(
                        height: shapeHeight,
                        decoration: BoxDecoration(
                          color: Color(0XFFc80718),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 35,
                            right: 10,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              // Text(
                              //   _pageTitle,
                              //   style: TextStyle(
                              //     fontSize: 35,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              Flexible(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 7.0),
                                        child: Text(
                                          _pageTitle,
                                          style: TextStyle(
                                            fontSize: 21,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    // Container(
                                    //   height: 40,
                                    //   color: Color(0XFFA90415),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: DropdownButton<String>(
                                    //       value: "Product Sorting",
                                    //       items: sortByList.map((String value) {
                                    //         return new DropdownMenuItem<String>(
                                    //           value: value,
                                    //           child: new Text(
                                    //             value,
                                    //             textAlign: TextAlign.center,
                                    //             style: TextStyle(
                                    //               color: Colors.white,
                                    //               fontSize: 15.0,
                                    //               fontWeight: FontWeight.bold,
                                    //             ),
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    //       onChanged: (value) {
                                    //         setState(() {});
                                    //       },
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // The card widget with top padding,
                    // incase if you wanted bottom padding to work,
                    // set the `alignment` of container to Alignment.bottomCenter
                    Container(
                      alignment: Alignment.topCenter,
                      padding: new EdgeInsets.only(
                        top: shapeHeight * .70,
                        right: 20.0,
                        left: 20.0,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Color(0XFFf9f7f7),
                                width: 4,
                              ),
                            ),
                            height: 100,
                            child: !isAvailable
                                ? Center(
                                    child: Text(
                                      noProductMessage,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Container(
                                // height:
                                //     MediaQuery.of(context).size.height - 200,
                                child:SearchList(arrCategories: _productList),
// _showLoder==false ? Container(): 
                                // FutureBuilder(
                                //   initialData: null,
                                //   future: _productList,
                                //   builder: (BuildContext context,
                                //       AsyncSnapshot snapshot) {
                                //     if (snapshot.hasData) {
                                //       var arrProducts = snapshot.data;
                                //       // debugPrint(arrProducts);
                                //       return ListView.builder(
                                //         padding: EdgeInsets.all(0),
                                //         shrinkWrap: true,
                                //         itemCount: arrProducts.length,
                                //         scrollDirection: Axis.vertical,
                                //         itemBuilder: (context, int index) {
                                //           SearchModel itemProduct =
                                //               arrProducts[index];
                                //           return ItemProduct(
                                //             // itemProduct: itemProduct,
                                //             isAgent: isAgent,
                                //             notifyCart: _updateCart,
                                //           );
                                //         },
                                //       );
                                //     } else {
                                //       return _showLoder
                                //           ? Center(
                                //               child:
                                //                   CircularProgressIndicator(),
                                //             )
                                //           : Container();
                                //     }
                                //   },
                                // ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
      title: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          focusNode: myFocusNode,
          onChanged: (value) => {
            setState(
              () {
                _searchKey = value;
              },
            ),
          },
          onSubmitted:(value){
            
          searchitem(value);
          },
          textInputAction:TextInputAction.done,
          style: TextStyle(
            fontSize: 14.0,
            color: Color(0xff000000),
          ),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0XFFF8F8F8),
            suffixIcon: IconButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ProductListScreen(
                //       categoryID: "",
                //       searchKeyword: _searchKey,
                //     ),
                //   ),
                // );
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
                            Variables.itemCount == null
                                ? "0"
                                : "${Variables.itemCount}",
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
        // IconButton(
        //   icon: Icon(
        //     Icons.search,
        //     color: Colors.white,
        //     size: 35,
        //   ),
        //   onPressed: () {
            // searchitem();
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => Search(
            //       categoryID: "",
            //       searchKeyword: _searchKey,
            //     ),
            //   ),
            // );
        //   },
        // )
      ],
    );
  }
}

class SearchList extends StatelessWidget {
  const SearchList({
    Key key,
    @required Future<SearchModel> arrCategories,
  })  : _arrCategories = arrCategories,
        super(key: key);
  final Future<SearchModel> _arrCategories;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: FutureBuilder(
          initialData: null,
          // key: UniqueKey(),
          future: _arrCategories,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var categories = snapshot.data.productdata;
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    Productdata categoryData = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SearchItemProduct(
                        productdata: categoryData,
                      ),
                    );
                  });
            } else {
              return Center(
                // child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
