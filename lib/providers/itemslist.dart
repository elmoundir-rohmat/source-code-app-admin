import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/IConstants.dart';
import './sellingitemsfields.dart';


class ItemsList with ChangeNotifier {
  List<SellingItemsFields> _items = [];
  List<SellingItemsFields> _itemspricevar = [];

  List<SellingItemsFields> _searchitems = [];
  List<SellingItemsFields> _searchitemspricevar = [];

  List<SellingItemsFields> _singleitems = [];
  List<SellingItemsFields> _singleitemspricevar = [];

  List<SellingItemsFields> _multiimages = [];

  Future<void> fetchItems(String catId, String type, int startitem, String checkinitialy) async {
    debugPrint("id"+catId);
    debugPrint("type"+type);
    debugPrint("sitem"+startitem.toString());
    debugPrint("sinit"+checkinitialy.toString());
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/get-menuitem';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("endOfProduct", false);
    try {
      if(checkinitialy == "initialy") {
        _items.clear();
        _itemspricevar.clear();
      } else {
      }
      final response = await http
          .post(
          url,
          body: {
            "id": catId,
            "start": startitem.toString(),
            "end": "0",
            "type" : type,
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("responsenested"+responseJson.toString());
      if (responseJson.toString() == "[]"){
        prefs.setBool("endOfProduct", true);
      } else {
        if(checkinitialy == "initialy") {
          _items.clear();
          _itemspricevar.clear();
        } else {
        }
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>)
        );

        for (int i = 0; i < data.length; i++){
          _items.add(SellingItemsFields(
            id: data[i]['id'].toString(),
            title: data[i]['item_name'].toString(),
            imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
            brand: data[i]['brand'].toString(),
          ));

          final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories

          if (pricevarJsondecode == null){

          } else {
            pricevarJsondecode.asMap().forEach((index, value) =>
                pricevardata.add(
                    pricevarJsondecode[index] as Map<String, dynamic>)
            );

            for (int j = 0; j < pricevardata.length; j++) {
              bool _discointDisplay = false;
              bool _membershipDisplay = false;

              if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
                _discointDisplay = false;
              } else {
                _discointDisplay = true;
              }
              if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
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
                varmemberprice:pricevardata[j]['membership_price'].toStringAsFixed(2),
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
  List<SellingItemsFields> get items {
    return [..._items];
  }

  List<SellingItemsFields> findById(String menuid) {
    return [..._itemspricevar.where((pricevar) => pricevar.menuid == menuid)];
  }


  Future<void> fetchsearchItems(String item_name) async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/search-items';
    try {
      _searchitems.clear();
      _searchitemspricevar.clear();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http
          .post(
          url,
          body: {
            "apiKey": prefs.containsKey('apiKey') ? prefs.getString('apiKey') : "",
            "item_name": item_name,
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final dataJson = json.encode(responseJson['data']);
      final dataJsondecode = json.decode(dataJson);
      List data = [];


      dataJsondecode.asMap().forEach((index, value) =>
          data.add(
              dataJsondecode[index] as Map<String, dynamic>)
      );
      _searchitems.clear();
      _searchitemspricevar.clear();

      for (int i = 0; i < data.length; i++){
        _searchitems.add(SellingItemsFields(
          id: data[i]['id'].toString(),
          title: data[i]['itemName'].toString(),
          imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['itemFeaturedImage'].toString(),
          brand: data[i]['brand'].toString(),
        ));


        final pricevarJson = json.encode(data[i]['priceVariation']); //fetching sub categories data
        final pricevarJsondecode = json.decode(pricevarJson);
        List pricevardata = []; //list for subcategories

        if (pricevarJsondecode == null){

        } else {
          pricevarJsondecode.asMap().forEach((index, value) =>
              pricevardata.add(
                  pricevarJsondecode[index] as Map<String, dynamic>)
          );

          for (int j = 0; j < pricevardata.length; j++) {
            bool _discointDisplay = false;
            bool _membershipDisplay = false;

            if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
              _discointDisplay = false;
            } else {
              _discointDisplay = true;
            }

            if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
              _membershipDisplay = false;
            } else {
              _membershipDisplay = true;
            }

            _searchitemspricevar.add(SellingItemsFields(
              varid: pricevardata[j]['id'].toString(),
              menuid: data[i]['id'].toString(),
              varname: pricevardata[j]['variationName'].toString(),
              varmrp: pricevardata[j]['mrp'].toStringAsFixed(2),
              varprice: pricevardata[j]['price'].toStringAsFixed(2),
              varmemberprice:pricevardata[j]['membership_price'].toStringAsFixed(2),
              varstock: pricevardata[j]['stock'].toString(),
              varminitem: pricevardata[j]['minItem'].toString(),
              varmaxitem: pricevardata[j]['maxItem'].toString(),
              varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                  pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
              discountDisplay: _discointDisplay,
              membershipDisplay: _membershipDisplay,
            ));
          }
        }
      }

      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  List<SellingItemsFields> get searchitems {
    return [..._searchitems];
  }

  List<SellingItemsFields> findByIdsearch(String menuid) {
    return [..._searchitemspricevar.where((pricevar) => pricevar.menuid == menuid)];
  }

  Future<void> fetchSingleItems(String itemid) async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'single-product';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _singleitems.clear();
      _singleitemspricevar.clear();
      _multiimages.clear();
      final response = await http
          .post(
          url,
          body: {
            "id": itemid,
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if(responseJson.toString() != "[]") {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(
                responseJson[index] as Map<String, dynamic>)
        );

        for (int i = 0; i < data.length; i++) {
          _singleitems.add(SellingItemsFields(
            id: data[i]['id'].toString(),
            title: data[i]['item_name'].toString(),
            imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
            brand: data[i]['brand'].toString(),
            description: data[i]['item_description'].toString(),
            manufacturedesc: data[i]['manufacturer_description'].toString(),
          ));


          final pricevarJson = json.encode(
              data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories

          if (pricevarJsondecode == null) {

          } else {
            pricevarJsondecode.asMap().forEach((index, value) =>
                pricevardata.add(
                    pricevarJsondecode[index] as Map<String, dynamic>)
            );

            for (int j = 0; j < pricevardata.length; j++) {
              var varcolor;
              if(j == 0) {
                varcolor = Color(0xff012961);
              } else {
                varcolor = Color(0xffBEBEBE);
              }
              bool _discointDisplay = false;
              bool _membershipDisplay = false;

              if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
                _discointDisplay = false;
              } else {
                _discointDisplay = true;
              }

              if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
                _membershipDisplay = false;
              } else {
                _membershipDisplay = true;
              }

              _singleitemspricevar.add(SellingItemsFields(
                varid: pricevardata[j]['id'].toString(),
                menuid: data[i]['id'].toString(),
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
                varcolor: varcolor,
              ));
              final multiimagesJson = json.encode(pricevardata[j]['images']); //fetching sub categories data
              final multiimagesJsondecode = json.decode(multiimagesJson);
              List multiimagesdata = [];

              if(multiimagesJsondecode.toString() == "[]") {
                _multiimages.add(SellingItemsFields(
                  varid: pricevardata[j]['id'].toString(),
                  menuid: data[i]['id'].toString(),
                  imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
                  varcolor: Color(0xff012961),
                ));
              } else {
                multiimagesJsondecode.asMap().forEach((index, value) =>
                    multiimagesdata.add(
                        multiimagesJsondecode[index] as Map<String, dynamic>)
                );

                for(int k = 0; k < multiimagesdata.length; k++) {
                  var varcolor;
                  if(k == 0) {
                    varcolor = Color(0xff012961);
                  } else {
                    varcolor = Color(0xffBEBEBE);
                  }
                  _multiimages.add(SellingItemsFields(
                    varid: pricevardata[j]['id'].toString(),
                    menuid: data[i]['id'].toString(),
                    imageUrl: IConstants.API_IMAGE + "items/images/" + multiimagesdata[k]['image'].toString(),
                    varcolor: varcolor,
                  ));
                }
              }
            }
          }
        }

        notifyListeners();
      }

    } catch (error) {
      throw error;
    }
  }

  List<SellingItemsFields> get singleitems {
    return [..._singleitems];
  }

  List<SellingItemsFields> findByIdsingleitems(String menuitemid) {
    return [..._singleitemspricevar.where((pricevar) => pricevar.menuid == menuitemid)];
  }

  List<SellingItemsFields> findByIdmulti(String pricevarid) {
    return [..._multiimages.where((pricevar) => pricevar.varid == pricevarid)];
  }
}