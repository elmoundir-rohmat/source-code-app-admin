import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeliveryslotFields with ChangeNotifier {
  final String day;
  final String date;
  final String dateformat;
  double width;
  final String time;
  final String id;
  Color selectedColor;
  Color textColor;
  Color borderColor;
  bool isSelect;
  final String index;
  final String status;

  DeliveryslotFields({
    this.day,
    this.date,
    this.dateformat,
    this.width,
    this.time,
    this.id,
    this. selectedColor,
    this.textColor,
    this.borderColor,
    this.isSelect,
    this.index,
    this.status,
  });
}