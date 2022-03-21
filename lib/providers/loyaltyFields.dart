import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoyaltyFields with ChangeNotifier {
  final String id;
  final String status;
  final String type;
  final String minimumOrderAmount;
  final String points;
  final String maximumRedeem;
  final String discount;

  LoyaltyFields({
    this.id,
    this.status,
    this.type,
    this.minimumOrderAmount,
    this.points,
    this.maximumRedeem,
    this.discount,
  });
}