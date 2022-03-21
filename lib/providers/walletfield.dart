import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class WalletItemsFields with ChangeNotifier {
  final String title;
  final String date;
  final String time;
  final String note;
  final String amount;
  final String closingbalance;
  final String img;
  final String paymentType;
  final String paymentName;
  final String paymentMode;

  WalletItemsFields({
    this.title,
    this.date,
    this.time,
    this.note,
    this.amount,
    this.closingbalance,
    this.img,
    this.paymentType,
    this.paymentName,
    this.paymentMode,
  });
}