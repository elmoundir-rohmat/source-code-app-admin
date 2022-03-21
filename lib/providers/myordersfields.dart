import 'package:flutter/foundation.dart';

class MyordersFields with ChangeNotifier {
  final String oid;
  final String invoiceno;
  final String odate;
  final String ototal;
  final String odelcharge;
  final String promocode;
  final double loyalty;
  final double wallet;
  final String totalDiscount;
  final String opaytype;
  final String orderType;
  final String ostatus;
  final String ostatustext;
  final String odeltime;
  final String odelivery;
  final bool isdeltime;
  final String oaddress;
  final String itemname;
  final String varname;
  final String price;
  final String qty;
  final String subtotal;
  final String itemorderid;
  final String itemid;
  final String customerorderitemsid;
  final String itemoactualamount;
  final String itemodelcharge;
  final String itemototalamount;
  final String omobilenum;
  bool checkboxval;
  String qtychange;

  final String returnref;
  final String returnitemname;
  final String returnaddress;
  final String returndate;
  final String returnreason;
  final String returnvarname;
  final String returnitemqty;

  final String itemImage;
  final String itemQuantity;
  final String itemPrice;

  final String totalTax;
  final String customerName;
  final String paymentStatus;
  final String restPay;
  final String itemLeftCount;
  final String id;
  final String discount;
  final String menuid;
  final String barcode;
  final String deliveryOn;
  final String returnTime;
  final String isTray;
  final String trayQty;
  final String ofdate;
  final String itemsCount;
  final String items;

  MyordersFields({
    this.oid,
    this.invoiceno,
    this.odate,
    this.ototal,
    this.odelcharge,
    this.promocode,
    this.loyalty,
    this.wallet,
    this.totalDiscount,
    this.opaytype,
    this.orderType,
    this.ostatus,
    this.ostatustext,
    this.odeltime,
    this.odelivery,
    this.isdeltime,
    this.oaddress,
    this.itemname,
    this.varname,
    this.price,
    this.qty,
    this.subtotal,
    this.itemorderid,
    this.itemid,
    this.customerorderitemsid,
    this.itemoactualamount,
    this.itemodelcharge,
    this.itemototalamount,
    this.omobilenum,
    this.checkboxval,
    this.qtychange,
    this.returnref,
    this.returnitemname,
    this.returnaddress,
    this.returndate,
    this.returnreason,
    this.returnvarname,
    this.returnitemqty,
    this.itemImage,
    this.itemQuantity,
    this.itemPrice,
    this.totalTax,
    this.customerName,
    this.paymentStatus,
    this.restPay,
    this.itemLeftCount,
    this.id,
    this.discount,
    this.menuid,
    this.barcode,
    this.returnTime,
    this.deliveryOn,
    this.isTray,
    this.trayQty,
    this.ofdate,
    this.itemsCount,
    this.items,
  });
}