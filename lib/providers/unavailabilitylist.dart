import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../providers/unavailableproducts_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class unavailabilities with ChangeNotifier {
  List<unavailabilitiesfield> _items = [];

  Future<void>  unavailable(String id,
      String title,
      String brand,
      String varid,
      String menuid,
      String varname,
      String varmrp,
      String price,
      String varmembership,
      String varstock,
      String varminitem,
      String varmaxitem,
      String imageUrl
      ) async{

    _items.add(unavailabilitiesfield(
        id: id,
      title: title,
      brand: brand,
      varid: varid,
      menuid: menuid,
      varname: varname,
      varmrp: varmrp,
      varprice: price,
      varmemberprice: varmembership,
      varstock: varstock,
      varminitem: varminitem,
      varmaxitem: varmaxitem,
      imageUrl: imageUrl
    )
    );

  }

  List<unavailabilitiesfield> get items {
    return [..._items];
  }
}