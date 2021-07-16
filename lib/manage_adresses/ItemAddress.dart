import 'dart:convert';

import 'package:groceryapp/manage_adresses/EditAdressScreen.dart';
import 'package:groceryapp/util/Util.dart';

import '../manage_adresses/AddressModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../util/AppColors.dart';
import '../util/Consts.dart';

class ItemAddress extends StatefulWidget {
  final int index;
  final Function(AddressModel itemAddress) notifyParent;
  final Function(int index) notifyDelete;
  final AddressModel addressModel;
  final List<AddressModel> mAddressList;

  const ItemAddress(
      {Key key, this.addressModel, this.mAddressList, this.notifyParent, this.index, this.notifyDelete})
      : super(key: key);
  @override
  _ItemAddressState createState() => _ItemAddressState();
}

class _ItemAddressState extends State<ItemAddress> {
  AddressModel itemAddress;
  int index;
  List<AddressModel> _mAddressList;
  String address;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemAddress = widget.addressModel;
    index = widget.index;
    _mAddressList = widget.mAddressList;
    address = "";
    if (itemAddress.name != null && itemAddress.name != "") {
      address += itemAddress.name;
    }
    if (itemAddress.flatHouseFloorBuilding != null &&
        itemAddress.flatHouseFloorBuilding != "") {
      if (address == "") {
        address += "" + itemAddress.flatHouseFloorBuilding;
      } else {
        address += "\n" + itemAddress.flatHouseFloorBuilding;
      }
    }
    if (itemAddress.locality != null && itemAddress.locality != "") {
      address += " " + itemAddress.locality;
    }
    if (itemAddress.landmark != null && itemAddress.landmark != "") {
      address += "\n" + itemAddress.landmark;
    }
    if (itemAddress.city != null && itemAddress.city != "") {
      address += " " + itemAddress.city;
    }
    if (itemAddress.pincode != null && itemAddress.pincode != "") {
      address += " - " + itemAddress.pincode;
    }
  }

  _itemSetDefault(bool isDefault) async {
    // setState(() {
    //   itemAddress.defaultBilling = isDefault ? "0" : "1";
    // });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&address_id=" + widget.addressModel.id;

    final http.Response response = await http.get(
      Uri.parse(Consts.updateDefaultAddress + requestParam),
    );
    print(Consts.updateDefaultAddress + requestParam);
    print("updateDefaultAddress response ${response.body}");
    widget.notifyParent(itemAddress);
  }

  //======== Delete Address ===
  void _deleteAddress(AddressModel itemAddress, int index) async {
    String addressId = itemAddress.id;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&address_id=" +addressId;
    final http.Response response = await http.get(
      Uri.parse(Consts.DELETE_ADDRESS + requestParam),
    );
    print(Consts.DELETE_ADDRESS + requestParam);
    if(response.statusCode ==200){
      print(response.body);
      var responseData = jsonDecode(response.body);
      var serverStatus = responseData['status'];
      var serverMessage = responseData['message'];
      if(serverStatus == "success"){
        widget.notifyDelete(index);
      }
      showCustomToast(serverMessage);
    }
    else{
      showCustomToast(Consts.SERVER_NOT_RESPONDING);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.checkoutAddDeleiverColor,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 15.0,
          bottom: 15.0,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "$address",
                    softWrap: true,
                    style: TextStyle(
                      color: AppColors.checkoutAddressColor,
                      fontSize: 15,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAdressScreen(
                          addressModel: itemAddress,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 30,
                    child: Icon(
                      Icons.edit,
                      size: 25,
                      color: Colors.black87,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showAlertDialogWithCancel(context, "Are you sure?\nThis can not be undone.", (){
                      print("Delete OK");
                      Navigator.pop(context);
                      _deleteAddress(itemAddress, index);
                    });
                  },
                  child: Container(
                    width: 30,
                    child: Icon(
                      Icons.delete,
                      size: 25,
                      color: AppColors.checkoutAddDeleiverColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    debugPrint("Mark as default.");
                    _itemSetDefault(
                      itemAddress.defaultBilling == "1" ? true : false,
                    );
                  },
                  child: Container(
                    width: 40,
                    child: Icon(
                      Icons.check_circle,
                      size: 25,
                      color: itemAddress.defaultBilling == "1"
                          ? AppColors.checkoutAddDeleiverColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
