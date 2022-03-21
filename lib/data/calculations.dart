import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/hiveDB.dart';
import '../main.dart';

class Calculations with ChangeNotifier
{
  static Box<Product> productBox = Hive.box<Product>(productBoxName);

  static deleteMembershipItem() async {
    for(int i = 0; i < productBox.values.length; i++) {
      if(productBox.values.elementAt(i).mode == 1) {
        productBox.deleteAt(i);
        break;
      }
    }
  }

  static int get checkmembershipItem {
    for(int i = 0; i < productBox.values.length; i++) {
      if(productBox.values.elementAt(i).mode == 1) {
        return 1;
      }
      }
    return 0;
  }

  static int get itemCount { // item count
    int cartCount = 0;
    cartCount=productBox.length;
    /*for(int i = 0; i < productBox.length; i++) {
      cartCount = cartCount + productBox.values.elementAt(i).itemQty;
    }*/
    return cartCount;
  }

  static double get totalmrp { // mrp price
    double totalmrp = 0;

    for(int i = 0; i < productBox.length; i++) {
      totalmrp = totalmrp + (productBox.values.elementAt(i).varMrp * productBox.values.elementAt(i).itemQty);
    }
    return totalmrp;
  }

  static double get totalprice { //for discount without membership
    double totalprice = 0;
    for(int i = 0; i < productBox.length; i++) {
      if(productBox.values.elementAt(i).itemPrice <= 0 ||
          productBox.values.elementAt(i).itemPrice.toString() == "" ||
          productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp) {
      } else {
        totalprice = totalprice +
            ((productBox.values.elementAt(i).varMrp * productBox.values.elementAt(i).itemQty) -
                (productBox.values.elementAt(i).itemPrice * productBox.values.elementAt(i).itemQty));
      }
    }
    return totalprice;
  }

  static double get discount {
    double discount = 0;
      discount = totalmrp - total;
      return discount;
  }

  static double get totalMembersPrice { //for discount with membership
    double totalprice = 0;
    for(int i = 0; i < productBox.length; i++) {
      if (productBox.values.elementAt(i).membershipPrice == '-' ||
          productBox.values.elementAt(i).membershipPrice == "0") {

        if (productBox.values.elementAt(i).itemPrice <= 0 ||
            productBox.values.elementAt(i).itemPrice.toString() == "" ||
            productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp) {

        } else {
          totalprice = totalprice +
              ((productBox.values.elementAt(i).varMrp * productBox.values.elementAt(i).itemQty)
                  - (productBox.values.elementAt(i).itemPrice * productBox.values.elementAt(i).itemQty));
        }
      }  else {
        totalprice = totalprice +
            ((productBox.values.elementAt(i).varMrp * productBox.values.elementAt(i).itemQty) -
                (double.parse(productBox.values.elementAt(i).membershipPrice) * productBox.values.elementAt(i).itemQty));

      }
    }
    return totalprice;
  }

  static double get total { //Total amount without membership
    double total = 0;
    for(int i = 0; i < productBox.length; i++) {
      if(productBox.values.elementAt(i).itemPrice <= 0 ||
          productBox.values.elementAt(i).itemPrice.toString() == "" ||
          productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp) {

        total = total +
            (productBox.values.elementAt(i).varMrp * productBox.values.elementAt(i).itemQty);
      } else {
        total = total +
            (productBox.values.elementAt(i).itemPrice * productBox.values.elementAt(i).itemQty);
      }
    }
    return total;
  }

  static double get totalMember { //Total amount with membership
    double total = 0;
    for(int i = 0; i < productBox.length; i++) {
      if (productBox.values.elementAt(i).membershipPrice == '-' ||
          productBox.values.elementAt(i).membershipPrice == "0") {

        if (productBox.values.elementAt(i).itemPrice <= 0 ||
            productBox.values.elementAt(i).itemPrice.toString() == "" ||
            productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp) {

          total = total +
              (productBox.values.elementAt(i).varMrp * productBox.values.elementAt(i).itemQty);
        } else {
          total = total +
              (productBox.values.elementAt(i).itemPrice * productBox.values.elementAt(i).itemQty);
        }
      } else {
        total = total +
            (double.parse(productBox.values.elementAt(i).membershipPrice) * productBox.values.elementAt(i).itemQty);
      }
    }
    return total;
  }

}