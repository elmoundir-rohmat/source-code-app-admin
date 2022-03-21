import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class PickuplocFields with ChangeNotifier {
  final String id;
  final String name;
  final String address;
  final String contact;

  PickuplocFields({
    this.id,
    this.name,
    this.address,
    this.contact,
  });
}