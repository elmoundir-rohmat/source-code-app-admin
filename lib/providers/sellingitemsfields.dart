import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SellingItemsFields with ChangeNotifier {
  final String id;
  final String title;
  final String imageUrl;
  final String brand;
  final String itemqty;
  final String varid;
  final String menuid;
  final String varname;
  final String varmrp;
  final String varprice;
  final String varmemberprice;
  final String varmemberid;
  final String varstock;
  final String varminitem;
  final String varmaxitem;
  final int varLoyalty;
  Color varcolor;
  final int mode;
  final bool discountDisplay;
  final bool membershipDisplay;
  final String description;
  final String manufacturedesc;


  SellingItemsFields({
    this.id,
    this.title,
    this.imageUrl,
    this.brand,
    this.itemqty,
    this.varid,
    this.menuid,
    this.varname,
    this.varmrp,
    this.varprice,
    this.varmemberprice,
    this.varmemberid,
    this.varstock,
    this.varminitem,
    this.varmaxitem,
    this.varLoyalty,
    this.varcolor,
    this.mode,
    this.discountDisplay,
    this.membershipDisplay,
    this.description,
    this.manufacturedesc,
  });
}