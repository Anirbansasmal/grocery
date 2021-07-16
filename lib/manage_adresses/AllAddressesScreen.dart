import 'dart:convert';

import '../manage_adresses/AddAdressScreen.dart';
import '../manage_adresses/ItemAddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../manage_adresses/AddressModel.dart';
import '../shapes/screen_clip.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';

class AllAdressScreen extends StatefulWidget {
  final List<AddressModel> mAddressList;

  const AllAdressScreen({
    Key key,
    this.mAddressList,
  }) : super(key: key);
  @override
  _AllAdressScreenState createState() => _AllAdressScreenState();
}

class _AllAdressScreenState extends State<AllAdressScreen> {
  List<AddressModel> _mAddressList;
  Future<List<AddressModel>> _addressList;

  AddressModel itemSelected;

  String selectedAddress;
  String selectedPaymmentMethod;
  bool isAdressApiCalling;

  @override
  void initState() {
    // _addressList = _getAddress();
    isAdressApiCalling = false;
    _mAddressList = [];
    _getAddress();
    itemSelected = new AddressModel();

    // TODO: implement initState
    super.initState();
  }

  _getAddress() async {
    setState(() {
      isAdressApiCalling = true;
      _mAddressList = [];
    });
    double totalPrice = 0;
    List<AddressModel> mList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    final http.Response response = await http.get(
      Uri.parse(Consts.USER_ADDRESSES_LIST + requestParam),
    );
    print(Consts.USER_ADDRESSES_LIST + requestParam);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var arrAddress = responseData["userdata"];
      print(responseData);
      if (responseData['status'] == "success") {
        if (arrAddress.length > 0) {
          for (int i = 0; i < arrAddress.length; i++) {
            var itemData = arrAddress[i];
            print(itemData);
            AddressModel item = AddressModel();
            // var productDetails =itemData['productdata'];
            item.id = itemData['id'];
            item.userId = itemData['user_id'];
            item.defaultBilling = itemData['default_billing'];
            if (item.defaultBilling == "1") {
              setState(() {
                itemSelected = item;
              });
            }
            item.name = itemData['name'];
            item.phone = itemData['phone'];
            item.email = itemData['email'];
            item.pincode = itemData['pincode'];
            item.flatHouseFloorBuilding = itemData['flat_house_floor_building'];
            item.locality = itemData['locality'];
            item.landmark = itemData['landmark'];
            item.city = itemData['city'];
            item.state = itemData['state'];
            item.country = itemData['country'];
            item.country = itemData['country'];
            item.addressType = itemData['address_type'];
            mList.add(item);
          }
        }
      }
      else {
        showCustomToast(serverMessage);
        setState(() {
          isAdressApiCalling = false;
          _mAddressList = [];
        },);
        return null;
      }
    } else {
      showCustomToast("Something went wrong.\nPlease try again.");
      setState(() {
        isAdressApiCalling = false;
        _mAddressList = [];
      });
      return null;
    }

    setState(() {
      _mAddressList = mList;
      isAdressApiCalling = false;
    });
  }

  // ==============
  _changePaymentMethod(String paymentMethod) {
    setState(() {
      selectedPaymmentMethod = paymentMethod;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(
          context,
          itemSelected,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: Text(
            "Vedic",
            style: TextStyle(
              fontFamily: "Philosopher",
              fontSize: 36,
            ),
          ),
          centerTitle: true,
        ),
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
                children: [
                  customShape(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 5,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _addAddress();
                                  },
                                  child: Text(
                                    "Add New",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          isAdressApiCalling ? Center(
                            child: CircularProgressIndicator(),
                          ):Container(),
                          _mAddressList.length <= 0
                              ? Container()
                              : ListView.separated(
                                  padding: EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _mAddressList.length,
                                  scrollDirection: Axis.vertical,
                                  separatorBuilder: (context, int index) {
                                    return Divider();
                                  },
                                  itemBuilder: (context, int index) {
                                    AddressModel itemAddress =
                                        _mAddressList[index];
                                    return ItemAddress(
                                      key: UniqueKey(),
                                      notifyParent: _notify,
                                      notifyDelete: _notifyDelete,
                                      addressModel: itemAddress,
                                      mAddressList: _mAddressList,
                                      index: index,
                                    );
                                  },
                                ),
                          /*FutureBuilder(
                            initialData: null,
                            future: _addressList,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                _mAddressList = snapshot.data;
                                return _mAddressList.length <= 0
                                    ? Container()
                                    : ListView.separated(
                                        padding: EdgeInsets.all(0),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _mAddressList.length,
                                        scrollDirection: Axis.vertical,
                                        separatorBuilder: (context, int index) {
                                          return Divider();
                                        },
                                        itemBuilder: (context, int index) {
                                          AddressModel itemAddress =
                                              _mAddressList[index];
                                          return ItemAddress(
                                            notifyParent: _notify,
                                            notifyDelete: _notifyDelete,
                                            addressModel: itemAddress,
                                            mAddressList: _mAddressList,
                                            index: index,
                                          );
                                        },
                                      );
                              } else {
                                return Container();
                              }
                            },
                          ),*/
                          SizedBox(
                            height: 20,
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
      ),
    );
  }

  final double shapeHeight = 140;
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
                "All Adresses",
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

  _notify(AddressModel itemAddress) async {
    // setState(() {});
    if (_mAddressList.length > 0) {
      for (int i = 0; i < _mAddressList.length; i++) {
        AddressModel addressModel = _mAddressList[i];

        addressModel.defaultBilling = "0";
        if (itemAddress.id == addressModel.id) {
          setState(() {
            if (itemAddress.defaultBilling == "0") {
              addressModel.defaultBilling = "1";
              debugPrint("Id of item is ${addressModel.id}");
              itemSelected = addressModel;
            }
          });
        } else {}
      }
    }

    debugPrint("_notify in all address data");
  }

  _addAddress() async {
    var dataReturned = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAdressScreen(
          previousScreen: "all_address",
        ),
      ),
    );
    debugPrint("Refresh data");
    if(dataReturned != null ){
      _getAddress();
    }

  }

  _notifyDelete(int index) async {
    // setState(() {});

    debugPrint("_notifyDelete");
    setState(() {});

    _mAddressList.removeAt(index);
  }
}
