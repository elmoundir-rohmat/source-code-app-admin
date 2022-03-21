import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ShoppinglistItemsFields with ChangeNotifier {
  final String listid;
  final String listname;
  bool listcheckbox;
  final String totalitemcount;
  final String itemid;
  final String itemname;
  final String imageurl;
  final String brand;
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
  final int mode;
  final bool discountDisplay;
  final bool membershipDisplay;

  ShoppinglistItemsFields({
    this.listid,
    this.listname,
    this.listcheckbox,
    this.totalitemcount,
    this.itemid,
    this.itemname,
    this.imageurl,
    this.brand,
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
    this.mode,
    this.discountDisplay,
    this.membershipDisplay,
  });
}