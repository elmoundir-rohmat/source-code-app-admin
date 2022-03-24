import 'dart:convert';
import 'dart:io';
import 'package:fellahi_e/providers/referFields.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/walletfield.dart';
import '../providers/sellingitemsfields.dart';
import '../constants/IConstants.dart';
import '../providers/pickuplocFields.dart';
import '../providers/shoppinglistfield.dart';
import '../providers/loyaltyFields.dart';
import '../providers/delChargeFields.dart';
import './brandfields.dart';
import '../constants/images.dart';

class BrandItemsList with ChangeNotifier {
  List<BrandsFields> _items = [];
  List<SellingItemsFields> _brandsitems = [];
  List<SellingItemsFields> _itemspricevar = [];
  List<WalletItemsFields> _walletitems = [];
  List<ShoppinglistItemsFields> _shoplistitems = [];
  List<ShoppinglistItemsFields> _listitemsdetails = [];
  List<ShoppinglistItemsFields> _listitemspricevar = [];
  List<WalletItemsFields> _paymentitems = [];
  List<PickuplocFields> _pickupLocitems = [];
  List<DelChargeFields> _itemsDelCharge = [];
  List<LoyaltyFields> _itemsLoyalty = [];
  ReferFields _referEarn;
Future<void> RegisterEmail() async{
  var url=IConstants.API_PATH + 'customer/password-register';
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(url, body: {
      // await keyword is used to wait to this operation is complete.
      "username": "",
      "email": "",
      "path" : "",
      "mobileNumber":"",
      "tokenId":"",
      "branch":"",
      "password":"",
      //"device":channel.toString(),

    });
    final responseJson = json.decode(utf8.decode(response.bodyBytes));
    final data = responseJson['data'] as Map<String, dynamic>;

    if (responseJson['status'].toString() == "true") {
    }

 else if (responseJson['status'].toString() == "false") {}
  } catch (error) {
    throw error;
  }

}

  Future<void> LoginEmail() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'useremail-login';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "email": prefs.getString('Email'),
        "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;
      if (responseJson['status'].toString() == 200) {
        //prefs.setString('Otp', data['otp'].toString());
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['userID'].toString());
       prefs.setString('Name', responseJson['name'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());


      /* Navigator.of(context).pushNamed(
         OtpconfirmScreen.routeName,
       );
*/


      } else if (responseJson['status'].toString() == 400) {}
    } catch (error) {
      throw error;
    }
  }
  Future<void> LoginUser() async {

    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/pre-register';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "mobileNumber": prefs.getString('Mobilenum'),
        "tokenId": prefs.getString('tokenid'),
        "signature" : prefs.containsKey("signature") ? prefs.getString('signature') : "",
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;

      if (responseJson['status'].toString() == "true") {
        prefs.setString('Otp', data['otp'].toString());
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['userID'].toString());
        prefs.setString('type', responseJson['type'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());

        if (prefs.getString('prevscreen') != null) {
          if (prefs.getString('prevscreen') == 'signingoogle') {
          } else if (prefs.getString('prevscreen') == 'signinfacebook') {
          } else {
            prefs.setString('FirstName', data['name'].toString());
            prefs.setString('LastName', "");
            prefs.setString('Email', data['email'].toString());
            prefs.setString("photoUrl", "");
          }
        }

//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );



      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      throw error;
    }
  }

  Future<void> PrivacyPolicy() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/privacy-policy';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final dataJson =
      json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>)); //store each category values in data list

      if (responseJson['status'].toString() == "true") {
        prefs.setString('privacy', data[0]['privacy'].toString());
        prefs.setString('terms', data[0]['restaurantTerms'].toString());
      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      throw error;
    }
  }

  Future<void> GetRestaurant() async {

    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'get-resturant';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url,
          body: {
            // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          prefs.setString("country_code", data[i]['country_code'].toString());
          prefs.setString("currency_format", data[i]['currency_format'].toString());
          prefs.setString("min_order_amount", data[i]['min_order_amount'].toString()); // this is for delivery charge
          prefs.setString("minimum_order_amount", data[i]['minimum_order_amount'].toString()); //minimum order amount
          prefs.setString("delivery_charge", data[i]['delivery_charge'].toString());
          prefs.setString("restaurant_name", data[i]['restaurant_name'].toString());
          prefs.setString("privacy", data[i]['privacy'].toString() == "null" ? "" : data[i]['privacy'].toString());
          prefs.setString("returnspolicy", data[i]['returns'].toString() == "null" ? "" : data[i]['returns'].toString());
          prefs.setString("refund", data[i]['refund'].toString() == "null" ? "" : data[i]['refund'].toString());
          prefs.setString("wallet", data[i]['wallet'].toString() == "null" ? "" : data[i]['wallet'].toString());
          prefs.setString("description", data[i]['description'].toString());
          prefs.setString("restaurant_address", data[i]['restaurant_address'].toString());
          prefs.setString("primary_mobile", data[i]['primary_mobile'].toString());
          prefs.setString("primary_email", data[i]['primary_email'].toString());
          prefs.setString("secondary_email", data[i]['secondary_email'].toString());
          prefs.setString("secondary_mobile", data[i]['secondary_mobile'].toString());
          prefs.setString("restaurant_terms", data[i]['restaurant_terms'].toString());
          prefs.setString("restaurant_location", data[i]['restaurant_location'].toString());
          prefs.setString("restaurant_lat", data[i]['restaurant_lat'].toString());
          prefs.setString("restaurant_long", data[i]['restaurant_long'].toString());
          prefs.setString("category_label", data[i]['category_label'].toString() == "null" ? "null" : data[i]['category_label'].toString());
          prefs.setString("category_two_label", data[i]['category_two_label'].toString() == "null" ? "null" : data[i]['category_two_label'].toString());
          prefs.setString("category_three_label", data[i]['category_three_label'].toString() == "null" ? "null" : data[i]['category_three_label'].toString());

          prefs.setString("category", (data[i]['category'].toString() == "null" || data[i]['category'].toString() == "") ? "null" : data[i]['category'].toString());
          prefs.setString("category_two", (data[i]['category_two'].toString() == "null" || data[i]['category_two'].toString() == "") ? "null" : data[i]['category_two'].toString());
          prefs.setString("category_three", (data[i]['category_three'].toString() == "null" || data[i]['category_three'].toString() == "") ? "null" : data[i]['category_three'].toString());
          prefs.setString("secondary_mobile", data[i]['secondary_mobile'].toString());
        }
      }
    } catch (error) {
      throw error;
    }
  }


  Future<void> guestNotification()async{


    var url = IConstants.API_PATH + 'customer/register/guest/user';
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "token": prefs.getString('tokenid'),//prefs.getString('apiKey'),
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "200") {
        prefs.setString('tokenid',responseJson['guestUserId']);
        prefs.setString("guestuserId",responseJson['guestUserId']);

      } else  {}
    } catch (error){
      throw error;
    }
  }
  Future<void> userDetails()async{

    var url = IConstants.API_PATH + 'customer/get-profile';
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
      });
      final responseJson = json.decode(response.body);
      final dataJson =
      json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);
      List data = [];
      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>));
      for (int i = 0; i < data.length; i++) {
        prefs.setString('membership', data[i]['membership'].toString());
        prefs.setString('myreffer', data[i]['myref'].toString());
        prefs.setString("referral_id", data[i]['referralId'].toString());
        //prefs.setString("dob", data[i]['dob'].toString() == "null" ? "null" : data[i]['dob'].toString());
      }
    } catch (error){
      throw error;
    }
  }


  Future<void> fetchBrands() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/get-brands';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _items.clear();
      final response = await http.post(url, body: {
        "branch": prefs.getString('branch'),
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

//      var idlist = responseJson.map<int>((m) => m['id'] as int).toList();
//      var imagelist = responseJson.map<String>((m) => m['banner_image'] as String).toList();

      List data = [];

      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>));

      for (int i = 0; i < data.length; i++) {
        _items.add(BrandsFields(
          id: data[i]['id'].toString(),
          title: data[i]['category_name'].toString(),
          imageUrl: IConstants.API_IMAGE +
              "sub-category/icons/" +
              data[i]['icon_image'].toString(),
        ));
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchBrandItems(
      String brandsid, int startitem, String checkinitialy) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/get-menuitem-by-brand';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("endOfProduct", false);
    try {
      if (checkinitialy == "initialy") {
        _brandsitems.clear();
        _itemspricevar.clear();
      } else {}
      final response = await http.post(url, body: {
        "id": brandsid,
        "start": startitem.toString(),
        "end": "0",
        "branch": prefs.getString('branch'),
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]" || responseJson.toString() == "") {
        prefs.setBool("endOfProduct", true);
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          _brandsitems.add(SellingItemsFields(
              id: data[i]['id'].toString(),
              title: data[i]['item_name'].toString(),
              imageUrl: IConstants.API_IMAGE +
                  "items/images/" +
                  data[i]['item_featured_image'].toString(),
              brand: data[i]['brand'].toString()));

          final pricevarJson = json.encode(
              data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories

          if (pricevarJsondecode == null) {
          } else {
            pricevarJsondecode.asMap().forEach((index, value) => pricevardata
                .add(pricevarJsondecode[index] as Map<String, dynamic>));

            for (int j = 0; j < pricevardata.length; j++) {
              bool _discointDisplay = false;
              bool _membershipDisplay = false;

              if (double.parse(pricevardata[j]['price'].toString()) <= 0 ||
                  pricevardata[j]['price'].toString() == "" ||
                  double.parse(pricevardata[j]['price'].toString()) ==
                      double.parse(pricevardata[j]['mrp'].toString())) {
                _discointDisplay = false;
              } else {
                _discointDisplay = true;
              }

              if (pricevardata[j]['membership_price'].toString() == '-' ||
                  pricevardata[j]['membership_price'].toString() == "0" ||
                  double.parse(
                      pricevardata[j]['membership_price'].toString()) ==
                      double.parse(pricevardata[j]['mrp'].toString())) {
                _membershipDisplay = false;
              } else {
                _membershipDisplay = true;
              }

              _itemspricevar.add(SellingItemsFields(
                varid: pricevardata[j]['id'].toString(),
                menuid: pricevardata[j]['menu_item_id'].toString(),
                varname: pricevardata[j]['variation_name'].toString(),
                varmrp: pricevardata[j]['mrp'].toStringAsFixed(2),
                varprice: pricevardata[j]['price'].toStringAsFixed(2),
                varmemberprice: pricevardata[j]['membership_price'].toStringAsFixed(2),
                varstock: pricevardata[j]['stock'].toString(),
                varminitem: pricevardata[j]['min_item'].toString(),
                varmaxitem: pricevardata[j]['max_item'].toString(),
                varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                    pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
                discountDisplay: _discointDisplay,
                membershipDisplay: _membershipDisplay,
              ));
            }
          }
        }
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchPaymentMode() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'payment-mode';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _paymentitems.clear();
      final response = await http.get(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      prefs.setBool("isExpress", false);
      prefs.setBool("isPickupMode", false);

      if (responseJson.toString() != "[]") {
        List data = [];

        responseJson
            .asMap()
            .forEach((index, value) => data.add(responseJson[index]));
        String payName = "";
        String payMode = "0";
        for (int i = 0; i < data.length; i++) {
          if (data[i].toString() == "cod") {
            payName = "Pay on Delivery";
            payMode = "6";
          } else if (data[i].toString() == "sod") {
            payName = translate('forconvience.SOD');//"Card on Delivery";
            payMode = "0";
          } else if (data[i].toString() == "online") {
            payName =translate('forconvience.Online Payment');
            payMode = "1";
          } else if (data[i].toString() == "wallet") {
            payName = "Wallet Balance";
            payMode = "2";
          } else if (data[i].toString() == "pickupfromstore") {
            payName = "Pickup from Store";
            payMode = "3";
          } else if (data[i].toString() == "loyalty") {
            payName = "Loyalty";
            payMode = "4";
          } else if (data[i].toString() == "express") {
            payName = "Express";
            payMode = "5";
          }

          if (payMode == "3" || payMode == "5") {
          } else {
            _paymentitems.add(WalletItemsFields(
              paymentType: data[i].toString(),
              paymentName: payName,
              paymentMode: payMode,
            ));
          }
          if (payMode == "3") {
            prefs.setBool("isPickupMode", true);
          }
          if (payMode == "5") {
            prefs.setBool("isExpress", true);
          }
        }
        /*_paymentitems.add(WalletItemsFields(
          paymentType: "loyalty",
          paymentName: "Loyalty",
          paymentMode: "4",
        ));*/
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchWalletBalance() async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'user/get-prepaid-balance';
    try {
      final response = await http.post(url, body: {
        "userId": prefs.getString('userID'),
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];

      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>));
      for (int i = 0; i < data.length; i++) {
        if (double.parse(data[i]['prepaid'].toString()) < 0) {
          prefs.setString("wallet_balance", "0");
        } else {
          prefs.setString("wallet_balance", data[i]['prepaid'].toString());
        }

        if (double.parse(data[i]['loyalty'].toString()) < 0 ||
            data[i]['loyalty'].toString() == "null") {
          prefs.setString("loyalty_balance", "0");
        } else {
          prefs.setString("loyalty_balance", data[i]['loyalty'].toString());
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchWalletLogs(String type) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'wallet/get-logs';

    try {
      _walletitems.clear();
      final response = await http.post(url, body: {
        "userId": prefs.getString('userID'),
        "type": (type == "wallet") ? "0" : "2",
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];

      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>));
      for (int i = 0; i < data.length; i++) {
        if (data[i]['data'].toString() != "[]") {
          final pricevarJson = json.encode(data[i]['data']);
          final pricevarJsondecode = json.decode(pricevarJson);

          var amount;
          var title;
          var img;
          if (double.parse(pricevarJsondecode['credit'].toString()) <= 0) {
            (type == "wallet")
                ? amount = "-  " +
                pricevarJsondecode['debit'].toString()+
            " " +
                prefs.getString("currency_format")


                : amount = "-  " + double.parse(pricevarJsondecode['debit'].toString()).toStringAsFixed(2);

            title = translate('forconvience.Debit');//"Debit";
            img = Images.debitImg;
          } else {
            (type == "wallet")
                ? amount = "+  " +
                pricevarJsondecode['credit'].toString()+
                " " + prefs.getString("currency_format")
                : amount = "+  " + double.parse(pricevarJsondecode['credit'].toString()).toStringAsFixed(2);
            title = translate('forconvience.Credit');//"Credit";
            img = Images.creditImg;
          }

          _walletitems.add(WalletItemsFields(
            title: title,
            date: pricevarJsondecode['date'].toString(),
            time: pricevarJsondecode['datetime'].toString(),
            amount: amount,
            note: pricevarJsondecode['note'].toString() == "null"
                ? ""
                : pricevarJsondecode['note'].toString(),
            closingbalance: (type == "wallet")?pricevarJsondecode['balance'].toString():double.parse(pricevarJsondecode['balance'].toString()).toStringAsFixed(2),
            img: img,
          ));
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchShoppinglist() async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/my-shopping-list';
    try {
      _shoplistitems.clear();
      _listitemsdetails.clear();
      _listitemspricevar.clear();
      final response = await http.post(url, body: {
        "apiKey": prefs.getString('apiKey'),
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == 'true') {
        if (responseJson['data'].toString() != "[]") {
          final dataJson =
          json.encode(responseJson['data']); //fetching categories data
          final dataJsondecode = json.decode(dataJson);

          List data = []; //list for categories

          dataJsondecode.asMap().forEach((index, value) => data.add(
              dataJsondecode[index] as Map<String,
                  dynamic>)); //store each category values in data list
          for (int i = 0; i < data.length; i++) {
            if (data[i]['shopping_list_details'].toString() != "[]") {
              final listdetailsJson = json.encode(data[i]
              ['shopping_list_details']); //fetching sub categories data
              final listdetailsJsondecode = json.decode(listdetailsJson);
              List listdetailsdata = []; //list for subcategories

              listdetailsJsondecode.asMap().forEach((index, value) =>
                  listdetailsdata.add(
                      listdetailsJsondecode[index] as Map<String, dynamic>));
              _shoplistitems.add(ShoppinglistItemsFields(
                listid: data[i]['shopping_list_id'].toString(),
                listname: data[i]['shopping_list_name'].toString(),
                listcheckbox: false,
                totalitemcount: listdetailsdata.length.toString(),
              ));

              for (int j = 0; j < listdetailsdata.length; j++) {
                _listitemsdetails.add(ShoppinglistItemsFields(
                  listid: data[i]['shopping_list_id'].toString(),
                  itemid: listdetailsdata[j]['menu_item_id'].toString(),
                  itemname: listdetailsdata[j]['itemName'].toString(),
                  imageurl: IConstants.API_IMAGE +
                      "items/images/" +
                      listdetailsdata[j]['itemFeaturedImage'].toString(),
                  brand: listdetailsdata[j]['brand'].toString(),
                ));

                bool _discointDisplay = false;
                bool _membershipDisplay = false;

                if (double.parse(listdetailsdata[j]['price'].toString()) <= 0 ||
                    listdetailsdata[j]['price'].toString() == "" ||
                    double.parse(listdetailsdata[j]['price'].toString()) ==
                        double.parse(listdetailsdata[j]['mrp'].toString())) {
                  _discointDisplay = false;
                } else {
                  _discointDisplay = true;
                }

                if (listdetailsdata[j]['membership_price'].toString() == '-' ||
                    listdetailsdata[j]['membership_price'].toString() == "0" ||
                    double.parse(listdetailsdata[j]['membership_price']
                        .toString()) ==
                        double.parse(listdetailsdata[j]['mrp'].toString())) {
                  _membershipDisplay = false;
                } else {
                  _membershipDisplay = true;
                }

                _listitemspricevar.add(
                  ShoppinglistItemsFields(
                    listid: data[i]['shopping_list_id'].toString(),
                    varid: listdetailsdata[j]['id'].toString(),
                    menuid: listdetailsdata[j]['menu_item_id'].toString(),
                    varname: listdetailsdata[j]['variationName'].toString(),
                    varmrp: listdetailsdata[j]['mrp'].toStringAsFixed(2),
                    varprice: listdetailsdata[j]['price'].toStringAsFixed(2),
                    varmemberprice:
                    listdetailsdata[j]['membership_price'].toStringAsFixed(2),
                    varstock: listdetailsdata[j]['stock'].toString(),
                    varminitem: listdetailsdata[j]['minItem'].toString(),
                    varmaxitem: listdetailsdata[j]['maxItem'].toString(),
                    varLoyalty: listdetailsdata[j]['loyalty'].toString() == "" ||
                        listdetailsdata[j]['loyalty'].toString() == "null" ? 0 : int.parse(listdetailsdata[j]['loyalty'].toString()),
                    discountDisplay: _discointDisplay,
                    membershipDisplay: _membershipDisplay,
                  ),
                );
              }
            } else {
              _shoplistitems.add(ShoppinglistItemsFields(
                listid: data[i]['shopping_list_id'].toString(),
                listname: data[i]['shopping_list_name'].toString(),
                listcheckbox: false,
                totalitemcount: "0",
              ));
            }
          }
        } else {}
      } else {}
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> CreateShoppinglist() async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/create-shopping-list';
    try {
      _shoplistitems.clear();
      final response = await http.post(url, body: {
        "apiKey": prefs.getString('apiKey'),
        "list_name": prefs.getString('list_name'),
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == 'true') {
        /*if (responseJson['data'].toString() != "[]") {
          final dataJson = json.encode(
              responseJson['data']); //fetching categories data
          final dataJsondecode = json.decode(dataJson);


          List data = []; //list for categories

          dataJsondecode.asMap().forEach((index, value) =>
              data.add(dataJsondecode[index] as Map<String, dynamic>)
          ); //store each category values in data list
        } else {
        }*/
      } else {}
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> AdditemtoShoppinglist(
      String itemid, String varid, String listid) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/add-item-to-list';
    try {
      final response = await http.post(url, body: {
        "apiKey": prefs.getString('apiKey'),
        "item_id": itemid,
        "list_id": listid,
        "qty": "0",
        "var_id": varid,
        // await keyword is used to wait to this operation is complete.
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> deliveryCharges(String addressid) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'get-delivery-charges/' + addressid;
    try {
      _itemsDelCharge.clear();
      final response = await http.get(url);

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() != "[]") {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          _itemsDelCharge.add(DelChargeFields(
            id: data[i]['id'].toString(),
            createdDate: data[i]['created_date'].toString(),
            minimumOrderAmountNoraml:
            (data[i]['minimum_order_amount_normal'].toString() == "null")
                ? "0.0"
                : data[i]['minimum_order_amount_normal'].toString(),
            deliveryChargeNormal:
            (data[i]['delivery_charge_normal'].toString() == "null")
                ? "0.0"
                : data[i]['delivery_charge_normal'].toString(),
            minimumOrderAmountPrime:
            (data[i]['minimum_order_amount_prime'].toString() == "null")
                ? "0.0"
                : data[i]['minimum_order_amount_prime'].toString(),
            deliveryChargePrime:
            (data[i]['delivery_charge_prime'].toString() == "null")
                ? "0.0"
                : data[i]['delivery_charge_prime'].toString(),
            minimumOrderAmountExpress:
            (data[i]['minimum_order_amount_express'].toString() == "null")
                ? "0.0"
                : data[i]['minimum_order_amount_express'].toString(),
            deliveryChargeExpress:
            (data[i]['delivery_charge_express'].toString() == "null")
                ? "0.0"
                : data[i]['delivery_charge_express'].toString(),
            deliveryDurationExpress:
            (data[i]['duration'].toString() == "null")
                ? "0.0 "
                : data[i]['duration'].toString(),
          ));
        }
      } else {}

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> getLoyalty() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'get-loyalty';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _itemsLoyalty.clear();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "branch": prefs.getString('branch'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() != "[]") {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          _itemsLoyalty.add(LoyaltyFields(
            id: data[i]['id'].toString(),
            status: data[i]['status'].toString(),
            type: data[i]['type'].toString(),
            minimumOrderAmount: data[i]['minimum_order_amount'].toString(),
            points: data[i]['points'].toString(),
            maximumRedeem: data[i]['maximum_redeem'].toString(),
            discount: data[i]['discount'].toString(),
          ));
        }
      } else {}

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> checkLoyalty(String total) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH +
        'check-loyalty/$total/' +
        prefs.getString('branch');
    try {
      final response = await http.get(
        url,
      );

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      prefs.setDouble("loyaltyPointsUser",
          (responseJson["points"].toString() == "null")
              ? 0.0
              : double.parse(responseJson["points"].toString()));
    } catch (error) {
      throw error;
    }
  }

  Future<void> ReferEarn()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-refercountdetails/' + prefs.getString('branch') +'/' + prefs.getString('userID');
    try {
      // _referEarn.clear();
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            //  "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() != "[]") {
        List data = [];
        /*responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );*/
        _referEarn = new ReferFields(
          amount: responseJson['data']['amount'].toString(),
          imageUrl: IConstants.API_IMAGE +
              responseJson['data']['image'].toString(),
          referral_count: responseJson['data']['referral_count'].toString() == "null" ? 0 : int.parse(responseJson['data']['referral_count'].toString()),
          earning_amount: responseJson['data']['earning_amount'].toString() == "null" ? responseJson['data']['earning_amount'].toStringAsFixed(0):responseJson['data']['earning_amount'].toStringAsFixed(2),

        );
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<BrandsFields> get items {
    return [..._items];
  }

  List<SellingItemsFields> get branditems {
    return [..._brandsitems];
  }

  List<SellingItemsFields> findById(String brandid) {
    return [..._itemspricevar.where((pricevar) => pricevar.menuid == brandid)];
  }

  List<WalletItemsFields> get itemspayment {
    return [..._paymentitems];
  }

  List<WalletItemsFields> get itemswallet {
    return [..._walletitems];
  }

  List<ShoppinglistItemsFields> get itemsshoplist {
    return [..._shoplistitems];
  }

  List<ShoppinglistItemsFields> findByIdlistitem(String listid) {
    return [..._listitemsdetails.where((list) => list.listid == listid)];
  }

  List<ShoppinglistItemsFields> findByIditempricevar(
      String listid, String menuid) {
    return [
      ..._listitemspricevar
          .where((list) => list.listid == listid && list.menuid == menuid)
    ];
  }

  List<DelChargeFields> get itemsDelCharges {
    return [..._itemsDelCharge];
  }

  List<LoyaltyFields> get itemsLoyalty {
    return [..._itemsLoyalty];
  }

  Future<void> removeShoppinglist(String listid) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/remove-shopping-list';
    try {
      final response = await http.post(url, body: {
        "apiKey": prefs.getString('apiKey'),
        "shopping_list_id": listid,
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == 'true') {
      } else {}
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchPickupfromStore() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'pickup-location';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      _pickupLocitems.clear();
      final response = await http.post(url, body: {
        "latitude": prefs.getString('latitude'),
        "longitude": prefs.getString('longitude'),
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() != "[]") {
        List data = [];

        responseJson
            .asMap()
            .forEach((index, value) => data.add(responseJson[index]));
        for (int i = 0; i < data.length; i++) {
          _pickupLocitems.add(PickuplocFields(
            id: data[i]["id"].toString(),
            name: data[i]["name"].toString(),
            address: data[i]["address"].toString(),
            contact: data[i]["contact"].toString(),
          ));

          /* _pickupLocitems.add(PickuplocFields(
            id: data[i]["id"].toString(),
            name: "Mangalore-City Center Mall MLR Mall MLR",
            address: "Times Square Mall, Near ShivBhag Kadri Junction ShivBhag Kadri Junction",
            contact: "9686741043",
          ));*/
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<PickuplocFields> get itemspickuploc {
    return [..._pickupLocitems];
  }

  ReferFields get referEarn {
    return _referEarn;
  }
}
