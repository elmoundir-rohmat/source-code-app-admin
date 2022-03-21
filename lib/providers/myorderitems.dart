import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import '../providers/myordersfields.dart';

class MyorderList with ChangeNotifier {
  List<MyordersFields> _items = [];
  List<MyordersFields> _items1 = [];
  List<MyordersFields> _orderitems = [];
  List<MyordersFields> _returnitems = [];

  Future<void> Myorders() async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'customer/order/list';
    try {
      _items.clear();
      _orderitems.clear();
      _returnitems.clear();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
        "branch": prefs.getString('branch'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("order"+responseJson.toString());
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
            var delivery = "";
            String orderstatustext;
            bool isdeltime = true;
            if (data[i]['orderStatus'].toString().toLowerCase() == "received" ||
                data[i]['orderStatus'].toString().toLowerCase() ==
                    "processing" ||
                data[i]['orderStatus'].toString().toLowerCase() == "ready" ||
                data[i]['orderStatus'].toString().toLowerCase() ==
                    "dispatched") {
              if (data[i]['orderType'].toString().toLowerCase() == "pickup") {
                delivery = "PICKUP ON";
              } else {
                delivery = "DELIVERY ON";
              }
              isdeltime = true;
            } else if (data[i]['orderStatus'].toString().toLowerCase() ==
                "cancelled") {
              delivery = "";
              isdeltime = false;
            } else {
              if (data[i]['orderType'].toString().toLowerCase() == "pickup") {
                delivery = "PICKUP ON";
              } else {
                delivery = "DELIVERED ON";
              }
              isdeltime = true;
            }

            if (data[i]['mode'].toString() == "1") {
              orderstatustext = "ORDER STATUS";
            } else {
              orderstatustext = "RETURN STATUS";

              if (data[i]['return'].toString() != "null") {
                final returndata = data[i]['return'] as Map<String, dynamic>;
                if (returndata.containsKey("day")) {
                  if (returndata['day'].toString() != "[]") {
                    final returndataJson = json.encode(returndata['day']);
                    final returndaradecode = json.decode(returndataJson);
                    List returnitemdata = [];

                    returndaradecode.asMap().forEach((index, value) =>
                        returnitemdata.add(
                            returndaradecode[index] as Map<String, dynamic>));

                    final returnvardataJson =
                    json.encode(returndata['variation']);
                    final returnvardaradecode = json.decode(returnvardataJson);
                    List returnvaritemdata = [];

                    returnvardaradecode.asMap().forEach((index, value) =>
                        returnvaritemdata.add(returnvardaradecode[index]
                        as Map<String, dynamic>));

                    for (int k = 0; k < returnvaritemdata.length; k++) {
                      _returnitems.add(MyordersFields(
                        itemorderid: data[i]['id'].toString(),
                        returnref: returnitemdata[0]['ref'].toString(),
                        returnitemname: returnvaritemdata[k]['item'].toString(),
                        returnaddress: returnitemdata[0]['address'].toString(),
                        returndate: returnitemdata[0]['date'].toString(),
                        returnreason: returnitemdata[0]['reason'].toString(),
                        returnvarname:
                        returnvaritemdata[k]['priceVariavtion'].toString(),
                        returnitemqty: returnvaritemdata[k]['qty'].toString(),
                        itemImage: returnvaritemdata[k]['itemImage'],
                      ));
                    }
                  }
                }
              }
            }

            _items.add(MyordersFields(
              oid: data[i]['id'].toString(),
              odate: data[i]['orderDate'].toString(),
              ototal: data[i]['orderAmount'].toString(),
              odelcharge: data[i]['deliveryCharge'].toString(),
              opaytype: data[i]['paymentType'].toString(),
              orderType: data[i]['orderType'].toString(),
              ostatus: data[i]['orderStatus'].toString(),
              ostatustext: orderstatustext,
              odeltime: data[i]['fixtime'].toString(),
              odelivery: delivery,
              isdeltime: isdeltime,
              oaddress: data[i]['address'].toString(),
              itemImage: data[i]['itemImage'],
            ));

            final customerdata = data[i]['customer'] as Map<String, dynamic>;

            final orderdataJson = json.encode(data[i]['customerOrderItems']);
            final orderdaradecode = json.decode(orderdataJson);
            List orderitemdata = [];

            orderdaradecode.asMap().forEach((index, value) => orderitemdata
                .add(orderdaradecode[index] as Map<String, dynamic>));

            for (int j = 0; j < orderitemdata.length; j++) {
              _orderitems.add(MyordersFields(
                itemorderid: data[i]['id'].toString(),
                customerorderitemsid: orderitemdata[j]['id'].toString(),
                itemid: orderitemdata[j]['itemId'].toString(),
                itemname: orderitemdata[j]['itemName'].toString(),
                varname: orderitemdata[j]['priceVariavtion'].toString(),
                price: orderitemdata[j]['price'].toString(),
                qty: orderitemdata[j]['quantity'].toString(),
                subtotal: double.parse(orderitemdata[j]['subTotal']).toStringAsFixed(2),
                itemoactualamount: double.parse(data[i]['actualAmount']).toStringAsFixed(2),
                itemodelcharge: data[i]['deliveryCharge'].toString(),
                itemototalamount: data[i]['orderAmount'].toStringAsFixed(2),
                omobilenum: customerdata['mobileNumber'].toString(),
                checkboxval: false,
                qtychange: "x" + orderitemdata[j]['quantity'].toString(),
                promocode: (data[i]['promocode'].toString() != "null")
                    ? data[i]['promocode'].toString()
                    : "",
                loyalty: (data[i]['loyalty'].toString() != "null" &&
                    double.parse(data[i]['loyalty'].toString()) > 0)
                    ? double.parse(data[i]['loyalty'].toString())
                    : 0,
                wallet: (data[i]['wallet'].toString() != "null" &&
                    double.parse(data[i]['wallet'].toString()) > 0)
                    ? double.parse(data[i]['wallet'].toString())
                    : 0,
                totalDiscount: data[i]['totalDiscount'].toString(),
                odate: data[i]['orderDate'].toString(),
                opaytype: data[i]['paymentType'].toString(),
                orderType: data[i]['orderType'].toString(),
                ostatus: data[i]['orderStatus'].toString(),
                oaddress: data[i]['address'].toString(),
                odeltime: data[i]['fixtime'].toString(),
                odelivery: delivery,
                isdeltime: isdeltime,
                ostatustext: orderstatustext,
                itemImage: data[i]['itemImage'],
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

  Future<void> Getorders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("apikey"+prefs.getString('apiKey'));
    var url =
        IConstants.API_PATH + 'get-customer-order/' +prefs.getString('apiKey');
    try {
      _items.clear();

      final response = await http.get(
        url,
      );

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("getorder"+responseJson.toString());
      if (responseJson.toString() == "[]") {
      } else {
        final itemJson =
        json.encode(responseJson['items']); //fetching sub categories data
        final itemJsondecode = json.decode(itemJson);
        List data = [];
        itemJsondecode.asMap().forEach((index, value) =>
            data.add(itemJsondecode[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          var delivery = "";
          String orderstatustext;
          bool isdeltime = true;
          if (data[i]['orderStatus'].toString().toLowerCase() == "received" ||
              data[i]['orderStatus'].toString().toLowerCase() == "processing" ||
              data[i]['orderStatus'].toString().toLowerCase() == "ready" ||
              data[i]['orderStatus'].toString().toLowerCase() == "dispatched") {
            if (data[i]['orderType'].toString().toLowerCase() == "pickup") {
              delivery = "PICKUP ON";
            } else {
              delivery = "DELIVERY ON";
            }
            isdeltime = true;
          } else if (data[i]['orderStatus'].toString().toLowerCase() ==
              "cancelled") {
            delivery = "";
            isdeltime = false;
          } else {
            if (data[i]['orderType'].toString().toLowerCase() == "pickup") {
              delivery = "PICKUP ON";
            } else {
              delivery = "DELIVERED ON";
            }
            isdeltime = true;
          }
          debugPrint("getorder total discout"+ data[i]['totalDiscount'].toString());
          debugPrint("get order wallet"+ data[i]['wallet'].toString());

          debugPrint("get order wallet"+ data[i][' totalDiscount'].toString());
          _items.add(MyordersFields(
            id: data[i]['id'].toString(),
            oid: data[i]['order_d'].toString(),
            itemid: data[i]['itemId'].toString(),
            itemname: data[i]['itemName'].toString(),
            varname: data[i]['priceVariavtion'].toString(),
            price: data[i]['price'].toString(),
            qty: data[i]['quantity'].toString(),
            itemoactualamount: double.parse(data[i]['actualAmount']).toStringAsFixed(2),
            discount: data[i]['discount'].toString(),
            subtotal: data[i]['subTotal'].toString(),
            itemImage: data[i]['image'].toString(),
//              itemImage: IConstants.API_IMAGE + "items/images/" + data[i]['image'].toString(),

            menuid: data[i]['menuid'].toString(),
            odeltime: data[i]['fixtime'].toString(),
            odate: data[i]['fixdate'].toString(),
            itemPrice: data[i]['itemPrice'].toString(),
            itemQuantity: data[i]['itemQuantity'].toString(),
            itemLeftCount: data[i]['itemLeftCount'].toString(),
            wallet: double.parse(data[i]['wallet'].toString()),
            itemodelcharge: data[i]['deliveryCharge'].toString(),
            loyalty: (data[i]['loyalty'].toString() != "null" &&
                double.parse(data[i]['loyalty'].toString()) > 0)
                ? double.parse(data[i]['loyalty'].toString())
                : 0,
            totalDiscount: double.parse(data[i]['totalDiscount']).toStringAsFixed(2),
            /* (responseJson['wallet'].toString() != "null" &&
                double.parse(responseJson['wallet'].toString()) > 0)
                ? double.parse(responseJson['wallet'].toString())
                : 0,*/
            ostatustext: orderstatustext,
            odelivery: delivery,
            isdeltime: isdeltime,
            ototal: double.parse(data[i]['orderAmount']).toStringAsFixed(2),
            orderType: data[i]['orderType'].toString(),
            ostatus: data[i]['orderStatus'].toString(),
          ));
        }
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> Vieworders(String orderId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'view-customer-order-details/' + orderId;
    try {
      _items.clear();
      _orderitems.clear();
//      _returnitems.clear();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("order view"+responseJson.toString());
      if (responseJson.toString() == "[]") {
      } else {
        var delivery = "";
        String orderstatustext;
        bool isdeltime = true;
        if (['orderStatus'].toString().toLowerCase() == "received" ||
            responseJson['orderStatus'].toString().toLowerCase() ==
                "processing" ||
            responseJson['orderStatus'].toString().toLowerCase() == "ready" ||
            responseJson['orderStatus'].toString().toLowerCase() ==
                "dispatched") {
          if (responseJson['orderType'].toString().toLowerCase() == "pickup") {
            delivery = "PICKUP ON";
          } else {
            delivery = "DELIVERY ON";
          }
          isdeltime = true;
        } else if (responseJson['orderStatus'].toString().toLowerCase() ==
            "cancelled") {
          delivery = "";
          isdeltime = false;
        } else {
          if (responseJson['orderType'].toString().toLowerCase() == "pickup") {
            delivery = "PICKUP ON";
          } else {
            delivery = "DELIVERED ON";
          }
          isdeltime = true;
        }

        _items.add(MyordersFields(
          wallet: (responseJson['wallet'].toString() != "null" &&
              double.parse(responseJson['wallet'].toString()) > 0)
              ? double.parse(responseJson['wallet'].toString())
              : 0,
          loyalty: (responseJson['loyalty'].toString() != "null" &&
              double.parse(responseJson['loyalty'].toString()) > 0)
              ? double.parse(responseJson['loyalty'].toString())
              : 0,
          itemorderid: responseJson['id'].toString(),
          customerorderitemsid: responseJson['id'].toString(),
          invoiceno: responseJson['invoice'].toString(),
          odate: responseJson['orderDate'].toString(),
          itemoactualamount: double.parse(responseJson['actualAmount']).toStringAsFixed(2),
          totalTax: responseJson['totalTax'].toString(),
          totalDiscount: double.parse(responseJson['totalDiscount']).toStringAsFixed(2),
          itemototalamount: double.parse(responseJson['orderAmount']).toStringAsFixed(2),
          customerName: responseJson['customerName'].toString(),
          oaddress: responseJson['address'].toString(),
          orderType: responseJson['orderType'].toString(),
          opaytype: responseJson['paymentType'].toString(),
          paymentStatus: responseJson['paymentStatus'].toString(),
          restPay: responseJson['restPay'].toString(),
          odeltime: responseJson['fixtime'].toString(),
          ofdate: responseJson['fixdate'].toString(),
          ostatus: responseJson['orderStatus'].toString(),
          itemodelcharge: responseJson['deliveryCharge'].toString(),
          itemsCount: responseJson['itemsCount'].toString(),
        ));
debugPrint("wallet"+items[0].wallet.toString());

        final itemJson = json.encode(responseJson['items']);
        final itemJsondecode = json.decode(itemJson);
        List data = [];

        itemJsondecode.asMap().forEach((index, value) =>
            data.add(itemJsondecode[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          var delivery = "";
          String orderstatustext;
          bool isdeltime = true;
          if (data[i]['orderStatus'].toString().toLowerCase() == "received" ||
              data[i]['orderStatus'].toString().toLowerCase() == "processing" ||
              data[i]['orderStatus'].toString().toLowerCase() == "ready" ||
              data[i]['orderStatus'].toString().toLowerCase() == "dispatched") {
            if (data[i]['orderType'].toString().toLowerCase() == "pickup") {
              delivery = "PICKUP ON";
            } else {
              delivery = "DELIVERY ON";
            }
            isdeltime = true;
          } else if (data[i]['orderStatus'].toString().toLowerCase() ==
              "cancelled") {
            delivery = "";
            isdeltime = false;
          } else {
            if (data[i]['orderType'].toString().toLowerCase() == "pickup") {
              delivery = "PICKUP ON";
            } else {
              delivery = "DELIVERED ON";
            }
            isdeltime = true;
          }
          _orderitems.add(MyordersFields(
            id: data[i]['id'].toString(),
            customerorderitemsid: data[i]['id'].toString(),
            itemorderid: responseJson['id'].toString(),
            invoiceno: responseJson['invoice'].toString(),
            oid: data[i]['order_d'].toString(),
            itemid: data[i]['itemId'].toString(),
            itemname: data[i]['itemName'].toString(),
            varname: data[i]['priceVariavtion'].toString(),
            price: data[i]['price'].toString(),
            qty: data[i]['quantity'].toString(),
            itemoactualamount: double.parse(data[i]['actualAmount']).toStringAsFixed(2),
            discount: data[i]['discount'].toString(),
            subtotal: double.parse(data[i]['subTotal']).toStringAsFixed(2),
            itemImage: data[i]['image'].toString(),
            menuid: data[i]['menuid'].toString(),
            barcode: data[i]['barcode'].toString(),
            returnTime: data[i]['return_time'].toString(),
            deliveryOn: (responseJson['orderStatus'].toString() == "DELIVERED") ? responseJson['deliveryOn'].toString() : "",
            ostatustext: orderstatustext,
            odelivery: delivery,
            isdeltime: isdeltime,
            checkboxval: false,
            qtychange: data[i]['quantity'].toString(),
          ));
        }

        /* List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++){


        }*/

      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> ReturnItem(String array, String orderid, String itemname) async {
    // imp feature in adding async is the it automatically wrap into Future.

    var url = IConstants.API_PATH + 'return/new-return';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "customerId": prefs.getString('userID'),
        "orderid": orderid,
        "date": prefs.getString('fixdate'),
        "note": "",
        "reason": prefs.getString('returning_reason'),
        "mode": prefs.getString('return_type'),
        "address": prefs.getString('addressId'),
        "itemId": array.toString(),
        "branch": prefs.getString('branch'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == '200') {}
    } catch (error) {
      throw error;
    }
  }

  List<MyordersFields> get items {
    return [..._items];
  }

  List<MyordersFields> get items1 {
    return [..._items1];
  }

  /*List<MyordersFields> get orderitems {
    return [..._orderitems];
  }*/

  List<MyordersFields> findById(String orderid) {
    return [..._orderitems.where((myorder) => myorder.itemorderid == orderid)];
  }

  List<MyordersFields> findByreturnId(String orderid) {
    return [..._returnitems.where((myorder) => myorder.itemorderid == orderid)];
  }

  List<MyordersFields> get vieworder {
    return [..._items];
  }

  List<MyordersFields> get vieworder1 {
    return [..._orderitems];
  }
}
