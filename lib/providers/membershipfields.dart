import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class MembershipFields with ChangeNotifier {
  final String name;
  final String description;
  final String avator;
  final String typesid;
  final String typesexpdate;
  final String typesname;
  final String typesprice;
  final String typesdiscountprice;
  final String typesduration;
  String text;
  Color backgroundcolor;
  Color textcolor;

  MembershipFields({
    this.name,
    this.description,
    this.typesexpdate,
    this.avator,
    this.typesid,
    this.typesname,
    this.typesprice,
    this.typesdiscountprice,
    this.typesduration,
    this.text,
    this.backgroundcolor,
    this.textcolor,
  });
}
