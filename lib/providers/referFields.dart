import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class ReferFields with ChangeNotifier {
  final String amount;
  final String imageUrl;
  final int referral_count;
  final String earning_amount;
  ReferFields({
    @required this.imageUrl,
    this.amount,
    this.referral_count,
    this.earning_amount,
  });
}