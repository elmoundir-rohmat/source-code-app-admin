import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AddressFields with ChangeNotifier {
  final String userid;
  final String useraddtype;
  final String username;
  final String useraddress;
  final String userlat;
  final String userlong;
  final String addressdefault;
  final IconData addressicon;

  AddressFields({
    this.userid,
    this.useraddtype,
    this.username,
    this.useraddress,
    this.userlat,
    this.userlong,
    this.addressdefault,
    this.addressicon,
  });
}